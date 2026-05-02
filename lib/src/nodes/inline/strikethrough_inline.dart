import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

class StrikethroughInlineRenderer extends InlineRenderer {
  const StrikethroughInlineRenderer();

  @override
  String get type => NodeType.strikethrough;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    final next = style.merge(ctx.theme.strikethroughTextStyle);
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
