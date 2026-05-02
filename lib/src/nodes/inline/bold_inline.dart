import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

class BoldInlineRenderer extends InlineRenderer {
  const BoldInlineRenderer();

  @override
  String get type => NodeType.bold;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    final next = style.merge(ctx.theme.boldTextStyle);
    return TextSpan(
      style: next,
      children: ctx.markast.buildInlines(
        ctx,
        node['children'] as List<dynamic>?,
        next,
      ),
    );
  }
}
