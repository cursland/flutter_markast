import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';
import '../../util/timed_network_image.dart';

/// Default video renderer: poster + play-icon affordance + source URL label.
/// No actual playback — this is intentional.
///
/// Provide [RenderContext.videoBuilder] in [Markast.buildDocument] to replace
/// the content area with a real player (e.g. `youtube_player_flutter`,
/// `video_player + chewie`). The outer frame decoration and source label are
/// still controlled by the theme.
class VideoNodeRenderer extends BlockRenderer {
  const VideoNodeRenderer();

  @override
  String get type => NodeType.video;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final src    = node['src']    as String? ?? '';
    final poster = node['poster'] as String?;
    final theme  = ctx.theme;

    return Container(
      decoration: theme.videoFrameDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: theme.videoAspectRatio,
            child: ctx.videoBuilder != null
                ? ctx.videoBuilder!(
                    src,
                    poster: poster,
                    aspectRatio: theme.videoAspectRatio,
                  )
                : _defaultPlayer(ctx, src, poster),
          ),
          Padding(
            padding: theme.videoSrcPadding,
            child: Text(
              src,
              style: theme.videoSrcTextStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _defaultPlayer(RenderContext ctx, String src, String? poster) {
    final theme = ctx.theme;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (poster != null && poster.isNotEmpty)
          TimedNetworkImage(
            url: poster,
            fit: BoxFit.cover,
            loadingBuilder: (_) => const SizedBox.shrink(),
            errorBuilder: (_) => const SizedBox.shrink(),
          ),
        Center(
          child: Container(
            width: theme.videoPlayButtonSize,
            height: theme.videoPlayButtonSize,
            decoration: theme.videoPlayButtonDecoration,
            child: Icon(
              Icons.play_arrow,
              color: theme.videoPlayIconColor,
              size: theme.videoPlayIconSize,
            ),
          ),
        ),
      ],
    );
  }
}
