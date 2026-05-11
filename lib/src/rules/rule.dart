/// `Diagnostic`/`Rule`/`Severity` primitives. Mirrors `markast.rules.base`.
library;

class Severity {
  Severity._();
  static const String error = 'error';
  static const String warning = 'warning';
  static const String info = 'info';
}

/// A single diagnostic entry to be attached to `document['warnings']`.
class Diagnostic {
  Diagnostic({
    required this.code,
    required this.message,
    this.context = '',
    this.severity = Severity.warning,
  });

  final String code;
  final String message;
  final String context;
  final String severity;

  /// Serialise to a plain dict for JSON output. Omits `severity` when it is
  /// the default ("warning") so the on-the-wire format matches Python byte
  /// for byte.
  Map<String, dynamic> toDict() {
    final d = <String, dynamic>{
      'code': code,
      'message': message,
      'context': context,
    };
    if (severity != Severity.warning) d['severity'] = severity;
    return d;
  }
}

/// Base class for validation rules.
///
/// The builder calls each registered rule's hooks at well-defined points and
/// appends any returned [Diagnostic]s to the document. Subclasses typically
/// override one of [checkHeadingChildren], [checkTableCellChildren],
/// [checkWidget], [checkHtmlBlock], or [checkFootnoteRef].
class Rule {
  Rule();

  /// Short, unique identifier — used for selective enable/disable.
  String get name => '';

  List<Diagnostic>? checkHeadingChildren(
          List<Map<String, dynamic>> children, int level) =>
      null;

  List<Diagnostic>? checkTableCellChildren(
          List<Map<String, dynamic>> children, bool isHeader) =>
      null;

  List<Diagnostic>? checkWidget(
    String widgetName,
    Map<String, dynamic> props,
    Map<String, List<Map<String, dynamic>>> slots,
    bool registered,
  ) =>
      null;

  List<Diagnostic>? checkHtmlBlock(String value) => null;

  List<Diagnostic>? checkFootnoteRef(String label, Set<String> definedLabels) =>
      null;
}
