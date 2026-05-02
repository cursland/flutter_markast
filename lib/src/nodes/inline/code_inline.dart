import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';

class CodeInlineRenderer extends InlineRenderer {
  const CodeInlineRenderer();

  @override
  String get type => NodeType.codeInline;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    final value = (node['value'] as String?) ?? '';
    final language = node['language'] as String?;
    final theme = ctx.theme;

    // backgroundColor is handled by the Container decoration, not TextStyle.
    final textStyle = style.merge(theme.codeInlineTextStyle).copyWith(
      backgroundColor: null,
    );

    Widget child;
    if (language != null && theme.highlightTheme != null) {
      final span = theme.highlightTheme!.highlight(value, language, textStyle);
      child = span != null ? Text.rich(span) : Text(value, style: textStyle);
    } else {
      child = Text(value, style: textStyle);
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Container(
        padding: theme.codeInlinePadding,
        decoration: theme.codeInlineDecoration,
        child: child,
      ),
    );
  }
}
