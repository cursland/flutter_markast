import 'package:re_highlight/re_highlight.dart';

import 'bash_grammar.dart';
import 'c_grammar.dart';
import 'cpp_grammar.dart';
import 'csharp_grammar.dart';
import 'css_grammar.dart';
import 'dart_grammar.dart';
import 'go_grammar.dart';
import 'html_grammar.dart';
import 'java_grammar.dart';
import 'javascript_grammar.dart';
import 'json_grammar.dart';
import 'kotlin_grammar.dart';
import 'markdown_grammar.dart';
import 'php_grammar.dart';
import 'plantuml_grammar.dart';
import 'python_grammar.dart';
import 'ruby_grammar.dart';
import 'rust_grammar.dart';
import 'sql_grammar.dart';
import 'swift_grammar.dart';
import 'typescript_grammar.dart';
import 'yaml_grammar.dart';

/// Registry of Markast's enhanced highlight grammars.
///
/// These grammars are designed to be drop-in replacements for the equivalent
/// `re_highlight` built-in modules. They emit the **same scope vocabulary**
/// (`keyword`, `string`, `number`, `meta`, `title.class_`, `title.function_`,
/// …) so that every existing theme in `MarkastCodeThemes` continues to work
/// without modification — the only thing that improves is *what* gets
/// classified as which scope.
///
/// `MarkastHighlightTheme` registers these on top of `re_highlight`'s
/// built-in catalog. Languages not covered here fall through to the built-in
/// grammar; languages covered here get the enhanced version. The set is
/// intentionally focused on the most-used languages in technical
/// documentation — extending it later is a matter of adding one file and
/// one entry to [all] below.
abstract final class MarkastGrammars {
  /// All enhanced grammars keyed by canonical name.
  ///
  /// These names are what `Highlight.registerLanguage` stores; aliases
  /// declared inside each `Mode` (e.g. `js` for JavaScript) are registered
  /// automatically by the engine.
  static final Map<String, Mode> all = <String, Mode>{
    'dart':       markastDartGrammar,
    'python':     markastPythonGrammar,
    'javascript': markastJavaScriptGrammar,
    'typescript': markastTypeScriptGrammar,
    'go':         markastGoGrammar,
    'rust':       markastRustGrammar,
    'java':       markastJavaGrammar,
    'kotlin':     markastKotlinGrammar,
    'swift':      markastSwiftGrammar,
    'csharp':     markastCSharpGrammar,
    'cpp':        markastCppGrammar,
    'c':          markastCGrammar,
    'ruby':       markastRubyGrammar,
    'php':        markastPhpGrammar,
    'sql':        markastSqlGrammar,
    'bash':       markastBashGrammar,
    'yaml':       markastYamlGrammar,
    'json':       markastJsonGrammar,
    'markdown':   markastMarkdownGrammar,
    'plantuml':   markastPlantUmlGrammar,
    'html':       markastHtmlGrammar,
    'css':        markastCssGrammar,
  };

  /// Canonical names of every language that has an enhanced grammar.
  static List<String> get supportedLanguages => all.keys.toList(growable: false);
}
