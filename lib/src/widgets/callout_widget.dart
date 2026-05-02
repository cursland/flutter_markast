import 'package:flutter/material.dart';

import '../core/render_context.dart';
import '../core/widget_node_renderer.dart';

/// Official `:::callout` widget. Props: `level` (info/warn/error/success),
/// optional `title`. Body comes from the `default` slot. Per-level visuals
/// are picked from `ctx.theme.calloutFor(level)`.
class CalloutWidgetRenderer extends WidgetNodeRenderer {
  const CalloutWidgetRenderer();

  @override
  String get name => 'callout';

  @override
  Widget build(
    RenderContext ctx,
    Map<String, dynamic> props,
    Map<String, List<Map<String, dynamic>>> slots,
  ) {
    final level = (props['level'] as String?) ?? 'info';
    final title = props['title'] as String?;
    final theme = ctx.theme;
    final palette = theme.calloutFor(level);

    final children = ctx.markast.buildMixedBody(
      ctx,
      slots['default'],
      ctx.effectiveBodyStyle,
    );

    return Container(
      padding: theme.calloutPadding,
      decoration: palette.decoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                palette.icon,
                color: palette.iconColor,
                size: theme.calloutTitleIconSize,
              ),
              SizedBox(width: theme.calloutTitleSpacing),
              Text(title ?? level.toUpperCase(), style: palette.titleStyle),
            ],
          ),
          SizedBox(height: theme.calloutTitleSpacing),
          ...children,
        ],
      ),
    );
  }
}
