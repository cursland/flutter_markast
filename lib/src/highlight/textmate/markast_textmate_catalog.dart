import 'dart:ui' show Brightness;

import 'package:flutter/painting.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

/// Curated catalog of TextMate themes that ship with `syntax_highlight`.
///
/// These are the official VSCode themes, distributed as TextMate JSON theme
/// files under `packages/syntax_highlight/themes/`. Every method on this
/// class returns a `Future<HighlighterTheme>` — load once at app startup and
/// pass into [MarkastTextMateHighlight.create].
///
/// ```dart
/// final theme = await MarkastTextMateThemes.darkPlus();
/// final hl    = await MarkastTextMateHighlight.create(theme: theme);
/// ```
///
/// Each theme accepts an optional [defaultStyle] — applied to text that
/// doesn't match any TextMate scope. The defaults here mirror the
/// `syntax_highlight` package's own choices (a soft cyan for dark themes,
/// dark navy for light) and look reasonable on top of any background.
///
/// ## Themes
///
/// * **darkPlus** — VSCode "Dark+ (default)". Most common dark theme.
/// * **darkVs** — Classic Visual Studio dark.
/// * **lightPlus** — VSCode "Light+ (default)". Most common light theme.
/// * **lightVs** — Classic Visual Studio light.
///
/// Compose multiple files via [merged] to layer overrides on top of a base
/// theme — the underlying engine merges in the order you pass.
abstract final class MarkastTextMateThemes {
  static const _kPkg = 'packages/syntax_highlight/themes';
  static const _kDarkDefaultStyle = TextStyle(color: Color(0xFFB9EEFF));
  static const _kLightDefaultStyle = TextStyle(color: Color(0xFF000088));

  /// VSCode "Dark+ (default)". Applied on top of the base "dark_vs" theme.
  static Future<HighlighterTheme> darkPlus({TextStyle? defaultStyle}) {
    return HighlighterTheme.loadFromAssets(
      const ['$_kPkg/dark_vs.json', '$_kPkg/dark_plus.json'],
      defaultStyle ?? _kDarkDefaultStyle,
    );
  }

  /// Classic Visual Studio dark, without the "+" overrides.
  static Future<HighlighterTheme> darkVs({TextStyle? defaultStyle}) {
    return HighlighterTheme.loadFromAssets(
      const ['$_kPkg/dark_vs.json'],
      defaultStyle ?? _kDarkDefaultStyle,
    );
  }

  /// VSCode "Light+ (default)". Applied on top of the base "light_vs" theme.
  static Future<HighlighterTheme> lightPlus({TextStyle? defaultStyle}) {
    return HighlighterTheme.loadFromAssets(
      const ['$_kPkg/light_vs.json', '$_kPkg/light_plus.json'],
      defaultStyle ?? _kLightDefaultStyle,
    );
  }

  /// Classic Visual Studio light, without the "+" overrides.
  static Future<HighlighterTheme> lightVs({TextStyle? defaultStyle}) {
    return HighlighterTheme.loadFromAssets(
      const ['$_kPkg/light_vs.json'],
      defaultStyle ?? _kLightDefaultStyle,
    );
  }

  /// Auto-pick a theme based on the current platform brightness.
  ///
  /// Returns [darkPlus] for [Brightness.dark], otherwise [lightPlus].
  static Future<HighlighterTheme> forBrightness(Brightness brightness,
      {TextStyle? defaultStyle}) {
    return brightness == Brightness.dark
        ? darkPlus(defaultStyle: defaultStyle)
        : lightPlus(defaultStyle: defaultStyle);
  }

  /// Compose a custom theme from one or more JSON asset paths plus a
  /// [defaultStyle]. Useful when you want to add overrides on top of a
  /// shipped theme, or load a third-party VSCode theme bundled in your app.
  static Future<HighlighterTheme> merged(
    List<String> jsonAssetPaths, {
    required TextStyle defaultStyle,
  }) {
    return HighlighterTheme.loadFromAssets(jsonAssetPaths, defaultStyle);
  }
}
