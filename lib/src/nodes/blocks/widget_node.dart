import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

/// Block-level dispatcher for `:::widget` containers — defers to the
/// widget registry by `widget` name.
class WidgetBlockRenderer extends BlockRenderer {
  const WidgetBlockRenderer();

  @override
  String get type => NodeType.widget;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    return ctx.markast.buildWidget(ctx, node);
  }
}
