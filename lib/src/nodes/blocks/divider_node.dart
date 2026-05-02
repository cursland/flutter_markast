import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class DividerNodeRenderer extends BlockRenderer {
  const DividerNodeRenderer();

  @override
  String get type => NodeType.divider;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) => Divider(
        color: ctx.theme.dividerColor,
        thickness: ctx.theme.dividerThickness,
        height: ctx.theme.dividerThickness,
      );
}
