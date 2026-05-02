import 'package:flutter/material.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/all.dart';

/// Wraps a re_highlight theme (Map<String, TextStyle>) and exposes a single
/// [highlight] method that returns a [TextSpan] for both inline code and
/// code blocks.
///
/// The engine ([Highlight] instance + all languages) is shared as a static
/// singleton — instantiation is synchronous, no async init required.
///
/// Usage:
/// ```dart
/// final ht = MarkastHighlightTheme(theme: someReHighlightTheme);
/// final span = ht.highlight(code, 'dart', baseStyle);
/// ```
class MarkastHighlightTheme {
  const MarkastHighlightTheme({required Map<String, TextStyle> theme})
      : _theme = theme;

  final Map<String, TextStyle> _theme;

  // Shared engine — registered once for the lifetime of the app.
  static final Highlight _engine =
      Highlight()..registerLanguages(builtinAllLanguages);

  // Common shorthand aliases → re_highlight canonical names.
  static const Map<String, String> _aliases = {
    'js': 'javascript',
    'ts': 'typescript',
    'py': 'python',
    'yml': 'yaml',
    'rb': 'ruby',
    'cs': 'csharp',
    'fs': 'fsharp',
    'kt': 'kotlin',
    'sh': 'bash',
    'ps1': 'powershell',
  };

  /// Highlight [code] for [language] and return a [TextSpan].
  ///
  /// [baseStyle] is applied as the root style — it carries font family, size,
  /// and (for inline code) background color. Token colors from [_theme]
  /// override the text color of each child span.
  ///
  /// Returns null if the language is unknown or parsing fails; callers should
  /// fall back to a plain [TextSpan].
  TextSpan? highlight(String code, String language, TextStyle baseStyle) {
    final lang = _aliases[language] ?? language;
    try {
      final result = _engine.highlight(code: code, language: lang);
      final renderer = TextSpanRenderer(baseStyle, _theme);
      result.render(renderer);
      return renderer.span;
    } catch (_) {
      return null;
    }
  }
}
