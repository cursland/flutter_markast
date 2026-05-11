/// `BuildTOC` — walk the document and build a nested table of contents
/// from headings. Result is stored in `doc['meta']['toc']`. Requires
/// [SlugifyHeadings] to have run first.
///
/// Mirrors `markast.transforms.toc`.
library;

import '../ast/node_types.dart';
import '../ast/utils.dart';
import '../ast/walker.dart';
import '../config.dart';
import 'transform.dart';

class BuildTOC extends Transform {
  const BuildTOC();

  @override
  String get name => 'toc';

  @override
  Map<String, dynamic> apply(Map<String, dynamic> doc, ParserConfig config) {
    final flat = <Map<String, dynamic>>[];
    for (final n in walk(doc)) {
      if (n['type'] != NodeType.heading) continue;
      flat.add({
        'level': n['level'] ?? 1,
        'text': extractText(n),
        'id': n['id'],
        'children': <Map<String, dynamic>>[],
      });
    }

    final meta = (doc['meta'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    meta['toc'] = _nest(flat);
    doc['meta'] = meta;
    return doc;
  }

  List<Map<String, dynamic>> _nest(List<Map<String, dynamic>> items) {
    final root = <Map<String, dynamic>>[];
    // Stack of (level, container).
    final stack = <(int, List<Map<String, dynamic>>)>[(0, root)];

    for (final entry in items) {
      final level = entry['level'] as int;
      while (stack.isNotEmpty && stack.last.$1 >= level) {
        stack.removeLast();
      }
      if (stack.isEmpty) stack.add((0, root));
      stack.last.$2.add(entry);
      stack.add((level, (entry['children'] as List).cast<Map<String, dynamic>>()));
    }
    return root;
  }
}
