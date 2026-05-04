import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Ruby grammar.
///
/// Improvements:
///   * Symbols `:foo`, `:'foo bar'`, `key:` painted as `symbol`.
///   * String interpolation `"#{expr}"` re-enters host grammar.
///   * `class Foo < Bar`, `module Foo`, `def name` extract titles.
///   * Heredocs `<<~END … END`.
///   * `@instance`, `@@class`, `$global` variables painted as `variable`.
final markastRubyGrammar = (() {
  const rbKeywords = <String>[
    'BEGIN', 'END', 'alias', 'and', 'begin', 'break', 'case', 'class', 'def',
    'defined?', 'do', 'else', 'elsif', 'end', 'ensure', 'false', 'for', 'if',
    'in', 'module', 'next', 'nil', 'not', 'or', 'redo', 'rescue', 'retry',
    'return', 'self', 'super', 'then', 'true', 'undef', 'unless', 'until',
    'when', 'while', 'yield', 'lambda', 'proc',
  ];

  const rbLiterals = <String>['true', 'false', 'nil'];

  const rbBuiltins = <String>[
    'Array', 'BasicObject', 'Class', 'Comparable', 'Complex', 'Enumerable',
    'Enumerator', 'Exception', 'Fiber', 'File', 'Float', 'Hash', 'Integer',
    'IO', 'Kernel', 'Method', 'Module', 'NilClass', 'Numeric', 'Object',
    'Proc', 'Range', 'Rational', 'Regexp', 'String', 'Struct', 'Symbol',
    'Thread', 'Time', 'TrueClass', 'FalseClass',
    'puts', 'print', 'p', 'pp', 'require', 'require_relative', 'load',
    'attr_reader', 'attr_writer', 'attr_accessor', 'include', 'extend',
    'raise', 'throw', 'catch',
  ];

  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'#\{',
    end: r'\}',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  rbKeywords,
      'literal':  rbLiterals,
      'built_in': rbBuiltins,
    },
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"',
           contains: <Mode>[markastBackslashEscape, substExpr]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'",
           contains: <Mode>[markastBackslashEscape]),
      // %w(...) word array
      Mode(scope: MarkastScopes.string, begin: r'%[wWiI]\(', end: r'\)'),
      // Heredoc
      Mode(scope: MarkastScopes.string,
           begin: r'<<[-~]?(\w+)', end: r'$',
           contains: <Mode>[substExpr]),
    ],
  );

  final symbols = Mode(
    scope: MarkastScopes.symbol,
    variants: <Mode>[
      Mode(begin: r":[A-Za-z_]\w*[!?=]?"),
      Mode(begin: r":'", end: r"'"),
      Mode(begin: r':"', end: r'"'),
      // Hash key: foo:
      Mode(begin: r'[A-Za-z_]\w*:(?=[^:])', relevance: 0),
    ],
    relevance: 0,
  );

  final variables = Mode(
    scope: MarkastScopes.variable,
    begin: r'(@@?|\$)[A-Za-z_]\w*',
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class module',
    end: r'$|;',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w:]*'),
      Mode(begin: r'<\s', contains: <Mode>[
        Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w:]*'),
      ]),
    ],
  );

  final defDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'def',
    end: r'$|;',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_][\w?!=]*'),
    ],
  );

  return Mode(
    name: 'Ruby',
    aliases: <String>['ruby', 'rb', 'gemspec', 'podspec', 'thor', 'irb'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  rbKeywords,
      'literal':  rbLiterals,
      'built_in': rbBuiltins,
    },
    contains: <Mode>[
      lineComment(r'#'),
      // =begin / =end block comment
      Mode(scope: MarkastScopes.comment, begin: r'^=begin', end: r'^=end'),
      strings,
      symbols,
      variables,
      classDecl,
      defDecl,
      markastNumber,
    ],
  );
})();
