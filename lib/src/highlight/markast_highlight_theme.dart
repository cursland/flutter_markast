import 'package:flutter/material.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/languages/all.dart';

import 'grammars/markast_grammars.dart';

/// Wraps a re_highlight theme (`Map<String, TextStyle>`) and exposes a single
/// [highlight] method that returns a [TextSpan] for both inline code and
/// code blocks.
///
/// The engine ([Highlight] instance + all languages) is shared as a static
/// singleton — instantiation is synchronous, no async init required.
///
/// ## Two layers of grammars
///
/// At construction time the static engine registers:
///
/// 1. **All built-in grammars** from `re_highlight/languages/all.dart` (~190
///    languages, basic quality — sufficient as a fallback).
/// 2. **Markast's enhanced grammars** from [MarkastGrammars.all] for the
///    most-used languages (Dart, Python, JS, TS, Go, Rust, Java, Kotlin,
///    Swift, C#, C, C++, Ruby, PHP, SQL, Bash, YAML, JSON, Markdown, PlantUML,
///    HTML, CSS). These overwrite the built-in entries — `registerLanguage`
///    does a `Map.put` semantically.
///
/// Both layers emit the same scope vocabulary (`keyword`, `string`, `number`,
/// `meta`, `title.class_`, `title.function_`, …) so every existing theme in
/// `MarkastCodeThemes` works unchanged. The improvement is in **which tokens
/// get classified as which scope**, not in how scopes are styled.
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

  /// Shared engine — registered once for the lifetime of the app.
  ///
  /// Built-in grammars are registered first (broad coverage, basic quality);
  /// Markast's enhanced grammars are registered on top and override the
  /// built-in entries for the languages they cover.
  static final Highlight _engine = () {
    final h = Highlight();
    h.registerLanguages(builtinAllLanguages);
    h.registerLanguages(MarkastGrammars.all);
    return h;
  }();

  /// Common shorthand aliases → canonical language names.
  static const Map<String, String> _aliases = {
    'js':         'javascript',
    'jsx':        'javascript',
    'mjs':        'javascript',
    'cjs':        'javascript',
    'ts':         'typescript',
    'tsx':        'typescript',
    'py':         'python',
    'yml':        'yaml',
    'rb':         'ruby',
    'cs':         'csharp',
    'c#':         'csharp',
    'fs':         'fsharp',
    'kt':         'kotlin',
    'kts':        'kotlin',
    'sh':         'bash',
    'zsh':        'bash',
    'shell':      'bash',
    'ps1':        'powershell',
    'md':         'markdown',
    'puml':       'plantuml',
    'uml':        'plantuml',
    'rs':         'rust',
    'golang':     'go',
    'h':          'c',
    'hpp':        'cpp',
    'hh':         'cpp',
    'hxx':        'cpp',
    'cc':         'cpp',
    'c++':        'cpp',
    'jsonc':      'json',
    'json5':      'json',
    'pgsql':      'sql',
    'mysql':      'sql',
    'sqlite':     'sql',
    'xml':        'html',
    'svg':        'html',
    'xhtml':      'html',
    'scss':       'css',
    'sass':       'css',
    'less':       'css',
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
    final lang = _aliases[language.toLowerCase()] ?? language.toLowerCase();
    try {
      final result = _engine.highlight(code: code, language: lang);
      final renderer = TextSpanRenderer(baseStyle, _theme);
      result.render(renderer);
      return renderer.span;
    } catch (_) {
      return null;
    }
  }

  /// Names of languages that use Markast's enhanced grammar (as opposed to
  /// re_highlight's basic built-in). Useful for diagnostics and tests.
  static List<String> get enhancedLanguages =>
      MarkastGrammars.supportedLanguages;
}
