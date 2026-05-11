/// Tree walker / visitor for the markast AST.
///
/// Mirrors `markast.ast.walker` on the Python side. The walker is generic over
/// container shapes: `children`, `rows`, `cells`, `slots` (dict of lists), and
/// the single-node `head`/`body` of a table.
library;

const _listChildKeys = ['children', 'rows', 'cells'];
const _dictChildKeys = ['slots'];
const _nodeChildKeys = ['head', 'body'];

Iterable<Map<String, dynamic>> _iterImmediateChildren(
    Map<String, dynamic> node) sync* {
  for (final key in _listChildKeys) {
    final v = node[key];
    if (v is List) {
      for (final c in v) {
        if (c is Map<String, dynamic>) yield c;
      }
    }
  }
  for (final key in _dictChildKeys) {
    final v = node[key];
    if (v is Map) {
      for (final slotChildren in v.values) {
        if (slotChildren is List) {
          for (final c in slotChildren) {
            if (c is Map<String, dynamic>) yield c;
          }
        }
      }
    }
  }
  for (final key in _nodeChildKeys) {
    final v = node[key];
    if (v is Map<String, dynamic>) yield v;
  }
}

/// Yield every node in document order (depth-first, pre-order).
///
/// When [includeRoot] is true (default), [node] itself is yielded first;
/// otherwise only descendants are yielded.
Iterable<Map<String, dynamic>> walk(
  Map<String, dynamic> node, {
  bool includeRoot = true,
}) sync* {
  if (includeRoot) yield node;
  for (final child in _iterImmediateChildren(node)) {
    yield* walk(child);
  }
}

/// Return the first descendant matching [type] (a string or a list of strings).
/// Returns `null` if nothing matches.
Map<String, dynamic>? find(Map<String, dynamic> node, Object type) {
  final types = type is String ? {type} : Set<String>.from(type as Iterable);
  for (final n in walk(node, includeRoot: false)) {
    if (types.contains(n['type'])) return n;
  }
  return null;
}

/// Return every descendant matching [type].
List<Map<String, dynamic>> findAll(Map<String, dynamic> node, Object type) {
  final types = type is String ? {type} : Set<String>.from(type as Iterable);
  return [
    for (final n in walk(node, includeRoot: false))
      if (types.contains(n['type'])) n,
  ];
}

/// Signature for [replace]/[Visitor] handlers.
typedef NodeMapper = Map<String, dynamic>? Function(Map<String, dynamic> node);

/// Walk the tree applying [fn] to every node, replacing each node with the
/// returned value. Return `null` to drop a node from its parent's list.
Map<String, dynamic> replace(
  Map<String, dynamic> node,
  NodeMapper fn, {
  bool inPlace = false,
}) {
  var newRoot = fn(node);
  if (inPlace) {
    newRoot ??= node;
  }
  newRoot ??= node;
  return _rewrite(newRoot, fn, inPlace: inPlace);
}

Map<String, dynamic> _rewrite(
  Map<String, dynamic> node,
  NodeMapper fn, {
  required bool inPlace,
}) {
  final target = inPlace ? node : Map<String, dynamic>.from(node);

  for (final key in _listChildKeys) {
    final v = target[key];
    if (v is List) {
      target[key] = _rewriteList(v.cast<dynamic>(), fn, inPlace: inPlace);
    }
  }

  for (final key in _dictChildKeys) {
    final v = target[key];
    if (v is Map) {
      final newSlots = inPlace
          ? v as Map<String, dynamic>
          : <String, dynamic>{};
      for (final entry in v.entries) {
        final k = entry.key as String;
        final vv = entry.value;
        if (vv is List) {
          newSlots[k] = _rewriteList(vv.cast<dynamic>(), fn, inPlace: inPlace);
        } else {
          newSlots[k] = vv;
        }
      }
      target[key] = newSlots;
    }
  }

  for (final key in _nodeChildKeys) {
    final v = target[key];
    if (v is Map<String, dynamic>) {
      final replaced = fn(v) ?? v;
      target[key] = _rewrite(replaced, fn, inPlace: inPlace);
    }
  }

  return target;
}

List<Map<String, dynamic>> _rewriteList(
  List<dynamic> children,
  NodeMapper fn, {
  required bool inPlace,
}) {
  final out = <Map<String, dynamic>>[];
  for (final child in children) {
    if (child is! Map<String, dynamic>) continue;
    final replaced = fn(child);
    if (replaced == null) continue;
    out.add(_rewrite(replaced, fn, inPlace: inPlace));
  }
  return out;
}

/// Class-based visitor — subclass and override `visit<NodeType>` methods.
///
/// The base [visit] looks up `visit<TypeCamelCase>` via reflection-free
/// dispatch; subclasses register handlers explicitly in [handlers]. Use
/// [run] to traverse a document and collect non-null results.
abstract class Visitor<T> {
  /// Map from node `type` discriminator to handler. Subclasses populate this
  /// in their constructor. Mirrors Python's `visit_<type>` convention.
  Map<String, T? Function(Map<String, dynamic>)> get handlers => const {};

  T? visit(Map<String, dynamic> node) {
    final h = handlers[node['type']];
    if (h == null) return genericVisit(node);
    return h(node);
  }

  /// Called when no specific handler matches. Override to act on every
  /// unmatched node type.
  T? genericVisit(Map<String, dynamic> node) => null;

  /// Visit every node in document order and collect non-null results.
  List<T> run(Map<String, dynamic> root) {
    final out = <T>[];
    for (final n in walk(root)) {
      final r = visit(n);
      if (r != null) out.add(r);
    }
    return out;
  }
}
