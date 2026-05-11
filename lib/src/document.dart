/// `Document` — a thin façade over the AST root map exposing common
/// operations as methods. Mirrors `markast.document.Document`. We intentionally
/// omit the `toMarkdown`/`toHtml` helpers — on the Flutter side the renderer
/// turns the AST into native widgets, so those Python conveniences have no
/// counterpart here.
library;

import 'dart:convert' show JsonEncoder, jsonDecode;

import 'ast/walker.dart' as walker;
import 'ast/utils.dart' as ast_utils;

class Document {
  Document(Map<String, dynamic> root) : _root = _validateRoot(root);

  static Map<String, dynamic> _validateRoot(Map<String, dynamic> root) {
    if (root['type'] != 'document') {
      throw ArgumentError("Document requires a Map with type='document'");
    }
    return root;
  }

  final Map<String, dynamic> _root;

  /// The underlying AST map (live reference, not a copy).
  Map<String, dynamic> get root => _root;

  List<Map<String, dynamic>> get children =>
      ((_root['children'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  List<Map<String, dynamic>> get warnings =>
      ((_root['warnings'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> get meta {
    final v = _root['meta'];
    if (v is Map<String, dynamic>) return v;
    final fresh = <String, dynamic>{};
    _root['meta'] = fresh;
    return fresh;
  }

  String get version => (_root['version'] as String?) ?? '';

  /// True if any diagnostic has severity `error`.
  bool get hasErrors =>
      warnings.any((w) => w['severity'] == 'error');

  // ── Serialisation ───────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => _root;

  /// Serialise to a JSON string. [indent] controls pretty-printing; pass
  /// `null` for compact output. Matches the Python `to_json(indent=2)`
  /// default.
  String toJson({int? indent = 2}) {
    final encoder = indent == null
        ? const JsonEncoder()
        : JsonEncoder.withIndent(' ' * indent);
    return encoder.convert(_root);
  }

  // ── Traversal helpers ───────────────────────────────────────────────────
  Iterable<Map<String, dynamic>> walkAll() => walker.walk(_root);

  Map<String, dynamic>? find(Object type) => walker.find(_root, type);

  List<Map<String, dynamic>> findAll(Object type) =>
      walker.findAll(_root, type);

  Map<String, int> count() => ast_utils.countNodes(_root);

  bool hasWarnings([String code = '']) =>
      ast_utils.hasWarnings(_root, code);

  // ── Misc ────────────────────────────────────────────────────────────────
  /// Reconstruct a [Document] from a JSON string previously produced by
  /// [toJson] (or by the Python `Document.to_json`).
  static Document fromJson(String jsonStr) {
    final decoded = jsonDecode(jsonStr);
    if (decoded is! Map<String, dynamic>) {
      throw ArgumentError('Expected a JSON object at the root.');
    }
    return Document(decoded);
  }

  @override
  String toString() =>
      "Document(version='$version', children=${children.length}, warnings=${warnings.length})";
}
