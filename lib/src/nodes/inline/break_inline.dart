import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

/// Soft and hard line-breaks. In this renderer both produce a real newline:
/// every Enter the author types in source becomes a visible break (unlike
/// CommonMark's default of collapsing softbreaks to a single space). This
/// trades spec-compliance for "what you type is what you see".
class SoftbreakInlineRenderer extends InlineRenderer {
  const SoftbreakInlineRenderer();

  @override
  String get type => NodeType.softbreak;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    return TextSpan(text: '\n', style: style);
  }
}

class HardbreakInlineRenderer extends InlineRenderer {
  const HardbreakInlineRenderer();

  @override
  String get type => NodeType.hardbreak;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    // Trailing ZWSP gives the empty line a glyph so consecutive hardbreaks
    // stack visibly; without it Flutter collapses the line to zero height.
    return TextSpan(text: '\n​', style: style);
  }
}
