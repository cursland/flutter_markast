import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

/// We don't parse raw HTML — render the source as preformatted text so it's
/// at least visible. Apps that want real HTML rendering can register a
/// renderer that uses `flutter_html`.
class HtmlBlockNodeRenderer extends BlockRenderer {
  const HtmlBlockNodeRenderer();

  @override
  String get type => NodeType.htmlBlock;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final value = (node['value'] as String?) ?? '';
    return Container(
      padding: ctx.theme.htmlBlockPadding,
      decoration: ctx.theme.htmlBlockDecoration,
      child: Text(value, style: ctx.theme.htmlBlockTextStyle),
    );
  }
}
