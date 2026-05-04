import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Go grammar.
///
/// Improvements:
///   * Backtick raw strings highlighted as `string`.
///   * Build tags `// +build foo` and `//go:build` rendered as `meta`.
///   * `func (recv *T) Name(...)` extracts the function name as
///     `title.function_`.
///   * `type Foo struct {}` extracts Foo as `title.class_`.
final markastGoGrammar = (() {
  const goKeywords = <String>[
    'break', 'case', 'chan', 'const', 'continue', 'default', 'defer', 'else',
    'fallthrough', 'for', 'func', 'go', 'goto', 'if', 'import', 'interface',
    'map', 'package', 'range', 'return', 'select', 'struct', 'switch', 'type',
    'var',
  ];

  const goLiterals = <String>['true', 'false', 'iota', 'nil'];

  const goBuiltins = <String>[
    'append', 'cap', 'clear', 'close', 'complex', 'copy', 'delete', 'imag',
    'len', 'make', 'max', 'min', 'new', 'panic', 'print', 'println', 'real',
    'recover',
    // Types
    'any', 'bool', 'byte', 'complex128', 'complex64', 'comparable', 'error',
    'float32', 'float64', 'int', 'int8', 'int16', 'int32', 'int64', 'rune',
    'string', 'uint', 'uint8', 'uint16', 'uint32', 'uint64', 'uintptr',
  ];

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      // Raw string
      Mode(scope: MarkastScopes.string, begin: r'`', end: r'`'),
      // Rune literal
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'", illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  // //go:build / // +build directives
  final buildTag = Mode(
    scope: MarkastScopes.meta,
    begin: r'//\s*(go:build|\+build)\b',
    end: r'$',
    relevance: 10,
  );

  final funcDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'func',
    end: r'(?=\()',
    excludeEnd: true,
    contains: <Mode>[
      // Receiver
      Mode(begin: r'\(', end: r'\)', contains: <Mode>[
        Mode(scope: MarkastScopes.type, begin: r'\*?[A-Za-z_]\w*\b'),
      ]),
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
    ],
    relevance: 0,
  );

  final typeDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'type',
    end: r'(?=\s+(struct|interface|=|\bfunc\b))',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_]\w*'),
    ],
  );

  return Mode(
    name: 'Go',
    aliases: <String>['go', 'golang'],
    keywords: {
      'keyword':  goKeywords,
      'literal':  goLiterals,
      'built_in': goBuiltins,
    },
    contains: <Mode>[
      buildTag,
      lineComment(r'//'),
      markastBlockComment,
      strings,
      typeDecl,
      funcDecl,
      markastNumber,
    ],
  );
})();
