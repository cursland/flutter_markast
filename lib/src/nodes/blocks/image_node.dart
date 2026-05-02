import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';
import '../../util/timed_network_image.dart';

/// Renders a block-level image with optional title caption.
///
/// Image loading strategy (when [RenderContext.imageBuilder] is null):
/// - `http(s)://` → [TimedNetworkImage]
/// - `file://` or absolute path → `Image.file()`
/// - everything else → `Image.asset()`
///
/// Provide [RenderContext.imageBuilder] in [Markast.buildDocument] to replace
/// the default loading logic (e.g. `CachedNetworkImage`, CDN transforms).
class ImageNodeRenderer extends BlockRenderer {
  const ImageNodeRenderer();

  @override
  String get type => NodeType.image;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final src   = node['src']   as String? ?? '';
    final alt   = node['alt']   as String? ?? '';
    final title = node['title'] as String?;
    final theme = ctx.theme;

    Widget img;
    if (src.isEmpty) {
      img = _placeholder(ctx, alt);
    } else {
      img = ClipRRect(
        borderRadius: theme.imageBorderRadius,
        child: _loadImage(ctx, src, alt),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        img,
        if (title != null && title.isNotEmpty)
          Padding(
            padding: theme.imageTitlePadding,
            child: Text(title, style: theme.imageTitleTextStyle),
          ),
      ],
    );
  }

  Widget _loadImage(RenderContext ctx, String src, String alt) {
    final theme = ctx.theme;

    if (ctx.imageBuilder != null) {
      return ctx.imageBuilder!(
        src,
        fit: theme.imageFit,
        semanticLabel: alt.isEmpty ? null : alt,
      );
    }

    final isNetwork = src.startsWith('http://') || src.startsWith('https://');
    final isFile = src.startsWith('file://') || src.startsWith('/');

    if (isNetwork) {
      return TimedNetworkImage(
        url: src,
        fit: theme.imageFit,
        semanticLabel: alt.isEmpty ? null : alt,
        loadingBuilder: (_) => _loading(ctx),
        errorBuilder: (_) => _placeholder(ctx, alt),
      );
    } else if (isFile) {
      final path = src.startsWith('file://') ? src.substring(7) : src;
      return Image.file(
        Uri.file(path).toFilePath() as dynamic,
        semanticLabel: alt.isEmpty ? null : alt,
        fit: theme.imageFit,
        errorBuilder: (_, e, s) => _placeholder(ctx, alt),
      );
    } else {
      return Image.asset(
        src,
        semanticLabel: alt.isEmpty ? null : alt,
        fit: theme.imageFit,
        errorBuilder: (_, e, s) => _placeholder(ctx, alt),
      );
    }
  }

  Widget _placeholder(RenderContext ctx, String alt) => Container(
        height: ctx.theme.imagePlaceholderHeight,
        alignment: Alignment.center,
        decoration: ctx.theme.imagePlaceholderDecoration,
        child: Text(
          alt.isEmpty ? 'image' : alt,
          style: ctx.theme.imagePlaceholderTextStyle,
        ),
      );

  Widget _loading(RenderContext ctx) => Container(
        height: ctx.theme.imagePlaceholderHeight,
        alignment: Alignment.center,
        decoration: ctx.theme.imagePlaceholderDecoration,
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: ctx.theme.imagePlaceholderTextStyle.color,
          ),
        ),
      );
}
