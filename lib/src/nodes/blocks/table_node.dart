import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class TableNodeRenderer extends BlockRenderer {
  const TableNodeRenderer();

  @override
  String get type => NodeType.table;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final headRows = _rowsOf(node['head']);
    final bodyRows = _rowsOf(node['body']);
    final theme = ctx.theme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: theme.tableDecoration,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.symmetric(inside: theme.tableInnerBorderSide),
          children: [
            for (final row in headRows) _row(ctx, row, isHeader: true),
            for (final row in bodyRows) _row(ctx, row, isHeader: false),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _rowsOf(dynamic section) {
    if (section is! Map<String, dynamic>) return const [];
    final rows = section['rows'] as List<dynamic>? ?? const [];
    return [for (final r in rows) r as Map<String, dynamic>];
  }

  TableRow _row(
    RenderContext ctx,
    Map<String, dynamic> row, {
    required bool isHeader,
  }) {
    final cells = (row['cells'] as List<dynamic>?) ?? const [];
    return TableRow(
      decoration: isHeader ? ctx.theme.tableHeaderRowDecoration : null,
      children: [
        for (final cell in cells)
          _cell(ctx, cell as Map<String, dynamic>, isHeader: isHeader),
      ],
    );
  }

  Widget _cell(
    RenderContext ctx,
    Map<String, dynamic> cell, {
    required bool isHeader,
  }) {
    final align = cell['align'] as String?;
    final base = isHeader
        ? ctx.theme.tableHeaderTextStyle
        : ctx.theme.tableCellTextStyle;
    final spans = ctx.markast.buildInlines(
      ctx,
      cell['children'] as List<dynamic>?,
      base,
    );
    return Padding(
      padding: ctx.theme.tableCellPadding,
      child: Text.rich(
        TextSpan(style: base, children: spans),
        textAlign: switch (align) {
          'right' => TextAlign.right,
          'center' => TextAlign.center,
          _ => TextAlign.left,
        },
      ),
    );
  }
}
