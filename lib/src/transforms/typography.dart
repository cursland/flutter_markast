/// `SmartTypography` — light-touch typographic substitutions on plain text
/// spans. Code spans, links, and HTML pass through untouched.
///
/// Mirrors `markast.transforms.typography`.
library;

import '../ast/node_types.dart';
import '../config.dart';
import 'transform.dart';

final List<(RegExp, String)> _rules = [
  (RegExp(r'---'), '—'),
  (RegExp(r'--'), '–'),
  (RegExp(r'\.\.\.'), '…'),
];

String _quotes(String s) {
  final buf = StringBuffer();
  var inDouble = false;
  var inSingle = false;
  for (var i = 0; i < s.length; i++) {
    final ch = s[i];
    final prev = i > 0 ? s[i - 1] : ' ';
    if (ch == '"') {
      if (!inDouble && (RegExp(r'\s').hasMatch(prev) || '([{'.contains(prev))) {
        buf.write('“');
        inDouble = true;
      } else {
        buf.write('”');
        inDouble = false;
      }
    } else if (ch == "'") {
      if (!inSingle && (RegExp(r'\s').hasMatch(prev) || '([{'.contains(prev))) {
        buf.write('‘');
        inSingle = true;
      } else {
        buf.write('’');
        inSingle = false;
      }
    } else {
      buf.write(ch);
    }
  }
  return buf.toString();
}

class SmartTypography extends Transform {
  const SmartTypography();

  @override
  String get name => 'smarttypography';

  @override
  Map<String, dynamic> apply(Map<String, dynamic> doc, ParserConfig config) {
    _walk(doc);
    return doc;
  }

  void _walk(Map<String, dynamic> node) {
    final t = node['type'];
    if (t == NodeType.codeInline || t == NodeType.codeBlock || t == NodeType.htmlBlock) {
      return;
    }
    if (t == NodeType.text) {
      var v = (node['value'] as String?) ?? '';
      for (final r in _rules) {
        v = v.replaceAllMapped(r.$1, (_) => r.$2);
      }
      v = _quotes(v);
      node['value'] = v;
      return;
    }

    final children = node['children'];
    if (children is List) {
      for (final c in children) {
        if (c is Map<String, dynamic>) _walk(c);
      }
    }
    final slots = node['slots'];
    if (slots is Map) {
      for (final v in slots.values) {
        if (v is List) {
          for (final c in v) {
            if (c is Map<String, dynamic>) _walk(c);
          }
        }
      }
    }
    for (final k in const ['head', 'body']) {
      final sub = node[k];
      if (sub is Map<String, dynamic>) _walk(sub);
    }
    for (final k in const ['rows', 'cells']) {
      final sub = node[k];
      if (sub is List) {
        for (final c in sub) {
          if (c is Map<String, dynamic>) _walk(c);
        }
      }
    }
  }
}
