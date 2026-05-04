import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced C grammar.
///
/// Improvements:
///   * Preprocessor directives `#include`, `#define`, `#ifdef` painted as `meta`
///     with the included path as `meta-string`.
///   * Numeric literals with suffixes (`123u`, `0xffULL`).
///   * `struct` / `enum` / `union` / `typedef` declarations extract title.
final markastCGrammar = (() {
  const cKeywords = <String>[
    'auto', 'break', 'case', 'continue', 'default', 'do', 'else', 'enum',
    'extern', 'for', 'goto', 'if', 'inline', 'register', 'restrict', 'return',
    'sizeof', 'static', 'struct', 'switch', 'typedef', 'union', 'volatile',
    'while', '_Alignas', '_Alignof', '_Atomic', '_Bool', '_Complex',
    '_Generic', '_Imaginary', '_Noreturn', '_Static_assert', '_Thread_local',
    'const',
  ];

  const cLiterals = <String>['true', 'false', 'NULL', 'nullptr'];

  const cBuiltins = <String>[
    'char', 'double', 'float', 'int', 'long', 'short', 'signed', 'unsigned',
    'void', 'size_t', 'ssize_t', 'ptrdiff_t',
    'int8_t', 'int16_t', 'int32_t', 'int64_t',
    'uint8_t', 'uint16_t', 'uint32_t', 'uint64_t',
    'FILE', 'bool', 'wchar_t',
    'printf', 'scanf', 'fprintf', 'fscanf', 'sprintf', 'snprintf',
    'malloc', 'calloc', 'free', 'realloc', 'memcpy', 'memset', 'strcpy',
    'strlen', 'strcmp', 'strncmp',
  ];

  // Preprocessor directive
  final preprocessor = Mode(
    scope: MarkastScopes.meta,
    begin: r'#\s*[A-Za-z]+',
    end: r'$',
    keywords: {
      'keyword': ['if', 'else', 'elif', 'endif', 'define', 'undef',
                   'warning', 'error', 'line', 'pragma', 'ifdef', 'ifndef',
                   'include'],
    },
    contains: <Mode>[
      // <stdio.h> style include
      Mode(scope: MarkastScopes.metaString, begin: r'<', end: r'>'),
      Mode(scope: MarkastScopes.metaString, begin: r'"', end: r'"'),
      lineComment(r'//'),
      markastBlockComment,
    ],
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'(L|u8?|U)?"', end: r'"',
           illegal: r'\\n', contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r"(L|u8?|U)?'", end: r"'",
           illegal: r'\\n', contains: <Mode>[markastBackslashEscape]),
    ],
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'struct enum union',
    end: r'(?=[\{;])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_]\w*'),
    ],
    relevance: 0,
  );

  return Mode(
    name: 'C',
    aliases: <String>['c', 'h'],
    keywords: {
      'keyword':  cKeywords,
      'literal':  cLiterals,
      'built_in': cBuiltins,
    },
    contains: <Mode>[
      preprocessor,
      lineComment(r'//'),
      markastBlockComment,
      strings,
      classDecl,
      markastNumber,
    ],
  );
})();
