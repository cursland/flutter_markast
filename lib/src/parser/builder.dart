/// `ASTBuilder` — turns a `package:markdown` Node tree into the markast
/// AST tree.
///
/// The Dart `package:markdown` already produces a structured `List<md.Node>`
/// (unlike Python's flat token stream), so the builder walks that tree
/// directly instead of doing the open/close depth counting the Python
/// builder needs. The behavioural contract is the same:
///
/// * Diagnostics never alter the parse — bad content is repaired in the
///   builder and the rules emit observational warnings on the side.
/// * Footnote definitions are emitted at the end of the document
///   (`package:markdown` already groups them into a `<section
///   class="footnotes">` block, matching Python's `footnote_block` layout).
library;

import 'package:markdown/markdown.dart' as md;

import '../ast/factory.dart' as f;
import '../ast/node_types.dart';
import '../ast/utils.dart' show extractText;
import '../config.dart';
import '../rules/codes.dart';
import '../rules/rule.dart';
import '../widgets_dsl/registry.dart';
import 'inline.dart';
import 'props.dart';

class ASTBuilder {
  ASTBuilder(this._config, this._registry, this._rules);

  final ParserConfig _config;
  final WidgetRegistry _registry;
  final List<Rule> _rules;
  final InlineBuilder _inline = InlineBuilder();
  final List<Diagnostic> _diagnostics = [];
  final Set<String> _footnoteDefs = {};
  // (label, contextHint) — the context is purely informational for diagnostics.
  final List<(String, String)> _footnoteRefs = [];
  int _widgetDepth = 0;

  /// Produce a markast AST `document` map from the top-level `md.Node`
  /// children parsed by `package:markdown`.
  Map<String, dynamic> build(List<md.Node> nodes) {
    final children = _blocks(nodes);

    // Post-pass: emit dangling-footnote diagnostics. We only emit them after
    // the whole document has been seen, so a reference forward of its
    // definition is still valid.
    for (final entry in _footnoteRefs) {
      for (final rule in _rules) {
        final diags = rule.checkFootnoteRef(entry.$1, _footnoteDefs);
        if (diags != null) _diagnostics.addAll(diags);
      }
    }

    return f.document(
      children,
      [for (final d in _diagnostics) d.toDict()],
    );
  }

  // ── Block dispatch ──────────────────────────────────────────────────────
  List<Map<String, dynamic>> _blocks(List<md.Node> nodes) {
    final out = <Map<String, dynamic>>[];
    for (final n in nodes) {
      final emitted = _block(n);
      if (emitted == null) continue;
      // A block builder can return multiple sibling nodes (e.g. when a
      // footnote section is unwrapped). Detect that via the special wrapper
      // type used internally.
      if (emitted['__siblings__'] == true) {
        out.addAll((emitted['nodes'] as List).cast<Map<String, dynamic>>());
      } else {
        out.add(emitted);
      }
    }
    return out;
  }

  Map<String, dynamic>? _block(md.Node n) {
    if (n is md.Text) {
      // package:markdown emits raw HTML blocks as top-level Text nodes (see
      // HtmlBlockSyntax). The syntax injects a leading `\n` when the block
      // is preceded by another block, and `trimRight`s the trailing newline.
      // The Python token stream does neither — restore the byte-equivalent
      // shape so `tok.content` matches.
      var value = n.text;
      if (value.startsWith('\n')) value = value.substring(1);
      if (value.trim().isEmpty) return null;
      if (!value.endsWith('\n')) value = '$value\n';
      if (_config.diagnoseHtmlBlocks) {
        for (final r in _rules) {
          final diags = r.checkHtmlBlock(value);
          if (diags != null) _diagnostics.addAll(diags);
        }
      }
      return f.htmlBlock(value);
    }
    if (n is! md.Element) return null;

    final tag = n.tag;
    switch (tag) {
      case 'h1':
      case 'h2':
      case 'h3':
      case 'h4':
      case 'h5':
      case 'h6':
        return _heading(int.parse(tag.substring(1)), n);
      case 'p':
        return _paragraph(n);
      case 'blockquote':
        return f.blockquote(_blocks(n.children ?? const []));
      case 'pre':
        return _codeBlock(n);
      case 'ul':
        return _list(false, n);
      case 'ol':
        return _list(true, n);
      case 'table':
        return _table(n);
      case 'hr':
        return f.divider();
      case 'markast_widget':
        return _widget(n);
      case 'section':
        // package:markdown wraps footnote definitions in a
        // <section class="footnotes"><ol><li>…</li></ol></section> at the end
        // of the document. Unwrap and emit each <li> as a footnote_def so the
        // top-level children layout matches Python's output (defs appear
        // after all the other blocks, in source order).
        if (n.attributes['class'] == 'footnotes') {
          return _footnoteSection(n);
        }
        return null;
      default:
        return null;
    }
  }

  // ── Specific block builders ─────────────────────────────────────────────
  Map<String, dynamic> _heading(int level, md.Element n) {
    final spans = _inline.build(n.children);

    for (final r in _rules) {
      final diags = r.checkHeadingChildren(spans, level);
      if (diags != null) _diagnostics.addAll(diags);
    }

    return f.heading(level, _sanitizeHeadingChildren(spans));
  }

  List<Map<String, dynamic>> _sanitizeHeadingChildren(
      List<Map<String, dynamic>> spans) {
    final cleaned = <Map<String, dynamic>>[];
    for (final span in spans) {
      final t = span['type'];
      if (t == NodeType.inlineImage) {
        final alt = (span['alt'] as String?) ?? '';
        if (alt.isNotEmpty) cleaned.add(f.text(alt));
      } else if (NodeType.headingAllowedInline.contains(t)) {
        cleaned.add(span);
      } else {
        final txt = extractText(span);
        if (txt.isNotEmpty) cleaned.add(f.text(txt));
      }
    }
    return cleaned;
  }

  Map<String, dynamic> _paragraph(md.Element n) {
    final spans = _inline.build(n.children);

    // Hoist a lone-image paragraph into a block image.
    final nonBreak = [
      for (final s in spans)
        if (s['type'] != NodeType.softbreak && s['type'] != NodeType.hardbreak)
          s,
    ];
    if (nonBreak.length == 1 && nonBreak.first['type'] == NodeType.inlineImage) {
      final img = nonBreak.first;
      return f.image(
        (img['src'] as String?) ?? '',
        (img['alt'] as String?) ?? '',
        img['title'] as String?,
      );
    }

    // Track footnote refs for the dangling-ref check.
    for (final span in spans) {
      if (span['type'] == NodeType.footnoteRef) {
        _footnoteRefs.add(((span['label'] as String?) ?? '', 'paragraph'));
      }
    }

    return f.paragraph(spans);
  }

  Map<String, dynamic> _codeBlock(md.Element pre) {
    // <pre> contains a single <code> child; the code element's class encodes
    // the language as "language-X" when known.
    md.Element? codeEl;
    for (final c in pre.children ?? const <md.Node>[]) {
      if (c is md.Element && c.tag == 'code') {
        codeEl = c;
        break;
      }
    }
    if (codeEl == null) {
      return f.codeBlock('', pre.textContent.trimRight());
    }

    var language = '';
    final cls = codeEl.attributes['class'];
    if (cls != null && cls.startsWith('language-')) {
      language = cls.substring('language-'.length);
    }

    final raw = codeEl.textContent;
    // package:markdown stores fenced-block content with a trailing newline;
    // strip it to match Python's `tok.content.rstrip("\n")`.
    final value = raw.endsWith('\n') ? raw.substring(0, raw.length - 1) : raw;

    // package:markdown does NOT parse the fence info-string beyond the
    // language. Filename + highlight-lines (e.g. ```ts [foo.ts]{1,3-4}`) live
    // in that info string. To recover them, we re-parse the info from the
    // language attribute itself if it carries the [..]{..} suffix (some
    // grammars), otherwise we fall back to the language as-is.
    final info = parseFenceInfo(language);
    return f.codeBlock(
      (info['language'] as String?) ?? '',
      value,
      filename: info['filename'] as String?,
      highlightLines: (info['highlight_lines'] as List<int>).isEmpty
          ? null
          : (info['highlight_lines'] as List<int>),
    );
  }

  Map<String, dynamic> _list(bool ordered, md.Element n) {
    var start = 1;
    if (ordered) {
      final startAttr = n.attributes['start'];
      if (startAttr != null) {
        start = int.tryParse(startAttr) ?? 1;
      }
    }
    final items = <Map<String, dynamic>>[];
    for (final child in n.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'li') {
        items.add(_listItem(child));
      }
    }
    return f.listNode(ordered, items, ordered ? start : null);
  }

  Map<String, dynamic> _listItem(md.Element li) {
    // package:markdown attaches `class="task-list-item"` and prepends a
    // <input type="checkbox" [checked="true"]> for tasklist items.
    bool? checked;
    final isTaskList = (li.attributes['class'] ?? '').contains('task-list-item');

    final rawChildren = List<md.Node>.from(li.children ?? const <md.Node>[]);
    if (isTaskList && rawChildren.isNotEmpty) {
      // Find and remove the leading <input> (the task-list marker). It may
      // sit a couple of nodes in if there's leading whitespace.
      for (var i = 0; i < rawChildren.length && i < 3; i++) {
        final c = rawChildren[i];
        if (c is md.Element && c.tag == 'input') {
          checked = c.attributes['checked'] == 'true';
          rawChildren.removeAt(i);
          // Also drop a leading whitespace Text that the syntax inserts
          // between the checkbox and the content.
          if (i < rawChildren.length && rawChildren[i] is md.Text) {
            final t = rawChildren[i] as md.Text;
            if (t.text.startsWith(' ')) {
              rawChildren[i] = md.Text(t.text.substring(1));
              if ((rawChildren[i] as md.Text).text.isEmpty) {
                rawChildren.removeAt(i);
              }
            }
          }
          break;
        }
      }
    }

    final content = _listItemContent(rawChildren);
    return f.listItem(content, checked: checked);
  }

  /// Build the children of a list item. Tight lists in `package:markdown`
  /// drop the `<p>` wrapper and inline the content directly; loose lists
  /// keep the paragraph wrappers. We mirror the Python builder's behaviour:
  /// flatten the loose <p>s into their inline children when the list is
  /// tight, otherwise emit them as paragraph nodes.
  List<Map<String, dynamic>> _listItemContent(List<md.Node> nodes) {
    final out = <Map<String, dynamic>>[];
    final pendingInline = <md.Node>[];

    void flushInline() {
      if (pendingInline.isEmpty) return;
      final built = _inline.build(pendingInline);
      out.addAll(built);
      pendingInline.clear();
    }

    for (final n in nodes) {
      if (n is md.Element) {
        switch (n.tag) {
          case 'p':
            flushInline();
            out.add(f.paragraph(_inline.build(n.children)));
            continue;
          case 'ul':
            flushInline();
            out.add(_list(false, n));
            continue;
          case 'ol':
            flushInline();
            out.add(_list(true, n));
            continue;
          case 'pre':
            flushInline();
            out.add(_codeBlock(n));
            continue;
          case 'blockquote':
            flushInline();
            out.add(f.blockquote(_blocks(n.children ?? const [])));
            continue;
          case 'table':
            flushInline();
            out.add(_table(n));
            continue;
          case 'markast_widget':
            flushInline();
            final w = _widget(n);
            out.add(w);
            continue;
          default:
            // Treat as inline: bold/italic/code/link/etc. fall through here.
            pendingInline.add(n);
            continue;
        }
      } else {
        pendingInline.add(n);
      }
    }
    flushInline();
    return out;
  }

  Map<String, dynamic> _table(md.Element n) {
    final headRows = <Map<String, dynamic>>[];
    final bodyRows = <Map<String, dynamic>>[];

    for (final section in n.children ?? const <md.Node>[]) {
      if (section is! md.Element) continue;
      final inHead = section.tag == 'thead';
      final inBody = section.tag == 'tbody';
      if (!inHead && !inBody) continue;
      for (final rowNode in section.children ?? const <md.Node>[]) {
        if (rowNode is! md.Element || rowNode.tag != 'tr') continue;
        final cells = <Map<String, dynamic>>[];
        for (final cellNode in rowNode.children ?? const <md.Node>[]) {
          if (cellNode is! md.Element) continue;
          final isHeader = cellNode.tag == 'th';
          if (!isHeader && cellNode.tag != 'td') continue;

          // package:markdown stores alignment as a bare `align="left"` attr
          // on the cell. (Python markdown-it-py uses `style="text-align:..."`.)
          // Accept both for robustness.
          String? align = cellNode.attributes['align'];
          if (align == null) {
            final style = cellNode.attributes['style'];
            if (style != null && style.startsWith('text-align:')) {
              align = style.substring('text-align:'.length).trim();
            }
          }

          final spans = _inline.build(cellNode.children);
          for (final rule in _rules) {
            final diags = rule.checkTableCellChildren(spans, isHeader);
            if (diags != null) _diagnostics.addAll(diags);
          }
          final cleaned = _sanitizeCellChildren(spans);
          cells.add(f.tableCell(cleaned, align: align, isHeader: isHeader));
        }
        (inHead ? headRows : bodyRows).add(f.tableRow(cells));
      }
    }

    return f.table(f.tableHead(headRows), f.tableBody(bodyRows));
  }

  List<Map<String, dynamic>> _sanitizeCellChildren(
      List<Map<String, dynamic>> spans) {
    final cleaned = <Map<String, dynamic>>[];
    for (final span in spans) {
      final t = span['type'];
      if (t == NodeType.inlineImage) {
        final alt = (span['alt'] as String?) ?? '';
        if (alt.isNotEmpty) cleaned.add(f.text(alt));
      } else if (NodeType.tableCellAllowedInline.contains(t)) {
        cleaned.add(span);
      } else {
        final txt = extractText(span);
        if (txt.isNotEmpty) cleaned.add(f.text(txt));
      }
    }
    return cleaned;
  }

  // ── Widget container ────────────────────────────────────────────────────
  Map<String, dynamic> _widget(md.Element n) {
    final widgetName = n.attributes['markast_widget_name'] ?? '';
    final info = n.attributes['markast_widget_info'] ?? '';

    _widgetDepth += 1;
    try {
      if (_config.maxWidgetDepth > 0 &&
          _widgetDepth > _config.maxWidgetDepth) {
        _diagnostics.add(Diagnostic(
          code: wNestingTooDeep,
          message:
              "Widget '$widgetName' nested deeper than max_widget_depth=${_config.maxWidgetDepth}.",
          context: 'widget=$widgetName',
        ));
      }

      final rawProps = parseProps(info, widgetName);
      final widgetFactory = _registry.get(widgetName);

      Map<String, dynamic> validated;
      final widgetDiagnostics = <Diagnostic>[];

      if (widgetFactory == null) {
        validated = Map<String, dynamic>.from(rawProps);
      } else {
        final widget = widgetFactory();
        final result = widget.validateProps(rawProps);
        validated = result.validated;
        widgetDiagnostics.addAll(result.diagnostics);
        widgetDiagnostics.addAll(widget.validate(validated, const {}));
      }

      _diagnostics.addAll(widgetDiagnostics);

      final slots = _splitSlots(n.children ?? const []);

      for (final rule in _rules) {
        final diags = rule.checkWidget(
          widgetName,
          validated,
          slots,
          widgetFactory != null,
        );
        if (diags != null) _diagnostics.addAll(diags);
      }

      return f.widgetNode(widgetName, validated, slots);
    } finally {
      _widgetDepth -= 1;
    }
  }

  /// Split a widget body into named slots using bare h1 dividers, exactly
  /// like the Python `_split_slots` does. The h1 must be at the root level
  /// of the body and its text must match `[a-z][a-z0-9_-]*`.
  Map<String, List<Map<String, dynamic>>> _splitSlots(List<md.Node> bodyNodes) {
    final slotIdRe = RegExp(r'^[a-z][a-z0-9_-]*$');
    final slots = <String, List<md.Node>>{'default': []};
    var currentSlot = 'default';

    for (final n in bodyNodes) {
      if (n is md.Element &&
          n.tag == 'h1' &&
          n.children != null &&
          n.children!.length == 1) {
        final first = n.children!.first;
        if (first is md.Text) {
          final candidate = first.text.trim();
          if (slotIdRe.hasMatch(candidate)) {
            currentSlot = candidate;
            slots[currentSlot] = <md.Node>[];
            continue;
          }
        }
      }
      slots[currentSlot]!.add(n);
    }

    return {
      for (final entry in slots.entries) entry.key: _blocks(entry.value),
    };
  }

  // ── Footnote section unwrap ─────────────────────────────────────────────
  Map<String, dynamic>? _footnoteSection(md.Element section) {
    // <section class="footnotes"><ol><li id="fn-X" footnoteLabel="X">…</li>…</ol></section>
    final defs = <Map<String, dynamic>>[];
    for (final child in section.children ?? const <md.Node>[]) {
      if (child is md.Element && child.tag == 'ol') {
        for (final li in child.children ?? const <md.Node>[]) {
          if (li is md.Element && li.tag == 'li') {
            final label = li.footnoteLabel ?? '';
            if (label.isNotEmpty) _footnoteDefs.add(label);
            defs.add(f.footnoteDef(
              label,
              _blocks(li.children ?? const []),
            ));
          }
        }
      }
    }
    if (defs.isEmpty) return null;
    // Smuggle multiple sibling nodes back up to _blocks.
    return {'__siblings__': true, 'nodes': defs};
  }
}
