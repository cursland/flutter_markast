/// `Transform` and `TransformPipeline` — base classes for AST→AST passes
/// applied after parsing and before serialisation. Mirrors
/// `markast.transforms.base`.
library;

import '../config.dart';

/// Subclass and override [apply] to define a transform.
abstract class Transform {
  const Transform();

  /// Stable identifier — used when looking up the transform from a string.
  String get name => '';

  /// Apply the transform to [doc] and return the (possibly new) document
  /// root. May add entries to `doc['meta']` for downstream code.
  Map<String, dynamic> apply(Map<String, dynamic> doc, ParserConfig config);
}

/// An ordered chain of [Transform] instances.
class TransformPipeline {
  TransformPipeline([List<Transform>? transforms])
      : _transforms = List<Transform>.from(transforms ?? const []);

  final List<Transform> _transforms;

  List<Transform> get transforms => List.unmodifiable(_transforms);

  void append(Transform t) => _transforms.add(t);

  void extend(Iterable<Transform> ts) => _transforms.addAll(ts);

  Map<String, dynamic> run(Map<String, dynamic> doc, ParserConfig config) {
    var result = doc;
    for (final t in _transforms) {
      result = t.apply(result, config);
    }
    return result;
  }

  List<String> names() => [
        for (final t in _transforms)
          t.name.isEmpty ? t.runtimeType.toString() : t.name,
      ];

  int get length => _transforms.length;
}
