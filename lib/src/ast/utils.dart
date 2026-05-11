/// Small utility functions for working with markast AST nodes.
///
/// Every helper is intentionally tiny and stateless — they exist only to
/// spare callers from duplicating the same boilerplate.
library;

import 'node_types.dart';
import 'walker.dart';

/// Best-effort plain-text projection of a node and its descendants.
///
/// Recurses through `children`, `rows`/`cells`, and named widget slots so a
/// widget contributes its slot contents too. Mirrors Python `extract_text`.
String extractText(Map<String, dynamic> node) {
  final hasChildren = node['children'] is List &&
      (node['children'] as List).isNotEmpty;
  if (node.containsKey('value') && !hasChildren) {
    return (node['value'] ?? '').toString();
  }

  final parts = <String>[];

  if (node.containsKey('value')) {
    parts.add((node['value'] ?? '').toString());
  }

  final children = node['children'];
  if (children is List) {
    for (final c in children) {
      if (c is Map<String, dynamic>) parts.add(extractText(c));
    }
  }

  for (final rowContainer in const ['head', 'body']) {
    final cont = node[rowContainer];
    if (cont is Map<String, dynamic>) {
      final rows = cont['rows'];
      if (rows is List) {
        for (final row in rows) {
          if (row is! Map<String, dynamic>) continue;
          final cells = row['cells'];
          if (cells is List) {
            for (final cell in cells) {
              if (cell is Map<String, dynamic>) {
                parts.add(extractText(cell));
                parts.add(' ');
              }
            }
          }
        }
      }
    }
  }

  final slots = node['slots'];
  if (slots is Map) {
    for (final slotChildren in slots.values) {
      if (slotChildren is List) {
        for (final c in slotChildren) {
          if (c is Map<String, dynamic>) parts.add(extractText(c));
        }
      }
    }
  }

  return parts.join().trim();
}

/// Return the canonical `children` list, or `[]` if none.
List<Map<String, dynamic>> childrenOf(Map<String, dynamic> node) {
  final v = node['children'];
  if (v is List) return v.cast<Map<String, dynamic>>();
  return const [];
}

/// Return the slots dict of a widget node (always at least `default`).
Map<String, List<Map<String, dynamic>>> slotsOf(Map<String, dynamic> widget) {
  final v = widget['slots'];
  if (v is! Map) return {'default': const []};
  return {
    for (final entry in v.entries)
      entry.key as String:
          (entry.value as List).cast<Map<String, dynamic>>(),
  };
}

/// Did the document collect any warnings (optionally of a specific [code])?
bool hasWarnings(Map<String, dynamic> doc, [String code = '']) {
  final w = doc['warnings'];
  if (w is! List || w.isEmpty) return false;
  if (code.isEmpty) return true;
  return w.any((d) => d is Map && d['code'] == code);
}

/// Tally how many of each node type appear under [root].
Map<String, int> countNodes(Map<String, dynamic> root) {
  final counts = <String, int>{};
  for (final n in walk(root)) {
    final t = (n['type'] as String?) ?? '<unknown>';
    counts[t] = (counts[t] ?? 0) + 1;
  }
  return counts;
}

bool isBlock(Map<String, dynamic> node) =>
    NodeType.blockTypes.contains(node['type']);

bool isInline(Map<String, dynamic> node) =>
    NodeType.inlineTypes.contains(node['type']);
