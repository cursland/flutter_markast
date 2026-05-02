import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class FootnoteDefNodeRenderer extends BlockRenderer {
  const FootnoteDefNodeRenderer();

  @override
  String get type => NodeType.footnoteDef;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final label = (node['label'] as String?) ?? '?';
    final theme = ctx.theme;
    final children = ctx.markast.buildMixedBody(
      ctx,
      node['children'] as List<dynamic>?,
      ctx.effectiveBodyStyle,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text('[$label]', style: theme.footnoteDefLabelTextStyle),
        ),
        SizedBox(width: theme.footnoteDefSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}
