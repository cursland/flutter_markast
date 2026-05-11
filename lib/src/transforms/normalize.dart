/// `NormalizeText` — merge adjacent `text` nodes and drop empties.
///
/// Mirrors `markast.transforms.normalize`. Cleans up the inline streams left
/// over by the parser when it splits text on softbreaks/hardbreaks.
library;

import '../ast/factory.dart' as f;
import '../ast/node_types.dart';
import '../config.dart';
import 'transform.dart';

class NormalizeText extends Transform {
  const NormalizeText();

  @override
  String get name => 'normalize';

  @override
  Map<String, dynamic> apply(Map<String, dynamic> doc, ParserConfig config) {
    _walk(doc);
    return doc;
  }

  void _walk(Map<String, dynamic> node) {
    final children = node['children'];
    if (children is List) {
      final normalised =
          _normaliseChildren(children.cast<Map<String, dynamic>>());
      node['children'] = normalised;
      for (final c in normalised) {
        _walk(c);
      }
    }

    final slots = node['slots'];
    if (slots is Map) {
      for (final entry in slots.entries.toList()) {
        final v = entry.value;
        if (v is List) {
          final normalised = _normaliseChildren(v.cast<Map<String, dynamic>>());
          slots[entry.key] = normalised;
          for (final c in normalised) {
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

  List<Map<String, dynamic>> _normaliseChildren(
      List<Map<String, dynamic>> children) {
    final out = <Map<String, dynamic>>[];
    for (final c in children) {
      if (c['type'] == NodeType.text) {
        final value = (c['value'] as String?) ?? '';
        if (value.isEmpty) continue;
        if (out.isNotEmpty && out.last['type'] == NodeType.text) {
          out[out.length - 1] = f.text(
            (out.last['value'] as String) + value,
          );
          continue;
        }
      }
      out.add(c);
    }
    return out;
  }
}
