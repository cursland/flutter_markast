/// `MarkdownRenderer` — AST → Markdown text.
///
/// The roundtrip `parse(text).toMarkdown()` yields a string equivalent to
/// `text` for every Markdown construct markast supports, modulo:
///
/// * Excess blank lines collapsed to a single blank line.
/// * Setext headings normalised to ATX.
/// * Loose-list marker positions normalised.
/// * List indent normalised to 2 spaces.
///
/// Subclass and override the relevant `_block_*` / `_inline_*` methods to
/// customise emission for specific node types.
library;

import '../ast/node_types.dart';
import '../widgets_dsl/registry.dart';

class MarkdownRenderer {
  MarkdownRenderer([WidgetRegistry? registry])
      : registry = registry ?? defaultRegistry;

  final WidgetRegistry registry;

  /// Render an AST root (or any block subtree) to a Markdown string.
  String render(Map<String, dynamic> ast) {
    if (ast['type'] != NodeType.document) {
      return _renderBlock(ast) ?? '';
    }
    return _renderBlockChildren(_asMaps(ast['children']));
  }

  // ── Block dispatch ──────────────────────────────────────────────────────
  String _renderBlockChildren(List<Map<String, dynamic>> children) {
    final parts = <String>[];
    for (final child in children) {
      final rendered = _renderBlock(child);
      if (rendered != null && rendered.isNotEmpty) parts.add(rendered);
    }
    return parts.join('\n\n');
  }

  String? _renderBlock(Map<String, dynamic> node) {
    switch (node['type']) {
      case NodeType.heading:
        return _blockHeading(node);
      case NodeType.paragraph:
        return _blockParagraph(node);
      case NodeType.blockquote:
        return _blockBlockquote(node);
      case NodeType.codeBlock:
        return _blockCodeBlock(node);
      case NodeType.image:
        return _blockImage(node);
      case NodeType.video:
        return _blockVideo(node);
      case NodeType.list:
        return _blockList(node);
      case NodeType.table:
        return _blockTable(node);
      case NodeType.divider:
        return _blockDivider(node);
      case NodeType.htmlBlock:
        return _blockHtmlBlock(node);
      case NodeType.widget:
        return _blockWidget(node);
      case NodeType.footnoteDef:
        return _blockFootnoteDef(node);
      default:
        return null;
    }
  }

  // ── Block renderers ─────────────────────────────────────────────────────
  String _blockHeading(Map<String, dynamic> node) {
    final lvl = (node['level'] as int).clamp(1, 6);
    return '${'#' * lvl} ${_inline(_asMaps(node['children']))}';
  }

  String _blockParagraph(Map<String, dynamic> node) =>
      _inline(_asMaps(node['children']));

  String _blockBlockquote(Map<String, dynamic> node) {
    final inner = _renderBlockChildren(_asMaps(node['children']));
    return inner
        .split('\n')
        .map((line) => line.isEmpty ? '>' : '> $line')
        .join('\n');
  }

  String _blockCodeBlock(Map<String, dynamic> node) {
    var info = (node['language'] as String?) ?? '';
    final filename = node['filename'] as String?;
    if (filename != null && filename.isNotEmpty) info += ' [$filename]';
    final highlightLines = (node['highlight_lines'] as List?)?.cast<int>();
    if (highlightLines != null && highlightLines.isNotEmpty) {
      info += '{${_formatHighlight(highlightLines)}}';
    }
    return '```$info\n${node['value'] ?? ''}\n```';
  }

  String _blockImage(Map<String, dynamic> node) => _imageMd(
        (node['src'] as String?) ?? '',
        (node['alt'] as String?) ?? '',
        node['title'] as String?,
      );

  String _blockVideo(Map<String, dynamic> node) {
    final factory = registry.get('video');
    if (factory == null) return '';
    return factory().toMarkdown(
      <String, dynamic>{
        'type': NodeType.widget,
        'widget': 'video',
        'props': <String, dynamic>{
          for (final entry in node.entries)
            if (entry.key != 'type') entry.key: entry.value,
        },
        'slots': const {'default': <Map<String, dynamic>>[]},
      },
      _renderBlockChildren,
    );
  }

  String _blockList(Map<String, dynamic> node) {
    final ordered = node['ordered'] == true;
    final start = (node['start'] as int?) ?? 1;
    final lines = <String>[];
    final items = _asMaps(node['children']);
    for (var idx = 0; idx < items.length; idx++) {
      final item = items[idx];
      var prefix = ordered ? '${start + idx}.' : '-';
      final checked = item['checked'];
      if (checked == true) {
        prefix += ' [x]';
      } else if (checked == false) {
        prefix += ' [ ]';
      }
      final content = _listItemContent(_asMaps(item['children']));
      final contentLines = content.split('\n');
      lines.add('$prefix ${contentLines.first}');
      for (var i = 1; i < contentLines.length; i++) {
        lines.add('  ${contentLines[i]}');
      }
    }
    return lines.join('\n');
  }

  String _listItemContent(List<Map<String, dynamic>> children) {
    final parts = <String>[];
    for (final child in children) {
      final t = child['type'];
      if (NodeType.inlineTypes.contains(t)) {
        parts.add(_inlineNode(child));
      } else if (t == NodeType.paragraph) {
        parts.add(_inline(_asMaps(child['children'])));
      } else if (t == NodeType.list) {
        parts.add('\n${_blockList(child)}');
      } else {
        final rendered = _renderBlock(child);
        if (rendered != null && rendered.isNotEmpty) {
          parts.add('\n\n$rendered');
        }
      }
    }
    return parts.join();
  }

  String _blockTable(Map<String, dynamic> node) {
    final head = (node['head'] as Map<String, dynamic>?) ?? const {};
    final body = (node['body'] as Map<String, dynamic>?) ?? const {};
    final lines = <String>[];

    final headRows = _asMaps(head['rows']);
    if (headRows.isNotEmpty) {
      final cells = _asMaps(headRows.first['cells']);
      lines.add(
        '| ${cells.map((c) => _inline(_asMaps(c['children']))).join(' | ')} |',
      );
      lines.add(
        '| ${cells.map((c) => _alignSep(c['align'] as String?)).join(' | ')} |',
      );
    }

    for (final row in _asMaps(body['rows'])) {
      final cells = _asMaps(row['cells']);
      lines.add(
        '| ${cells.map((c) => _inline(_asMaps(c['children']))).join(' | ')} |',
      );
    }

    return lines.join('\n');
  }

  String _blockDivider(Map<String, dynamic> _) => '---';

  String _blockHtmlBlock(Map<String, dynamic> node) {
    final value = (node['value'] as String?) ?? '';
    var i = value.length;
    while (i > 0 && value[i - 1] == '\n') {
      i--;
    }
    return value.substring(0, i);
  }

  String _blockWidget(Map<String, dynamic> node) {
    final widgetName = (node['widget'] as String?) ?? '';
    final factory = registry.get(widgetName);
    if (factory != null) {
      return factory().toMarkdown(node, _renderBlockChildren);
    }
    return _blockWidgetGeneric(node);
  }

  String _blockWidgetGeneric(Map<String, dynamic> node) {
    final widgetName = (node['widget'] as String?) ?? 'unknown';
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    final propStr = formatProps(props);

    final parts = <String>[':::$widgetName${propStr.isEmpty ? '' : ' $propStr'}', ''];
    final slots = (node['slots'] as Map<String, dynamic>?) ?? const {};
    for (final entry in slots.entries) {
      final slotName = entry.key;
      final slotChildren = _asMaps(entry.value);
      if (slotName != 'default') {
        parts.addAll(['# $slotName', '']);
      }
      final rendered = _renderBlockChildren(slotChildren);
      if (rendered.isNotEmpty) parts.addAll([rendered, '']);
    }
    parts.add(':::');
    return parts.join('\n');
  }

  String _blockFootnoteDef(Map<String, dynamic> node) {
    final body = _renderBlockChildren(_asMaps(node['children']));
    final label = (node['label'] as String?) ?? '';
    if (body.isEmpty) return '[^$label]:';
    final lines = body.split('\n');
    final out = <String>['[^$label]: ${lines.first}'];
    for (var i = 1; i < lines.length; i++) {
      out.add(lines[i].isEmpty ? '' : '    ${lines[i]}');
    }
    return out.join('\n');
  }

  // ── Inline ──────────────────────────────────────────────────────────────
  String _inline(List<Map<String, dynamic>> children) =>
      children.map(_inlineNode).join();

  String _inlineNode(Map<String, dynamic> node) {
    switch (node['type']) {
      case NodeType.text:
        return (node['value'] as String?) ?? '';
      case NodeType.bold:
        return '**${_inline(_asMaps(node['children']))}**';
      case NodeType.italic:
        return '*${_inline(_asMaps(node['children']))}*';
      case NodeType.boldItalic:
        return '***${_inline(_asMaps(node['children']))}***';
      case NodeType.codeInline:
        final lang = node['language'] as String?;
        final value = (node['value'] as String?) ?? '';
        if (lang != null && lang.isNotEmpty) return '`$lang:$value`';
        return '`$value`';
      case NodeType.strikethrough:
        return '~~${_inline(_asMaps(node['children']))}~~';
      case NodeType.underline:
        return '__${_inline(_asMaps(node['children']))}__';
      case NodeType.softbreak:
        return '\n';
      case NodeType.hardbreak:
        return '  \n';
      case NodeType.link:
        final href = (node['href'] as String?) ?? '';
        final title = node['title'] as String?;
        final text = _inline(_asMaps(node['children']));
        if (title != null && title.isNotEmpty) return '[$text]($href "$title")';
        return '[$text]($href)';
      case NodeType.inlineImage:
      case NodeType.image:
        return _imageMd(
          (node['src'] as String?) ?? '',
          (node['alt'] as String?) ?? '',
          node['title'] as String?,
        );
      case NodeType.footnoteRef:
        return '[^${node['label'] ?? ''}]';
      default:
        return '';
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _asMaps(Object? v) {
    if (v is List) return v.cast<Map<String, dynamic>>();
    return const [];
  }
}

// ─── Module-level helpers ────────────────────────────────────────────────────
String _imageMd(String src, String alt, String? title) {
  if (title != null && title.isNotEmpty) return '![$alt]($src "$title")';
  return '![$alt]($src)';
}

String _alignSep(String? align) {
  switch (align) {
    case 'left':
      return ':---';
    case 'center':
      return ':---:';
    case 'right':
      return '---:';
    default:
      return '---';
  }
}

String _formatHighlight(List<int> lines) {
  if (lines.isEmpty) return '';
  final sorted = lines.toSet().toList()..sort();
  final out = <String>[];
  var s = sorted.first;
  var e = sorted.first;
  for (var i = 1; i < sorted.length; i++) {
    final x = sorted[i];
    if (x == e + 1) {
      e = x;
    } else {
      out.add(s == e ? '$s' : '$s-$e');
      s = e = x;
    }
  }
  out.add(s == e ? '$s' : '$s-$e');
  return out.join(',');
}

/// Format a typed props map back into `key="val"` markdown syntax. Used by
/// the renderer for the generic widget form and by individual widget
/// overrides so they share one quoting policy.
String formatProps(Map<String, dynamic> props) {
  final tokens = <String>[];
  for (final entry in props.entries) {
    final v = entry.value;
    if (v == null) continue;
    if (v == true) {
      tokens.add(entry.key);
      continue;
    }
    if (v == false) {
      tokens.add('${entry.key}=false');
      continue;
    }
    final s = v.toString();
    final needsQuote = s.contains(RegExp(r'\s')) ||
        s.contains('"') ||
        s.contains("'") ||
        s.contains('=');
    if (needsQuote) {
      tokens.add('${entry.key}="$s"');
    } else {
      tokens.add('${entry.key}=$s');
    }
  }
  return tokens.join(' ');
}
