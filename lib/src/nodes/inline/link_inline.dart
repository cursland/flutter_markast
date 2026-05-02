import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

class LinkInlineRenderer extends InlineRenderer {
  const LinkInlineRenderer();

  @override
  String get type => NodeType.link;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    final href  = node['href']  as String? ?? '';
    final title = node['title'] as String?;
    final next  = style.merge(ctx.theme.linkTextStyle);

    final onTap = ctx.onLinkTap;
    final recognizer = onTap != null
        ? (TapGestureRecognizer()..onTap = () => onTap(href, title))
        : null;

    return TextSpan(
      style: next,
      recognizer: recognizer,
      mouseCursor: onTap != null ? SystemMouseCursors.click : null,
      children: ctx.markast.buildInlines(
        ctx,
        node['children'] as List<dynamic>?,
        next,
      ),
    );
  }
}
