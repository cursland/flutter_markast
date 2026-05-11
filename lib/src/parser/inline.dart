/// `InlineBuilder` — walks a list of `md.Node` children (the inline content
/// of a paragraph, heading, list item, table cell, etc.) and produces the
/// inline portion of the markast AST.
///
/// Mirrors `markast.parser.inline.InlineBuilder` for everything that
/// influences the produced JSON.
library;

import 'package:markdown/markdown.dart' as md;

import '../ast/factory.dart' as f;
import '../ast/node_types.dart';

/// Language identifiers accepted as a prefix in inline code (e.g. `python:code`).
/// Anything not in this set falls through as plain inline code without a
/// language tag. Mirrors `_KNOWN_LANGUAGES` in the Python inline builder.
const Set<String> _knownLanguages = {
  // Web
  'html', 'css', 'javascript', 'js', 'typescript', 'ts',
  'jsx', 'tsx', 'vue', 'svelte', 'astro',
  // General purpose / backend
  'python', 'py', 'ruby', 'rb', 'php', 'perl', 'lua',
  'java', 'kotlin', 'scala', 'groovy',
  'swift', 'objc',
  'go', 'rust', 'zig', 'nim', 'crystal',
  'c', 'cpp', 'csharp', 'cs', 'fsharp', 'fs',
  'dart', 'r',
  // Shell / scripting
  'bash', 'sh', 'zsh', 'fish', 'powershell', 'ps1', 'bat',
  // Data / config
  'json', 'yaml', 'yml', 'toml', 'xml', 'csv', 'ini',
  // Query / API
  'sql', 'graphql', 'gql',
  // Markup / docs
  'markdown', 'md', 'latex', 'tex', 'rst',
  // Build / infra
  'dockerfile', 'docker', 'makefile', 'cmake',
  'nginx', 'apache', 'terraform',
  // Other languages
  'haskell', 'ocaml', 'erlang', 'elixir', 'clojure',
  'julia', 'matlab', 'fortran',
  // Misc
  'diff', 'patch', 'proto', 'regex',
  'asm', 'wasm',
  'text', 'plain',
  'solidity',
};

final RegExp _langPrefixRe = RegExp(r'^([a-z][a-z0-9+#\-]*):(.*)$', dotAll: true);

({String? language, String value}) _splitLang(String content) {
  final m = _langPrefixRe.firstMatch(content);
  if (m != null && _knownLanguages.contains(m.group(1))) {
    return (language: m.group(1), value: m.group(2)!);
  }
  return (language: null, value: content);
}

class InlineBuilder {
  /// Convert a list of inline `md.Node`s into a list of markast inline AST
  /// nodes.
  List<Map<String, dynamic>> build(List<md.Node>? nodes) {
    if (nodes == null) return [];
    final out = <Map<String, dynamic>>[];
    for (final n in nodes) {
      _emit(out, n);
    }
    return _dropSoftbreakNextToHardbreak(_mergeAdjacentText(out));
  }

  void _emit(List<Map<String, dynamic>> out, md.Node n) {
    if (n is md.Text) {
      // Text content may contain literal `\n` (real newlines → softbreaks),
      // and literal two-char `\n` sequences (backslash-n → hardbreaks). Split
      // accordingly. Empty fragments are dropped.
      _emitTextSegments(out, n.text);
      return;
    }
    if (n is! md.Element) return;

    switch (n.tag) {
      case 'strong':
        final built = build(n.children);
        if (built.length == 1 && built.first['type'] == NodeType.italic) {
          out.add(f.boldItalic(
              (built.first['children'] as List).cast<Map<String, dynamic>>()));
        } else {
          out.add(f.bold(built));
        }
        return;
      case 'em':
        final built = build(n.children);
        if (built.length == 1 && built.first['type'] == NodeType.bold) {
          out.add(f.boldItalic(
              (built.first['children'] as List).cast<Map<String, dynamic>>()));
        } else {
          out.add(f.italic(built));
        }
        return;
      case 'code':
        final raw = _plainText(n);
        final split = _splitLang(raw);
        out.add(f.codeInline(split.value, language: split.language));
        return;
      case 'a':
        // Could be: a regular link, an autolink, OR the back-ref anchor that
        // package:markdown injects at the end of every footnote definition
        // (class="footnote-backref"). We drop the back-ref AND the
        // synthetic " " text node that the package always inserts ahead of
        // it, so the produced AST matches what the Python parser emits.
        if (n.attributes['class'] == 'footnote-backref') {
          if (out.isNotEmpty && out.last['type'] == NodeType.text) {
            final v = (out.last['value'] as String?) ?? '';
            if (v.endsWith(' ')) {
              if (v.length == 1) {
                out.removeLast();
              } else {
                out[out.length - 1] = f.text(v.substring(0, v.length - 1));
              }
            }
          }
          return;
        }
        final href = n.attributes['href'] ?? '';
        final title = n.attributes['title'];
        out.add(f.link(href, build(n.children), title));
        return;
      case 'del':
      case 's':
        out.add(f.strikethrough(build(n.children)));
        return;
      case 'u':
        out.add(f.underline(build(n.children)));
        return;
      case 'img':
        out.add(f.inlineImage(
          n.attributes['src'] ?? '',
          n.attributes['alt'] ?? '',
          n.attributes['title'],
        ));
        return;
      case 'br':
        out.add(f.hardbreak());
        return;
      case 'sup':
        // Footnote reference: <sup class="footnote-ref"><a href="#fn-X"
        // id="fnref-X">N</a></sup>. We recover the label from the inner
        // anchor's href, then emit a footnote_ref node.
        if (n.attributes['class'] == 'footnote-ref') {
          final label = _footnoteLabelFromSup(n);
          if (label != null) {
            out.add(f.footnoteRef(label));
            return;
          }
        }
        // Unknown <sup>; fall through to plain text projection.
        out.add(f.text(_plainText(n)));
        return;
      default:
        // Any other inline element (inline HTML, unhandled extensions) is
        // projected to its plain text content. Matches the Python builder's
        // handling of `html_inline`.
        final text = _plainText(n);
        if (text.isNotEmpty) out.add(f.text(text));
    }
  }

  String? _footnoteLabelFromSup(md.Element sup) {
    final children = sup.children;
    if (children == null) return null;
    for (final c in children) {
      if (c is md.Element && c.tag == 'a') {
        final href = c.attributes['href'] ?? '';
        if (href.startsWith('#fn-')) {
          return Uri.decodeComponent(href.substring(4));
        }
      }
    }
    return null;
  }

  String _plainText(md.Node n) {
    if (n is md.Text) return n.text;
    if (n is md.Element) {
      return (n.children ?? const <md.Node>[]).map(_plainText).join();
    }
    return '';
  }

  /// Emit one or more `text`/`softbreak`/`hardbreak` nodes for a raw text
  /// segment. Recognises real `\n` (softbreak) and the two-char literal
  /// `\` + `n` (hardbreak), matching the Python parser's behaviour.
  void _emitTextSegments(List<Map<String, dynamic>> out, String text) {
    if (text.isEmpty) return;

    final buf = StringBuffer();
    var i = 0;
    final n = text.length;
    while (i < n) {
      final ch = text.codeUnitAt(i);
      // Literal "\n" (backslash + n) → hardbreak, possibly repeated.
      if (ch == 0x5C /* \ */ && i + 1 < n && text.codeUnitAt(i + 1) == 0x6E) {
        if (buf.isNotEmpty) {
          out.add(f.text(buf.toString()));
          buf.clear();
        }
        while (i + 1 < n &&
            text.codeUnitAt(i) == 0x5C &&
            text.codeUnitAt(i + 1) == 0x6E) {
          out.add(f.hardbreak());
          i += 2;
        }
        continue;
      }
      // Real `\n` → softbreak.
      if (ch == 0x0A) {
        if (buf.isNotEmpty) {
          out.add(f.text(buf.toString()));
          buf.clear();
        }
        out.add(f.softbreak());
        i += 1;
        continue;
      }
      buf.writeCharCode(ch);
      i += 1;
    }
    if (buf.isNotEmpty) out.add(f.text(buf.toString()));
  }

  /// Merge adjacent text spans into one. Mirrors `_merge_adjacent_text`.
  List<Map<String, dynamic>> _mergeAdjacentText(
      List<Map<String, dynamic>> nodes) {
    final out = <Map<String, dynamic>>[];
    for (final node in nodes) {
      if (out.isNotEmpty &&
          node['type'] == NodeType.text &&
          out.last['type'] == NodeType.text) {
        out[out.length - 1] = f.text(
          (out.last['value'] as String) + (node['value'] as String),
        );
      } else {
        out.add(node);
      }
    }
    return out;
  }

  /// Drop softbreaks that sit immediately before or after a hardbreak.
  /// Mirrors `_drop_softbreak_next_to_hardbreak`.
  List<Map<String, dynamic>> _dropSoftbreakNextToHardbreak(
      List<Map<String, dynamic>> nodes) {
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node['type'] == NodeType.softbreak) {
        final prevHard =
            out.isNotEmpty && out.last['type'] == NodeType.hardbreak;
        final nextHard = i + 1 < nodes.length &&
            nodes[i + 1]['type'] == NodeType.hardbreak;
        if (prevHard || nextHard) continue;
      }
      out.add(node);
    }
    return out;
  }
}
