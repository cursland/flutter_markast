import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Icons, CircularProgressIndicator;

import '../../ast/node_types.dart';
import '../../core/inline_renderer.dart';
import '../../core/render_context.dart';
import '../../util/timed_network_image.dart';

/// Renders an inline image as a [WidgetSpan] sized to match the surrounding
/// line height ([MarkastTheme.inlineImageHeightFactor]).
///
/// Provide [RenderContext.imageBuilder] to replace the default loading logic.
class InlineImageRenderer extends InlineRenderer {
  const InlineImageRenderer();

  @override
  String get type => NodeType.inlineImage;

  @override
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style) {
    final src  = node['src'] as String? ?? '';
    final size = (style.fontSize ?? 16) * ctx.theme.inlineImageHeightFactor;

    // Derive the muted color from the surrounding text rather than hardcoding.
    final fade = (style.color ?? ctx.theme.bodyTextStyle.color ?? const Color(0xFF888888))
        .withValues(alpha: 0.45);

    Widget broken() => Icon(Icons.broken_image_outlined, size: size, color: fade);
    Widget loading() => SizedBox(
          width: size,
          height: size,
          child: Center(
            child: SizedBox(
              width: size * 0.6,
              height: size * 0.6,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: fade),
            ),
          ),
        );

    Widget child;
    if (src.isEmpty) {
      child = broken();
    } else if (ctx.imageBuilder != null) {
      child = ctx.imageBuilder!(src, width: size, height: size, fit: BoxFit.contain);
    } else {
      final isNetwork = src.startsWith('http://') || src.startsWith('https://');
      if (isNetwork) {
        child = TimedNetworkImage(
          url: src,
          loadingBuilder: (_) => loading(),
          errorBuilder: (_) => broken(),
        );
      } else {
        child = Image.asset(src, errorBuilder: (_, e, s) => broken());
      }
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: SizedBox(height: size, child: child),
    );
  }
}
