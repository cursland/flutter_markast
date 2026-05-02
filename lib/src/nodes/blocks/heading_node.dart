import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class HeadingNodeRenderer extends BlockRenderer {
  const HeadingNodeRenderer();

  @override
  String get type => NodeType.heading;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final level = (node['level'] as int?) ?? 1;
    final style = ctx.theme.headingStyleFor(level);
    final spans = ctx.markast.buildInlines(
      ctx,
      node['children'] as List<dynamic>?,
      style,
    );
    return Padding(
      padding: ctx.theme.headingPadding,
      child: Text.rich(TextSpan(style: style, children: spans)),
    );
  }
}
