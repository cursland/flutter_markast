import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class BlockquoteNodeRenderer extends BlockRenderer {
  const BlockquoteNodeRenderer();

  @override
  String get type => NodeType.blockquote;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final innerStyle =
        ctx.effectiveBodyStyle.merge(ctx.theme.blockquoteTextStyle);
    final innerCtx = ctx.copyWith(bodyStyleOverride: innerStyle);

    final children = ctx.markast.buildMixedBody(
      innerCtx,
      node['children'] as List<dynamic>?,
      innerStyle,
    );

    return Container(
      padding: ctx.theme.blockquotePadding,
      decoration: ctx.theme.blockquoteDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    i == children.length - 1 ? 0 : ctx.theme.blockSpacing * 0.5,
              ),
              child: children[i],
            ),
        ],
      ),
    );
  }
}
