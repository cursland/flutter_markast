import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class ParagraphNodeRenderer extends BlockRenderer {
  const ParagraphNodeRenderer();

  @override
  String get type => NodeType.paragraph;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final style = ctx.effectiveBodyStyle;
    final spans = ctx.markast.buildInlines(
      ctx,
      node['children'] as List<dynamic>?,
      style,
    );
    return Padding(
      padding: ctx.theme.paragraphPadding,
      child: Text.rich(TextSpan(style: style, children: spans)),
    );
  }
}
