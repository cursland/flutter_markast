import 'package:flutter/painting.dart';

/// Abstract contract for any syntax-highlighting engine that plugs into
/// Markast.
///
/// Markast ships two implementations:
///
/// * **[MarkastHighlightTheme]** — the default engine. Built on top of
///   `re_highlight` (a Dart port of highlight.js) plus Markast's enhanced
///   grammars. Synchronous, broad coverage (~190 languages), works on every
///   Flutter platform without async setup.
///
/// * **[MarkastTextMateHighlight]** — the opt-in engine. Built on top of
///   `syntax_highlight` (the Serverpod TextMate engine). Uses the **same
///   grammar files VSCode uses**, producing visually identical output for the
///   15 languages it supports. Requires async initialization at app startup.
///
/// Both implementations expose the same single method, [highlight], so
/// `MarkastTheme.highlightTheme` accepts either one transparently. The code
/// block widget calls `highlight()` and renders whatever [TextSpan] comes
/// back — it has no knowledge of which engine produced it.
abstract class MarkastHighlighter {
  const MarkastHighlighter();

  /// Returns a styled [TextSpan] for [code] interpreted as [language], with
  /// [baseStyle] applied as the root text style (font family, size, …).
  ///
  /// Returns `null` when:
  /// * the language is not supported by this engine, or
  /// * parsing fails.
  ///
  /// In either case the caller is expected to fall back to a plain
  /// `TextSpan(text: code, style: baseStyle)`.
  TextSpan? highlight(String code, String language, TextStyle baseStyle);

  /// Whether this engine can highlight [language] (after alias resolution).
  ///
  /// Useful for UIs that want to show "this language is highlighted" badges,
  /// or for the code block widget to decide whether to render a fallback.
  bool supports(String language);
}
