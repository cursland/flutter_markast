import 'package:flutter/material.dart';

import '../highlight/markast_highlight_catalog.dart';
import '../highlight/markast_highlight_theme.dart';

/// Visual settings for one callout level. Just a Dart record — no custom
/// class. Build inline:
///
/// ```dart
/// (
///   icon: Icons.info_outline,
///   iconColor: Colors.blue,
///   titleStyle: TextStyle(...),
///   decoration: BoxDecoration(...),
/// )
/// ```
typedef MarkastCalloutStyle = ({
  IconData icon,
  Color iconColor,
  TextStyle titleStyle,
  BoxDecoration decoration,
});

/// The single umbrella theme for everything the official markast renderers
/// draw. Every concern is exposed as a plain Flutter primitive
/// ([TextStyle], [EdgeInsets], [BoxDecoration], …) so the consumer keeps
/// total control — including the font of bold text — without learning a
/// new API.
///
/// Custom widgets/blocks under `lib/custom/` are NOT styled through this
/// theme; their look lives inside each widget file. They still receive the
/// full [RenderContext] so they can do their own responsive work.
///
/// Plug it in either way:
///
/// 1. The Flutter way — through [ThemeData.extensions]:
///    ```dart
///    MaterialApp(
///      theme: ThemeData(extensions: [myMarkastTheme]),
///    );
///    ```
///    Renderers pull it via `Theme.of(context).extension<MarkastTheme>()`.
///
/// 2. Direct override on the renderer:
///    ```dart
///    final m = Markast.withDefaults(theme: myMarkastTheme);
///    ```
///
/// If neither is set, `MarkastTheme.fromTheme(Theme.of(context))` is built
/// automatically from the surrounding [ThemeData].
class MarkastTheme extends ThemeExtension<MarkastTheme> {
  const MarkastTheme({
    // ── Layout ─────────────────────────────────────────────────────────
    this.maxContentWidth = 720,
    this.documentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 32),
    this.compactDocumentPadding = const EdgeInsets.fromLTRB(16, 12, 16, 28),
    this.wideDocumentPadding = const EdgeInsets.fromLTRB(24, 24, 24, 48),
    this.compactBreakpoint = 600,
    this.wideBreakpoint = 1024,
    this.blockSpacing = 16,

    // ── Body / paragraph ──────────────────────────────────────────────
    required this.bodyTextStyle,
    this.paragraphPadding = EdgeInsets.zero,

    // ── Headings (per level) ──────────────────────────────────────────
    required this.h1TextStyle,
    required this.h2TextStyle,
    required this.h3TextStyle,
    required this.h4TextStyle,
    required this.h5TextStyle,
    required this.h6TextStyle,
    this.headingPadding = const EdgeInsets.only(top: 8, bottom: 4),

    // ── Inline overlays (merged onto the surrounding TextStyle) ──────
    this.boldTextStyle = const TextStyle(fontWeight: FontWeight.w700),
    this.italicTextStyle = const TextStyle(fontStyle: FontStyle.italic),
    this.boldItalicTextStyle = const TextStyle(
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
    ),
    this.strikethroughTextStyle = const TextStyle(
      decoration: TextDecoration.lineThrough,
    ),
    this.underlineTextStyle = const TextStyle(
      decoration: TextDecoration.underline,
    ),
    required this.linkTextStyle,
    required this.codeInlineTextStyle,
    required this.codeInlineDecoration,
    this.codeInlinePadding = const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    required this.footnoteRefTextStyle,
    required this.unknownInlineTextStyle,
    this.inlineImageHeightFactor = 1.1,

    // ── Blockquote ────────────────────────────────────────────────────
    required this.blockquoteDecoration,
    this.blockquotePadding = const EdgeInsets.fromLTRB(16, 8, 8, 8),
    required this.blockquoteTextStyle,

    // ── Code block ────────────────────────────────────────────────────
    required this.codeBlockTextStyle,
    required this.codeBlockDecoration,
    this.codeBlockPadding = const EdgeInsets.all(12),
    required this.codeBlockHeaderDecoration,
    this.codeBlockHeaderPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    required this.codeBlockFilenameTextStyle,
    required this.codeBlockLanguageTextStyle,
    required this.codeBlockLanguageBadgeDecoration,
    this.codeBlockLanguageBadgePadding =
        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    this.codeBlockShowCopyButton = true,
    required this.codeBlockCopyIconColor,
    this.codeBlockCopyIconSize = 16,

    // ── List ──────────────────────────────────────────────────────────
    required this.listMarkerTextStyle,
    this.listMarkerWidth = 22,
    this.listItemSpacing = 6,
    this.listBulletMarker = '•',

    // ── Table ─────────────────────────────────────────────────────────
    required this.tableDecoration,
    required this.tableHeaderRowDecoration,
    required this.tableHeaderTextStyle,
    required this.tableCellTextStyle,
    this.tableCellPadding =
        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    required this.tableInnerBorderSide,

    // ── Divider ───────────────────────────────────────────────────────
    required this.dividerColor,
    this.dividerThickness = 1,

    // ── Image ─────────────────────────────────────────────────────────
    this.imageBorderRadius = const BorderRadius.all(Radius.circular(8)),
    this.imageFit = BoxFit.contain,
    required this.imageTitleTextStyle,
    this.imageTitlePadding = const EdgeInsets.only(top: 4),
    required this.imagePlaceholderDecoration,
    required this.imagePlaceholderTextStyle,
    this.imagePlaceholderHeight = 120,

    // ── Video ─────────────────────────────────────────────────────────
    required this.videoFrameDecoration,
    required this.videoSrcTextStyle,
    this.videoSrcPadding = const EdgeInsets.all(8),
    this.videoPlayButtonDecoration = const BoxDecoration(
      color: Color(0x80000000),
      shape: BoxShape.circle,
    ),
    this.videoPlayButtonSize = 56,
    this.videoPlayIconColor = const Color(0xFFFFFFFF),
    this.videoPlayIconSize = 32,
    this.videoAspectRatio = 16 / 9,

    // ── Footnote def ─────────────────────────────────────────────────
    required this.footnoteDefLabelTextStyle,
    this.footnoteDefSpacing = 8,

    // ── HTML block ────────────────────────────────────────────────────
    required this.htmlBlockDecoration,
    this.htmlBlockPadding = const EdgeInsets.all(12),
    required this.htmlBlockTextStyle,

    // ── Missing renderer fallback ────────────────────────────────────
    required this.missingRendererDecoration,
    required this.missingRendererTextStyle,
    this.missingRendererPadding = const EdgeInsets.all(8),
    this.missingRendererMargin =
        const EdgeInsets.symmetric(vertical: 4),

    // ── Callouts (one record per level) ───────────────────────────────
    required this.calloutInfo,
    required this.calloutWarn,
    required this.calloutError,
    required this.calloutSuccess,
    this.calloutPadding = const EdgeInsets.all(14),
    this.calloutTitleSpacing = 8,
    this.calloutTitleIconSize = 18,

    // ── Syntax highlighting ───────────────────────────────────────────
    this.highlightTheme,
  });

  // ── Layout ────────────────────────────────────────────────────────
  final double maxContentWidth;
  final EdgeInsets documentPadding;
  final EdgeInsets compactDocumentPadding;
  final EdgeInsets wideDocumentPadding;
  final double compactBreakpoint;
  final double wideBreakpoint;
  final double blockSpacing;

  // ── Body / paragraph ──────────────────────────────────────────────
  final TextStyle bodyTextStyle;
  final EdgeInsets paragraphPadding;

  // ── Headings ──────────────────────────────────────────────────────
  final TextStyle h1TextStyle;
  final TextStyle h2TextStyle;
  final TextStyle h3TextStyle;
  final TextStyle h4TextStyle;
  final TextStyle h5TextStyle;
  final TextStyle h6TextStyle;
  final EdgeInsets headingPadding;

  // ── Inline ────────────────────────────────────────────────────────
  final TextStyle boldTextStyle;
  final TextStyle italicTextStyle;
  final TextStyle boldItalicTextStyle;
  final TextStyle strikethroughTextStyle;
  final TextStyle underlineTextStyle;
  final TextStyle linkTextStyle;
  final TextStyle codeInlineTextStyle;
  final BoxDecoration codeInlineDecoration;
  final EdgeInsets codeInlinePadding;
  final TextStyle footnoteRefTextStyle;
  final TextStyle unknownInlineTextStyle;
  final double inlineImageHeightFactor;

  // ── Blockquote ────────────────────────────────────────────────────
  final BoxDecoration blockquoteDecoration;
  final EdgeInsets blockquotePadding;
  final TextStyle blockquoteTextStyle;

  // ── Code block ────────────────────────────────────────────────────
  final TextStyle codeBlockTextStyle;
  final BoxDecoration codeBlockDecoration;
  final EdgeInsets codeBlockPadding;
  final BoxDecoration codeBlockHeaderDecoration;
  final EdgeInsets codeBlockHeaderPadding;
  final TextStyle codeBlockFilenameTextStyle;
  final TextStyle codeBlockLanguageTextStyle;
  final BoxDecoration codeBlockLanguageBadgeDecoration;
  final EdgeInsets codeBlockLanguageBadgePadding;
  final bool codeBlockShowCopyButton;
  final Color codeBlockCopyIconColor;
  final double codeBlockCopyIconSize;

  // ── List ──────────────────────────────────────────────────────────
  final TextStyle listMarkerTextStyle;
  final double listMarkerWidth;
  final double listItemSpacing;
  final String listBulletMarker;

  // ── Table ─────────────────────────────────────────────────────────
  final BoxDecoration tableDecoration;
  final BoxDecoration tableHeaderRowDecoration;
  final TextStyle tableHeaderTextStyle;
  final TextStyle tableCellTextStyle;
  final EdgeInsets tableCellPadding;
  final BorderSide tableInnerBorderSide;

  // ── Divider ───────────────────────────────────────────────────────
  final Color dividerColor;
  final double dividerThickness;

  // ── Image ─────────────────────────────────────────────────────────
  final BorderRadius imageBorderRadius;
  final BoxFit imageFit;
  final TextStyle imageTitleTextStyle;
  final EdgeInsets imageTitlePadding;
  final BoxDecoration imagePlaceholderDecoration;
  final TextStyle imagePlaceholderTextStyle;
  final double imagePlaceholderHeight;

  // ── Video ─────────────────────────────────────────────────────────
  final BoxDecoration videoFrameDecoration;
  final TextStyle videoSrcTextStyle;
  final EdgeInsets videoSrcPadding;
  final BoxDecoration videoPlayButtonDecoration;
  final double videoPlayButtonSize;
  final Color videoPlayIconColor;
  final double videoPlayIconSize;
  final double videoAspectRatio;

  // ── Footnote def ──────────────────────────────────────────────────
  final TextStyle footnoteDefLabelTextStyle;
  final double footnoteDefSpacing;

  // ── HTML block ────────────────────────────────────────────────────
  final BoxDecoration htmlBlockDecoration;
  final EdgeInsets htmlBlockPadding;
  final TextStyle htmlBlockTextStyle;

  // ── Missing renderer fallback ─────────────────────────────────────
  final BoxDecoration missingRendererDecoration;
  final TextStyle missingRendererTextStyle;
  final EdgeInsets missingRendererPadding;
  final EdgeInsets missingRendererMargin;

  // ── Callouts ──────────────────────────────────────────────────────
  final MarkastCalloutStyle calloutInfo;
  final MarkastCalloutStyle calloutWarn;
  final MarkastCalloutStyle calloutError;
  final MarkastCalloutStyle calloutSuccess;
  final EdgeInsets calloutPadding;
  final double calloutTitleSpacing;
  final double calloutTitleIconSize;

  // ── Syntax highlighting ────────────────────────────────────────────
  final MarkastHighlightTheme? highlightTheme;

  // ── Helpers ───────────────────────────────────────────────────────

  TextStyle headingStyleFor(int level) {
    switch (level.clamp(1, 6)) {
      case 1:
        return h1TextStyle;
      case 2:
        return h2TextStyle;
      case 3:
        return h3TextStyle;
      case 4:
        return h4TextStyle;
      case 5:
        return h5TextStyle;
      default:
        return h6TextStyle;
    }
  }

  EdgeInsets paddingFor(double width) {
    if (width < compactBreakpoint) return compactDocumentPadding;
    if (width >= wideBreakpoint) return wideDocumentPadding;
    return documentPadding;
  }

  MarkastCalloutStyle calloutFor(String level) {
    switch (level) {
      case 'warn':
      case 'warning':
        return calloutWarn;
      case 'error':
      case 'danger':
        return calloutError;
      case 'success':
        return calloutSuccess;
      case 'info':
      default:
        return calloutInfo;
    }
  }

  // ── Sensible defaults derived from a ThemeData ────────────────────

  factory MarkastTheme.fromTheme(ThemeData data) {
    final cs = data.colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final muted = isDark
        ? const Color(0xFF8B949E)
        : const Color(0xFF6B7280);
    final border = isDark
        ? const Color(0xFF30363D)
        : const Color(0xFFE4E4EB);
    final codeBg = isDark
        ? const Color(0xFF161B22)
        : const Color(0xFFF3F3F7);

    final body = TextStyle(color: cs.onSurface, fontSize: 16, height: 1.6);
    final code = TextStyle(
      fontFamily: 'monospace',
      color: cs.onSurface,
      fontSize: 13.5,
      height: 1.5,
    );

    return MarkastTheme(
      bodyTextStyle: body,

      h1TextStyle: body.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),
      h2TextStyle: body.copyWith(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      h3TextStyle: body.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h4TextStyle: body.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      ),
      h5TextStyle: body.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      h6TextStyle: body.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: muted,
      ),

      linkTextStyle: TextStyle(
        color: cs.primary,
        decoration: TextDecoration.underline,
        decorationColor: cs.primary,
      ),
      codeInlineTextStyle: TextStyle(
        fontFamily: 'monospace',
        color: cs.primary,
        fontSize: 13.5,
        height: 1.0,
      ),
      codeInlineDecoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.20),
          width: 0.8,
        ),
      ),
      footnoteRefTextStyle: TextStyle(
        color: cs.primary,
        fontFeatures: const [FontFeature.superscripts()],
      ),
      unknownInlineTextStyle: TextStyle(color: cs.error),

      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: cs.primary, width: 3)),
      ),
      blockquoteTextStyle: TextStyle(color: muted),

      codeBlockTextStyle: code,
      codeBlockDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      codeBlockHeaderDecoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      codeBlockFilenameTextStyle: TextStyle(
        color: muted,
        fontSize: 12,
        fontFamily: 'monospace',
      ),
      codeBlockLanguageTextStyle: TextStyle(
        color: cs.primary,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      codeBlockLanguageBadgeDecoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      codeBlockCopyIconColor: muted,

      listMarkerTextStyle: body.copyWith(color: muted),

      tableDecoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      tableHeaderRowDecoration: BoxDecoration(color: codeBg),
      tableHeaderTextStyle:
          body.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
      tableCellTextStyle:
          body.copyWith(fontWeight: FontWeight.w400, fontSize: 14),
      tableInnerBorderSide: BorderSide(color: border),

      dividerColor: border,

      imageTitleTextStyle: TextStyle(color: muted, fontSize: 13),
      imagePlaceholderDecoration: BoxDecoration(
        color: codeBg,
        border: Border.all(color: border),
      ),
      imagePlaceholderTextStyle: TextStyle(color: muted),

      videoFrameDecoration: BoxDecoration(
        color: codeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      videoSrcTextStyle: TextStyle(color: muted, fontSize: 12),

      footnoteDefLabelTextStyle: body.copyWith(
        color: cs.primary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),

      htmlBlockDecoration: BoxDecoration(
        color: codeBg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(6),
      ),
      htmlBlockTextStyle: TextStyle(
        fontFamily: 'monospace',
        color: muted,
        fontSize: 12.5,
        height: 1.5,
      ),

      missingRendererDecoration: BoxDecoration(
        border: Border.all(color: cs.error),
        borderRadius: BorderRadius.circular(4),
      ),
      missingRendererTextStyle: TextStyle(color: cs.error, fontSize: 12),

      calloutInfo: (
        icon: Icons.info_outline,
        iconColor: cs.primary,
        titleStyle: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: cs.primary, width: 3)),
        ),
      ),
      calloutWarn: (
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFB45309),
        titleStyle: const TextStyle(
          color: Color(0xFFB45309),
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
        decoration: const BoxDecoration(
          color: Color(0x1AB45309),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border(left: BorderSide(color: Color(0xFFB45309), width: 3)),
        ),
      ),
      calloutError: (
        icon: Icons.error_outline,
        iconColor: cs.error,
        titleStyle: TextStyle(
          color: cs.error,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
        decoration: BoxDecoration(
          color: cs.error.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: cs.error, width: 3)),
        ),
      ),
      calloutSuccess: (
        icon: Icons.check_circle_outline,
        iconColor: const Color(0xFF16A34A),
        titleStyle: const TextStyle(
          color: Color(0xFF16A34A),
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.4,
        ),
        decoration: const BoxDecoration(
          color: Color(0x1A16A34A),
          borderRadius: BorderRadius.all(Radius.circular(8)),
          border: Border(left: BorderSide(color: Color(0xFF16A34A), width: 3)),
        ),
      ),
      highlightTheme: MarkastHighlightTheme(
        theme: isDark ? MarkastCodeThemes.paraisoDark : MarkastCodeThemes.paraisoLight,
      ),
    );
  }

  // ── ThemeExtension API ────────────────────────────────────────────

  @override
  MarkastTheme copyWith({
    double? maxContentWidth,
    EdgeInsets? documentPadding,
    EdgeInsets? compactDocumentPadding,
    EdgeInsets? wideDocumentPadding,
    double? compactBreakpoint,
    double? wideBreakpoint,
    double? blockSpacing,
    TextStyle? bodyTextStyle,
    EdgeInsets? paragraphPadding,
    TextStyle? h1TextStyle,
    TextStyle? h2TextStyle,
    TextStyle? h3TextStyle,
    TextStyle? h4TextStyle,
    TextStyle? h5TextStyle,
    TextStyle? h6TextStyle,
    EdgeInsets? headingPadding,
    TextStyle? boldTextStyle,
    TextStyle? italicTextStyle,
    TextStyle? boldItalicTextStyle,
    TextStyle? strikethroughTextStyle,
    TextStyle? underlineTextStyle,
    TextStyle? linkTextStyle,
    TextStyle? codeInlineTextStyle,
    BoxDecoration? codeInlineDecoration,
    EdgeInsets? codeInlinePadding,
    TextStyle? footnoteRefTextStyle,
    TextStyle? unknownInlineTextStyle,
    double? inlineImageHeightFactor,
    BoxDecoration? blockquoteDecoration,
    EdgeInsets? blockquotePadding,
    TextStyle? blockquoteTextStyle,
    TextStyle? codeBlockTextStyle,
    BoxDecoration? codeBlockDecoration,
    EdgeInsets? codeBlockPadding,
    BoxDecoration? codeBlockHeaderDecoration,
    EdgeInsets? codeBlockHeaderPadding,
    TextStyle? codeBlockFilenameTextStyle,
    TextStyle? codeBlockLanguageTextStyle,
    BoxDecoration? codeBlockLanguageBadgeDecoration,
    EdgeInsets? codeBlockLanguageBadgePadding,
    bool? codeBlockShowCopyButton,
    Color? codeBlockCopyIconColor,
    double? codeBlockCopyIconSize,
    TextStyle? listMarkerTextStyle,
    double? listMarkerWidth,
    double? listItemSpacing,
    String? listBulletMarker,
    BoxDecoration? tableDecoration,
    BoxDecoration? tableHeaderRowDecoration,
    TextStyle? tableHeaderTextStyle,
    TextStyle? tableCellTextStyle,
    EdgeInsets? tableCellPadding,
    BorderSide? tableInnerBorderSide,
    Color? dividerColor,
    double? dividerThickness,
    BorderRadius? imageBorderRadius,
    BoxFit? imageFit,
    TextStyle? imageTitleTextStyle,
    EdgeInsets? imageTitlePadding,
    BoxDecoration? imagePlaceholderDecoration,
    TextStyle? imagePlaceholderTextStyle,
    double? imagePlaceholderHeight,
    BoxDecoration? videoFrameDecoration,
    TextStyle? videoSrcTextStyle,
    EdgeInsets? videoSrcPadding,
    BoxDecoration? videoPlayButtonDecoration,
    double? videoPlayButtonSize,
    Color? videoPlayIconColor,
    double? videoPlayIconSize,
    double? videoAspectRatio,
    TextStyle? footnoteDefLabelTextStyle,
    double? footnoteDefSpacing,
    BoxDecoration? htmlBlockDecoration,
    EdgeInsets? htmlBlockPadding,
    TextStyle? htmlBlockTextStyle,
    BoxDecoration? missingRendererDecoration,
    TextStyle? missingRendererTextStyle,
    EdgeInsets? missingRendererPadding,
    EdgeInsets? missingRendererMargin,
    MarkastCalloutStyle? calloutInfo,
    MarkastCalloutStyle? calloutWarn,
    MarkastCalloutStyle? calloutError,
    MarkastCalloutStyle? calloutSuccess,
    EdgeInsets? calloutPadding,
    double? calloutTitleSpacing,
    double? calloutTitleIconSize,
    MarkastHighlightTheme? highlightTheme,
  }) {
    return MarkastTheme(
      maxContentWidth: maxContentWidth ?? this.maxContentWidth,
      documentPadding: documentPadding ?? this.documentPadding,
      compactDocumentPadding:
          compactDocumentPadding ?? this.compactDocumentPadding,
      wideDocumentPadding: wideDocumentPadding ?? this.wideDocumentPadding,
      compactBreakpoint: compactBreakpoint ?? this.compactBreakpoint,
      wideBreakpoint: wideBreakpoint ?? this.wideBreakpoint,
      blockSpacing: blockSpacing ?? this.blockSpacing,
      bodyTextStyle: bodyTextStyle ?? this.bodyTextStyle,
      paragraphPadding: paragraphPadding ?? this.paragraphPadding,
      h1TextStyle: h1TextStyle ?? this.h1TextStyle,
      h2TextStyle: h2TextStyle ?? this.h2TextStyle,
      h3TextStyle: h3TextStyle ?? this.h3TextStyle,
      h4TextStyle: h4TextStyle ?? this.h4TextStyle,
      h5TextStyle: h5TextStyle ?? this.h5TextStyle,
      h6TextStyle: h6TextStyle ?? this.h6TextStyle,
      headingPadding: headingPadding ?? this.headingPadding,
      boldTextStyle: boldTextStyle ?? this.boldTextStyle,
      italicTextStyle: italicTextStyle ?? this.italicTextStyle,
      boldItalicTextStyle: boldItalicTextStyle ?? this.boldItalicTextStyle,
      strikethroughTextStyle:
          strikethroughTextStyle ?? this.strikethroughTextStyle,
      underlineTextStyle: underlineTextStyle ?? this.underlineTextStyle,
      linkTextStyle: linkTextStyle ?? this.linkTextStyle,
      codeInlineTextStyle: codeInlineTextStyle ?? this.codeInlineTextStyle,
      codeInlineDecoration: codeInlineDecoration ?? this.codeInlineDecoration,
      codeInlinePadding: codeInlinePadding ?? this.codeInlinePadding,
      footnoteRefTextStyle: footnoteRefTextStyle ?? this.footnoteRefTextStyle,
      unknownInlineTextStyle:
          unknownInlineTextStyle ?? this.unknownInlineTextStyle,
      inlineImageHeightFactor:
          inlineImageHeightFactor ?? this.inlineImageHeightFactor,
      blockquoteDecoration: blockquoteDecoration ?? this.blockquoteDecoration,
      blockquotePadding: blockquotePadding ?? this.blockquotePadding,
      blockquoteTextStyle: blockquoteTextStyle ?? this.blockquoteTextStyle,
      codeBlockTextStyle: codeBlockTextStyle ?? this.codeBlockTextStyle,
      codeBlockDecoration: codeBlockDecoration ?? this.codeBlockDecoration,
      codeBlockPadding: codeBlockPadding ?? this.codeBlockPadding,
      codeBlockHeaderDecoration:
          codeBlockHeaderDecoration ?? this.codeBlockHeaderDecoration,
      codeBlockHeaderPadding:
          codeBlockHeaderPadding ?? this.codeBlockHeaderPadding,
      codeBlockFilenameTextStyle:
          codeBlockFilenameTextStyle ?? this.codeBlockFilenameTextStyle,
      codeBlockLanguageTextStyle:
          codeBlockLanguageTextStyle ?? this.codeBlockLanguageTextStyle,
      codeBlockLanguageBadgeDecoration: codeBlockLanguageBadgeDecoration ??
          this.codeBlockLanguageBadgeDecoration,
      codeBlockLanguageBadgePadding:
          codeBlockLanguageBadgePadding ?? this.codeBlockLanguageBadgePadding,
      codeBlockShowCopyButton:
          codeBlockShowCopyButton ?? this.codeBlockShowCopyButton,
      codeBlockCopyIconColor:
          codeBlockCopyIconColor ?? this.codeBlockCopyIconColor,
      codeBlockCopyIconSize:
          codeBlockCopyIconSize ?? this.codeBlockCopyIconSize,
      listMarkerTextStyle: listMarkerTextStyle ?? this.listMarkerTextStyle,
      listMarkerWidth: listMarkerWidth ?? this.listMarkerWidth,
      listItemSpacing: listItemSpacing ?? this.listItemSpacing,
      listBulletMarker: listBulletMarker ?? this.listBulletMarker,
      tableDecoration: tableDecoration ?? this.tableDecoration,
      tableHeaderRowDecoration:
          tableHeaderRowDecoration ?? this.tableHeaderRowDecoration,
      tableHeaderTextStyle: tableHeaderTextStyle ?? this.tableHeaderTextStyle,
      tableCellTextStyle: tableCellTextStyle ?? this.tableCellTextStyle,
      tableCellPadding: tableCellPadding ?? this.tableCellPadding,
      tableInnerBorderSide: tableInnerBorderSide ?? this.tableInnerBorderSide,
      dividerColor: dividerColor ?? this.dividerColor,
      dividerThickness: dividerThickness ?? this.dividerThickness,
      imageBorderRadius: imageBorderRadius ?? this.imageBorderRadius,
      imageFit: imageFit ?? this.imageFit,
      imageTitleTextStyle: imageTitleTextStyle ?? this.imageTitleTextStyle,
      imageTitlePadding: imageTitlePadding ?? this.imageTitlePadding,
      imagePlaceholderDecoration:
          imagePlaceholderDecoration ?? this.imagePlaceholderDecoration,
      imagePlaceholderTextStyle:
          imagePlaceholderTextStyle ?? this.imagePlaceholderTextStyle,
      imagePlaceholderHeight:
          imagePlaceholderHeight ?? this.imagePlaceholderHeight,
      videoFrameDecoration: videoFrameDecoration ?? this.videoFrameDecoration,
      videoSrcTextStyle: videoSrcTextStyle ?? this.videoSrcTextStyle,
      videoSrcPadding: videoSrcPadding ?? this.videoSrcPadding,
      videoPlayButtonDecoration:
          videoPlayButtonDecoration ?? this.videoPlayButtonDecoration,
      videoPlayButtonSize: videoPlayButtonSize ?? this.videoPlayButtonSize,
      videoPlayIconColor: videoPlayIconColor ?? this.videoPlayIconColor,
      videoPlayIconSize: videoPlayIconSize ?? this.videoPlayIconSize,
      videoAspectRatio: videoAspectRatio ?? this.videoAspectRatio,
      footnoteDefLabelTextStyle:
          footnoteDefLabelTextStyle ?? this.footnoteDefLabelTextStyle,
      footnoteDefSpacing: footnoteDefSpacing ?? this.footnoteDefSpacing,
      htmlBlockDecoration: htmlBlockDecoration ?? this.htmlBlockDecoration,
      htmlBlockPadding: htmlBlockPadding ?? this.htmlBlockPadding,
      htmlBlockTextStyle: htmlBlockTextStyle ?? this.htmlBlockTextStyle,
      missingRendererDecoration:
          missingRendererDecoration ?? this.missingRendererDecoration,
      missingRendererTextStyle:
          missingRendererTextStyle ?? this.missingRendererTextStyle,
      missingRendererPadding:
          missingRendererPadding ?? this.missingRendererPadding,
      missingRendererMargin:
          missingRendererMargin ?? this.missingRendererMargin,
      calloutInfo: calloutInfo ?? this.calloutInfo,
      calloutWarn: calloutWarn ?? this.calloutWarn,
      calloutError: calloutError ?? this.calloutError,
      calloutSuccess: calloutSuccess ?? this.calloutSuccess,
      calloutPadding: calloutPadding ?? this.calloutPadding,
      calloutTitleSpacing: calloutTitleSpacing ?? this.calloutTitleSpacing,
      calloutTitleIconSize: calloutTitleIconSize ?? this.calloutTitleIconSize,
      highlightTheme: highlightTheme ?? this.highlightTheme,
    );
  }

  /// Step lerp — content theming rarely needs interpolation; switching at
  /// 0.5 is fine and keeps the implementation small.
  @override
  MarkastTheme lerp(ThemeExtension<MarkastTheme>? other, double t) {
    if (other is! MarkastTheme) return this;
    return t < 0.5 ? this : other;
  }
}
