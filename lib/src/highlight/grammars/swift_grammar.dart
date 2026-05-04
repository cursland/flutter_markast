import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Swift grammar.
///
/// Improvements:
///   * String interpolation `\(expr)` painted as subst with re-entrant
///     numbers / strings.
///   * Attributes (`@objc`, `@available(...)`) painted as `meta`.
///   * `func name()`, `class Foo`, `struct Foo`, `enum Foo`, `protocol Foo`
///     extract title.
final markastSwiftGrammar = (() {
  const swKeywords = <String>[
    'as', 'associatedtype', 'async', 'await', 'break', 'case', 'catch',
    'class', 'continue', 'default', 'defer', 'deinit', 'do', 'else', 'enum',
    'extension', 'fallthrough', 'fileprivate', 'final', 'for', 'func',
    'guard', 'if', 'import', 'in', 'indirect', 'init', 'inout', 'internal',
    'is', 'lazy', 'let', 'mutating', 'nonmutating', 'open', 'operator',
    'override', 'private', 'protocol', 'public', 'repeat', 'required',
    'rethrows', 'return', 'self', 'Self', 'static', 'struct', 'subscript',
    'super', 'switch', 'throw', 'throws', 'try', 'typealias', 'var', 'where',
    'while', 'some', 'any', 'actor', 'nonisolated',
  ];

  const swLiterals = <String>['true', 'false', 'nil'];

  const swBuiltins = <String>[
    'Bool', 'Int', 'Int8', 'Int16', 'Int32', 'Int64',
    'UInt', 'UInt8', 'UInt16', 'UInt32', 'UInt64',
    'Float', 'Double', 'Character', 'String', 'Substring',
    'Array', 'Dictionary', 'Set', 'Optional', 'Result', 'Range', 'ClosedRange',
    'Any', 'AnyObject', 'Void', 'Never',
    'print', 'debugPrint', 'fatalError', 'precondition', 'assert',
  ];

  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\\\(',
    end: r'\)',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  swKeywords,
      'literal':  swLiterals,
      'built_in': swBuiltins,
    },
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"""', end: r'"""',
           contains: <Mode>[markastBackslashEscape, substExpr]),
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape, substExpr]),
    ],
  );

  final attribute = Mode(
    scope: MarkastScopes.meta,
    begin: r'@[A-Za-z_]\w*',
    contains: <Mode>[
      Mode(begin: r'\(', end: r'\)', contains: <Mode>[strings, markastNumber]),
    ],
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class struct enum protocol extension actor',
    end: r'(?=[\{:<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w]*'),
    ],
  );

  final funcDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'func',
    end: r'(?=[\(<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
    ],
  );

  return Mode(
    name: 'Swift',
    aliases: <String>['swift'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  swKeywords,
      'literal':  swLiterals,
      'built_in': swBuiltins,
    },
    contains: <Mode>[
      lineComment(r'//'),
      markastBlockComment,
      strings,
      attribute,
      classDecl,
      funcDecl,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'->', relevance: 0),
    ],
  );
})();
