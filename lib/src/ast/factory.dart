/// Factory helpers that build well-formed markast AST nodes.
///
/// Every node is a plain `Map<String, dynamic>` — the same JSON shape produced
/// by the Python `markast` parser, so the renderer side stays interchangeable.
///
/// These helpers exist because they give a single source of truth for the
/// exact fields a node carries and they omit `null`/falsy fields where
/// appropriate, matching the Python output byte for byte.
library;

import 'node_types.dart';

/// Internal version stamp of the produced AST. Bump only on breaking shape
/// changes. Mirrors `AST_VERSION` in Python `markast.ast.factory`.
const String astVersion = '1.0';

// ─── Document / root ─────────────────────────────────────────────────────────
Map<String, dynamic> document(
  List<Map<String, dynamic>> children, [
  List<Map<String, dynamic>>? warnings,
  Map<String, dynamic>? meta,
]) {
  final node = <String, dynamic>{
    'type': NodeType.document,
    'version': astVersion,
    'warnings': warnings ?? const <Map<String, dynamic>>[],
    'children': children,
  };
  if (meta != null && meta.isNotEmpty) node['meta'] = meta;
  return node;
}

// ─── Block nodes ─────────────────────────────────────────────────────────────
Map<String, dynamic> heading(int level, List<Map<String, dynamic>> children,
    {String? id}) {
  if (level < 1 || level > 6) {
    throw ArgumentError('heading level must be 1..6, got $level');
  }
  final node = <String, dynamic>{
    'type': NodeType.heading,
    'level': level,
    'children': children,
  };
  if (id != null) node['id'] = id;
  return node;
}

Map<String, dynamic> paragraph(List<Map<String, dynamic>> children) =>
    {'type': NodeType.paragraph, 'children': children};

Map<String, dynamic> blockquote(List<Map<String, dynamic>> children) =>
    {'type': NodeType.blockquote, 'children': children};

Map<String, dynamic> codeBlock(
  String language,
  String value, {
  String? filename,
  List<int>? highlightLines,
}) {
  final node = <String, dynamic>{
    'type': NodeType.codeBlock,
    'language': language,
    'value': value,
  };
  if (filename != null && filename.isNotEmpty) node['filename'] = filename;
  if (highlightLines != null && highlightLines.isNotEmpty) {
    node['highlight_lines'] = List<int>.from(highlightLines);
  }
  return node;
}

Map<String, dynamic> image(String src, [String alt = '', String? title]) =>
    {'type': NodeType.image, 'src': src, 'alt': alt, 'title': title};

Map<String, dynamic> video(String src,
    {String? poster, Map<String, dynamic>? extra}) {
  final node = <String, dynamic>{'type': NodeType.video, 'src': src};
  if (poster != null) node['poster'] = poster;
  if (extra != null) node.addAll(extra);
  return node;
}

Map<String, dynamic> listNode(
  bool ordered,
  List<Map<String, dynamic>> children, [
  int? start,
]) {
  final node = <String, dynamic>{
    'type': NodeType.list,
    'ordered': ordered,
    'children': children,
  };
  if (ordered) node['start'] = start ?? 1;
  return node;
}

Map<String, dynamic> listItem(List<Map<String, dynamic>> children,
    {bool? checked}) {
  final node = <String, dynamic>{
    'type': NodeType.listItem,
    'children': children,
  };
  if (checked != null) node['checked'] = checked;
  return node;
}

Map<String, dynamic> table(
        Map<String, dynamic> head, Map<String, dynamic> body) =>
    {'type': NodeType.table, 'head': head, 'body': body};

Map<String, dynamic> tableHead(List<Map<String, dynamic>> rows) =>
    {'type': NodeType.tableHead, 'rows': rows};

Map<String, dynamic> tableBody(List<Map<String, dynamic>> rows) =>
    {'type': NodeType.tableBody, 'rows': rows};

Map<String, dynamic> tableRow(List<Map<String, dynamic>> cells) =>
    {'type': NodeType.tableRow, 'cells': cells};

Map<String, dynamic> tableCell(
  List<Map<String, dynamic>> children, {
  String? align,
  bool isHeader = false,
}) =>
    {
      'type': NodeType.tableCell,
      'is_header': isHeader,
      'align': align,
      'children': children,
    };

Map<String, dynamic> divider() => {'type': NodeType.divider};

Map<String, dynamic> widgetNode(
  String name,
  Map<String, dynamic> props,
  Map<String, List<Map<String, dynamic>>> slots,
) {
  // Guarantee "default" slot exists, first, matching Python ordering.
  final ordered = <String, List<Map<String, dynamic>>>{
    'default': slots['default'] ?? const <Map<String, dynamic>>[],
  };
  for (final entry in slots.entries) {
    if (entry.key != 'default') ordered[entry.key] = entry.value;
  }
  return {
    'type': NodeType.widget,
    'widget': name,
    'props': props,
    'slots': ordered,
  };
}

Map<String, dynamic> htmlBlock(String value) =>
    {'type': NodeType.htmlBlock, 'value': value};

Map<String, dynamic> footnoteDef(
        String label, List<Map<String, dynamic>> children) =>
    {'type': NodeType.footnoteDef, 'label': label, 'children': children};

// ─── Inline nodes ────────────────────────────────────────────────────────────
Map<String, dynamic> text(String value) =>
    {'type': NodeType.text, 'value': value};

Map<String, dynamic> bold(List<Map<String, dynamic>> children) =>
    {'type': NodeType.bold, 'children': children};

Map<String, dynamic> italic(List<Map<String, dynamic>> children) =>
    {'type': NodeType.italic, 'children': children};

Map<String, dynamic> boldItalic(List<Map<String, dynamic>> children) =>
    {'type': NodeType.boldItalic, 'children': children};

Map<String, dynamic> codeInline(String value, {String? language}) {
  final node = <String, dynamic>{'type': NodeType.codeInline, 'value': value};
  if (language != null && language.isNotEmpty) node['language'] = language;
  return node;
}

Map<String, dynamic> link(
  String href,
  List<Map<String, dynamic>> children, [
  String? title,
]) =>
    {
      'type': NodeType.link,
      'href': href,
      'title': title,
      'children': children,
    };

Map<String, dynamic> strikethrough(List<Map<String, dynamic>> children) =>
    {'type': NodeType.strikethrough, 'children': children};

Map<String, dynamic> underline(List<Map<String, dynamic>> children) =>
    {'type': NodeType.underline, 'children': children};

Map<String, dynamic> inlineImage(String src, [String alt = '', String? title]) =>
    {'type': NodeType.inlineImage, 'src': src, 'alt': alt, 'title': title};

Map<String, dynamic> softbreak() => {'type': NodeType.softbreak};

Map<String, dynamic> hardbreak() => {'type': NodeType.hardbreak};

Map<String, dynamic> footnoteRef(String label) =>
    {'type': NodeType.footnoteRef, 'label': label};
