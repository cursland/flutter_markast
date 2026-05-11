/// `Linkify` — turn bare URLs in plain-text spans into `link` nodes.
///
/// Mirrors `markast.transforms.linkify`. Opt-in (some content authors prefer
/// literal URLs in code-like contexts).
library;

import '../ast/factory.dart' as f;
import '../ast/node_types.dart';
import '../config.dart';
import 'transform.dart';

final RegExp _urlRe = RegExp(
  r'''\b(?<url>https?://[^\s<>'")]+)''',
  caseSensitive: false,
);

class Linkify extends Transform {
  const Linkify();

  @override
  String get name => 'linkify';

  @override
  Map<String, dynamic> apply(Map<String, dynamic> doc, ParserConfig config) {
    _walk(doc);
    return doc;
  }

  void _walk(Map<String, dynamic> node) {
    if (node['type'] == NodeType.link) return; // never linkify inside a link.

    final children = node['children'];
    if (children is List) {
      final linkified =
          _linkifyInline(children.cast<Map<String, dynamic>>());
      node['children'] = linkified;
      for (final c in linkified) {
        _walk(c);
      }
    }

    final slots = node['slots'];
    if (slots is Map) {
      for (final entry in slots.entries.toList()) {
        final v = entry.value;
        if (v is List) {
          final linkified = _linkifyInline(v.cast<Map<String, dynamic>>());
          slots[entry.key] = linkified;
          for (final c in linkified) {
            _walk(c);
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

  List<Map<String, dynamic>> _linkifyInline(
      List<Map<String, dynamic>> children) {
    final out = <Map<String, dynamic>>[];
    for (final c in children) {
      if (c['type'] != NodeType.text) {
        out.add(c);
        continue;
      }
      final text = (c['value'] as String?) ?? '';
      if (text.isEmpty) {
        out.add(c);
        continue;
      }
      var last = 0;
      var any = false;
      for (final m in _urlRe.allMatches(text)) {
        any = true;
        if (m.start > last) out.add(f.text(text.substring(last, m.start)));
        final url = m.namedGroup('url')!;
        out.add(f.link(url, [f.text(url)]));
        last = m.end;
      }
      if (any) {
        if (last < text.length) out.add(f.text(text.substring(last)));
      } else {
        out.add(c);
      }
    }
    return out;
  }
}
