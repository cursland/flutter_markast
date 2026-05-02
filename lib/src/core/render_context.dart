import 'package:flutter/widgets.dart';

import '../theme/markast_theme.dart';
import 'markast.dart';

// ── Callback typedefs ────────────────────────────────────────────────────────

/// Builds the raw image widget for a given [src]. The renderer handles
/// [ClipRRect] border-radius, placeholder, and title caption — only the image
/// content itself is delegated.
///
/// Default when null:
/// - `http(s)://` → [TimedNetworkImage] with 8 s timeout
/// - `file://` or absolute path → `Image.file()`
/// - everything else → `Image.asset()`
typedef MarkastImageBuilder = Widget Function(
  String src, {
  double? width,
  double? height,
  BoxFit fit,
  String? semanticLabel,
});

/// Builds the video player widget for a given [src]. The renderer wraps it
/// in an [AspectRatio] and outer frame decoration; only the player content
/// is delegated.
///
/// Default when null: poster image + play-icon affordance (no real playback).
typedef MarkastVideoBuilder = Widget Function(
  String src, {
  String? poster,
  double aspectRatio,
});

// ── RenderContext ─────────────────────────────────────────────────────────────

/// Passed through every renderer call. Holds the [BuildContext], the resolved
/// [MarkastTheme], the [Markast] instance (for recursive child rendering), all
/// per-document callbacks, and a mutable scratchpad for cross-node data.
///
/// Use [copyWith] inside container renderers to propagate a modified context
/// (e.g. a body-style override for blockquote) without mutating the original.
///
/// Custom widget renderers receive this same instance — call
/// `ctx.copyWith(context: innerContext)` inside a [LayoutBuilder] / [Builder]
/// when you need a fresh [BuildContext] with up-to-date constraints.
class RenderContext {
  RenderContext({
    required this.context,
    required this.theme,
    required this.markast,
    this.onLinkTap,
    this.imageBuilder,
    this.videoBuilder,
    this.onCodeCopy,
    this.bodyStyleOverride,
    Map<String, dynamic>? scratch,
  }) : scratch = scratch ?? <String, dynamic>{};

  final BuildContext context;
  final MarkastTheme theme;
  final Markast markast;

  /// Called when a link is tapped. [url] is the `href`; [title] is the
  /// optional Markdown title attribute. When null, links render as styled
  /// text with no interaction.
  final void Function(String url, String? title)? onLinkTap;

  /// Custom image widget builder. See [MarkastImageBuilder] for defaults.
  final MarkastImageBuilder? imageBuilder;

  /// Custom video player builder. See [MarkastVideoBuilder] for defaults.
  final MarkastVideoBuilder? videoBuilder;

  /// Called when the user taps the copy button on a code block. [code] is the
  /// raw text content. Defaults to [Clipboard.setData] when null.
  final void Function(String code)? onCodeCopy;

  /// When set, paragraphs and inline text inherit this style instead of
  /// [MarkastTheme.bodyTextStyle]. Used by blockquote and callout to recolor
  /// inner content without mutating the theme.
  final TextStyle? bodyStyleOverride;

  /// Mutable per-render scratchpad (footnote map, heading depth, …).
  /// Shared across the entire render tree for the lifetime of one
  /// [Markast.buildDocument] call.
  final Map<String, dynamic> scratch;

  /// The effective body style for the current subtree.
  TextStyle get effectiveBodyStyle =>
      bodyStyleOverride ?? theme.bodyTextStyle;

  /// Returns a copy with any of the given fields overridden.
  RenderContext copyWith({
    BuildContext? context,
    MarkastTheme? theme,
    void Function(String url, String? title)? onLinkTap,
    MarkastImageBuilder? imageBuilder,
    MarkastVideoBuilder? videoBuilder,
    void Function(String code)? onCodeCopy,
    TextStyle? bodyStyleOverride,
  }) =>
      RenderContext(
        context: context ?? this.context,
        theme: theme ?? this.theme,
        markast: markast,
        onLinkTap: onLinkTap ?? this.onLinkTap,
        imageBuilder: imageBuilder ?? this.imageBuilder,
        videoBuilder: videoBuilder ?? this.videoBuilder,
        onCodeCopy: onCodeCopy ?? this.onCodeCopy,
        bodyStyleOverride: bodyStyleOverride ?? this.bodyStyleOverride,
        scratch: scratch,
      );
}
