import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

class TextInlineRenderer extends InlineRenderer {
  const TextInlineRenderer();

  @override
  String get type => NodeType.text;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    return TextSpan(text: (node['value'] as String?) ?? '', style: style);
  }
}
