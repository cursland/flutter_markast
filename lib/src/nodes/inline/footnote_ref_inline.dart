import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

class FootnoteRefInlineRenderer extends InlineRenderer {
  const FootnoteRefInlineRenderer();

  @override
  String get type => NodeType.footnoteRef;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    final label = (node['label'] as String?) ?? '?';
    return TextSpan(
      text: '[$label]',
      style: style.merge(ctx.theme.footnoteRefTextStyle),
    );
  }
}
