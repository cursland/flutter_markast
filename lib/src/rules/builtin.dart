/// Built-in W001–W009 validation rules. Mirrors `markast.rules.builtin`.
library;

import '../ast/node_types.dart';
import 'codes.dart';
import 'rule.dart';

class BuiltinRules extends Rule {
  BuiltinRules();

  @override
  String get name => 'builtin';

  @override
  List<Diagnostic>? checkHeadingChildren(
      List<Map<String, dynamic>> children, int level) {
    final out = <Diagnostic>[];
    for (final child in children) {
      final t = child['type'];
      if (t == NodeType.inlineImage) {
        out.add(Diagnostic(
          code: wImageInHeading,
          message:
              'Image inside h$level heading — alt text used as content.',
          context:
              "src=${_pyRepr(child['src'] ?? '')}, alt=${_pyRepr(child['alt'] ?? '')}",
        ));
      } else if (!NodeType.headingAllowedInline.contains(t)) {
        out.add(Diagnostic(
          code: wBlockInInline,
          message:
              "Node type '$t' is not valid inside a heading — converted to plain text.",
          context: 'level=$level',
        ));
      }
    }
    return out.isEmpty ? null : out;
  }

  @override
  List<Diagnostic>? checkTableCellChildren(
      List<Map<String, dynamic>> children, bool isHeader) {
    final out = <Diagnostic>[];
    for (final child in children) {
      final t = child['type'];
      if (t == NodeType.inlineImage) {
        out.add(Diagnostic(
          code: wImageInTable,
          message: 'Image inside table cell — alt text used as content.',
          context: 'src=${_pyRepr(child['src'] ?? '')}',
        ));
      } else if (!NodeType.tableCellAllowedInline.contains(t)) {
        out.add(Diagnostic(
          code: wBlockInInline,
          message:
              "Node type '$t' is not valid inside a table cell — converted to plain text.",
        ));
      }
    }
    return out.isEmpty ? null : out;
  }

  @override
  List<Diagnostic>? checkWidget(
    String widgetName,
    Map<String, dynamic> props,
    Map<String, List<Map<String, dynamic>>> slots,
    bool registered,
  ) {
    if (registered) return null;
    return [
      Diagnostic(
        code: wUnknownWidget,
        message:
            "Widget '$widgetName' is not registered — rendered as a generic widget node.",
        context: 'widget=$widgetName',
      ),
    ];
  }

  @override
  List<Diagnostic>? checkHtmlBlock(String value) {
    final flat = value.replaceAll('\n', ' ');
    final snippet =
        value.length > 60 ? '${flat.substring(0, 60)}...' : flat;
    return [
      Diagnostic(
        code: wHtmlBlock,
        message: 'Raw HTML block found — passed through as html_block node.',
        context: snippet.trim(),
        severity: Severity.info,
      ),
    ];
  }

  @override
  List<Diagnostic>? checkFootnoteRef(
      String label, Set<String> definedLabels) {
    if (definedLabels.contains(label)) return null;
    return [
      Diagnostic(
        code: wDanglingFootnote,
        message: 'Footnote reference [^$label] has no matching definition.',
        context: 'label=$label',
      ),
    ];
  }
}

/// Mimic Python's `repr()` of a short string (we only need it for the W001/W006
/// `context` field). Wraps in single quotes and escapes single quotes inside.
String _pyRepr(Object value) {
  final s = value.toString();
  // Python's repr prefers single quotes unless the string contains a single
  // quote but not a double quote. We follow the same heuristic.
  final hasSingle = s.contains("'");
  final hasDouble = s.contains('"');
  if (hasSingle && !hasDouble) {
    return '"${s.replaceAll(r"\", r"\\").replaceAll('"', r'\"')}"';
  }
  return "'${s.replaceAll(r"\", r"\\").replaceAll("'", r"\'")}'";
}
