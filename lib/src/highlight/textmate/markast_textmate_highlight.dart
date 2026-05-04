import 'package:flutter/painting.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import '../markast_highlighter.dart';

/// VSCode-quality syntax highlighting for Markast.
///
/// This is the **opt-in** highlight engine — built on `syntax_highlight`,
/// which executes the same TextMate grammar files VSCode itself uses. The
/// output is visually equivalent to what you'd see in VSCode's editor for
/// the 15 languages it supports.
///
/// ## Setup
///
/// Because TextMate grammars are loaded from bundled JSON assets, the engine
/// requires a one-time async bootstrap. Do it once at app startup, before
/// `runApp`:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final hl = await MarkastTextMateHighlight.create(
///     theme: await MarkastTextMateThemes.darkPlus(),
///   );
///   runApp(MyApp(highlighter: hl));
/// }
/// ```
///
/// Then plug it into a [MarkastTheme]:
///
/// ```dart
/// final markast = Markast(themeModifier: (base) => base.copyWith(
///   highlightTheme: hl,   // accepts MarkastHighlighter (interface)
/// ));
/// ```
///
/// ## Supported languages
///
/// The bundled grammars cover: **css, dart, go, html, java, javascript, json,
/// kotlin, python, rust, sql, swift, typescript, yaml** (and Serverpod's
/// custom protocol). For any other language, [highlight] returns `null` and
/// the code block falls back to plain text — that's why Markast keeps the
/// re_highlight backend ([MarkastHighlightTheme]) around as a separate option:
/// the two engines are alternatives, not layers.
///
/// ## Why not just one engine?
///
/// * Motor A ([MarkastHighlightTheme]) — sync, ~190 languages, custom
///   grammars, custom themes catalog.
/// * Motor B ([MarkastTextMateHighlight]) — async setup, 15 languages,
///   VSCode-grade output, official VSCode themes.
///
/// They share **no theme vocabulary** (re_highlight uses scope names like
/// `keyword`, `string`; TextMate themes use full hierarchical scopes like
/// `keyword.control.dart`, `string.quoted.double.dart`), which is why
/// crossing them adds more friction than value. Pick one per project.
class MarkastTextMateHighlight extends MarkastHighlighter {
  MarkastTextMateHighlight._({
    required HighlighterTheme theme,
    required Set<String> languages,
  })  : _theme = theme,
        _languages = languages;

  /// Bootstrap the engine. Loads each [languages] grammar from
  /// `packages/syntax_highlight/grammars/<lang>.json` (bundled with the
  /// `syntax_highlight` package — no extra asset declarations needed in your
  /// `pubspec.yaml`).
  ///
  /// Pass [theme] from [MarkastTextMateThemes] (e.g. `await
  /// MarkastTextMateThemes.darkPlus()`) or build a custom one via
  /// `HighlighterTheme.loadFromAssets(...)`.
  ///
  /// Defaults to loading **all** languages this engine ships with — fast
  /// enough at startup (a few KB each). Pass a subset to reduce app launch
  /// time if you only need a few.
  static Future<MarkastTextMateHighlight> create({
    required HighlighterTheme theme,
    List<String> languages = allLanguages,
  }) async {
    await Highlighter.initialize(languages);
    return MarkastTextMateHighlight._(
      theme: theme,
      languages: Set<String>.from(languages),
    );
  }

  /// Every language `syntax_highlight` ships a grammar file for.
  static const List<String> allLanguages = <String>[
    'css', 'dart', 'go', 'html', 'java', 'javascript', 'json', 'kotlin',
    'python', 'rust', 'serverpod_protocol', 'sql', 'swift', 'typescript',
    'yaml',
  ];

  final HighlighterTheme _theme;
  final Set<String> _languages;

  /// Common shorthand aliases → canonical TextMate language names.
  static const Map<String, String> _aliases = {
    'js':       'javascript',
    'jsx':      'javascript',
    'mjs':      'javascript',
    'cjs':      'javascript',
    'ts':       'typescript',
    'tsx':      'typescript',
    'py':       'python',
    'yml':      'yaml',
    'kt':       'kotlin',
    'kts':      'kotlin',
    'rs':       'rust',
    'golang':   'go',
    'jsonc':    'json',
    'json5':    'json',
    'pgsql':    'sql',
    'mysql':    'sql',
    'sqlite':   'sql',
    'xhtml':    'html',
    'xml':      'html',
    'svg':      'html',
    'scss':     'css',
    'sass':     'css',
    'less':     'css',
  };

  String _canonical(String language) =>
      _aliases[language.toLowerCase()] ?? language.toLowerCase();

  @override
  TextSpan? highlight(String code, String language, TextStyle baseStyle) {
    final lang = _canonical(language);
    if (!_languages.contains(lang)) return null;
    try {
      final hl = Highlighter(language: lang, theme: _theme);
      final span = hl.highlight(code);
      // Wrap with the consumer-provided baseStyle so font family / size /
      // background (e.g. inline-code background) are honoured. The
      // syntax_highlight wrapper provides token colours; baseStyle provides
      // typography.
      return TextSpan(style: baseStyle, children: [span]);
    } catch (_) {
      return null;
    }
  }

  @override
  bool supports(String language) => _languages.contains(_canonical(language));

  /// Names of languages this engine has loaded.
  Set<String> get loadedLanguages => Set<String>.unmodifiable(_languages);
}
