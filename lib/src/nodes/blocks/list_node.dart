import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

class ListNodeRenderer extends BlockRenderer {
  const ListNodeRenderer();

  @override
  String get type => NodeType.list;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final ordered = (node['ordered'] as bool?) ?? false;
    final start = (node['start'] as int?) ?? 1;
    final items = (node['children'] as List<dynamic>?) ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++)
          _ListItem(
            ctx: ctx,
            node: items[i] as Map<String, dynamic>,
            marker:
                ordered ? '${start + i}.' : ctx.theme.listBulletMarker,
          ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.ctx, required this.node, required this.marker});

  final RenderContext ctx;
  final Map<String, dynamic> node;
  final String marker;

  @override
  Widget build(BuildContext context) {
    final theme = ctx.theme;
    final checked = node['checked'] as bool?;
    final children = (node['children'] as List<dynamic>?) ?? const [];

    // Marker inherits body metrics (fontSize + height) so its line box
    // matches the body's first line and the baselines align naturally with
    // CrossAxisAlignment.start. Theme's listMarkerTextStyle is treated as
    // an overlay (typically just a color override).
    final markerStyle =
        ctx.effectiveBodyStyle.merge(theme.listMarkerTextStyle);
    final lineHeight =
        (markerStyle.fontSize ?? 16) * (markerStyle.height ?? 1);

    Widget bullet;
    if (checked != null) {
      // Center the checkbox vertically within the body's first-line box.
      bullet = SizedBox(
        width: theme.listMarkerWidth,
        height: lineHeight,
        child: Center(
          child: SizedBox(
            width: theme.listMarkerWidth,
            height: theme.listMarkerWidth,
            child: Checkbox(
              value: checked,
              onChanged: null,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      );
    } else {
      bullet = SizedBox(
        width: theme.listMarkerWidth,
        child: Text(marker, style: markerStyle),
      );
    }

    final widgets = ctx.markast.buildMixedBody(
      ctx,
      children,
      ctx.effectiveBodyStyle,
    );
    final body = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      body.add(widgets[i]);
      if (i != widgets.length - 1) {
        body.add(SizedBox(height: theme.blockSpacing * 0.5));
      }
    }

    return Padding(
      padding: EdgeInsets.only(bottom: theme.listItemSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bullet,
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: body,
            ),
          ),
        ],
      ),
    );
  }
}
