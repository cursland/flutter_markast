import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced C++ grammar.
///
/// Improvements over C:
///   * Modern keywords (`constexpr`, `consteval`, `concept`, `requires`,
///     `co_await`, `co_yield`, `co_return`, etc.).
///   * `class Foo : public Bar`, `struct`, `union`, `template`.
///   * Lambda capture `[&, this]` painted as `params`.
///   * Raw string literals `R"delim(...)delim"`.
final markastCppGrammar = (() {
  const cppKeywords = <String>[
    // C-shared
    'auto', 'break', 'case', 'continue', 'default', 'do', 'else', 'enum',
    'extern', 'for', 'goto', 'if', 'inline', 'register', 'return',
    'sizeof', 'static', 'struct', 'switch', 'typedef', 'union', 'volatile',
    'while', 'const', 'restrict',
    // C++-only
    'alignas', 'alignof', 'and', 'and_eq', 'asm', 'bitand', 'bitor',
    'catch', 'class', 'compl', 'concept', 'consteval', 'constexpr',
    'constinit', 'const_cast', 'co_await', 'co_return', 'co_yield', 'decltype',
    'delete', 'dynamic_cast', 'explicit', 'export', 'final', 'friend',
    'mutable', 'namespace', 'new', 'noexcept', 'not', 'not_eq', 'nullptr',
    'operator', 'or', 'or_eq', 'override', 'private', 'protected', 'public',
    'reinterpret_cast', 'requires', 'static_assert', 'static_cast',
    'template', 'this', 'thread_local', 'throw', 'try', 'typeid', 'typename',
    'using', 'virtual', 'xor', 'xor_eq',
  ];

  const cppLiterals = <String>['true', 'false', 'NULL', 'nullptr'];

  const cppBuiltins = <String>[
    'char', 'char8_t', 'char16_t', 'char32_t', 'wchar_t',
    'double', 'float', 'int', 'long', 'short', 'signed', 'unsigned',
    'void', 'bool', 'size_t', 'ptrdiff_t',
    'std', 'string', 'string_view', 'wstring', 'vector', 'array', 'list',
    'map', 'unordered_map', 'set', 'unordered_set', 'pair', 'tuple',
    'shared_ptr', 'unique_ptr', 'weak_ptr', 'optional', 'variant', 'any',
    'function', 'thread', 'mutex', 'lock_guard', 'unique_lock', 'future',
    'promise', 'cout', 'cin', 'cerr', 'endl',
  ];

  final preprocessor = Mode(
    scope: MarkastScopes.meta,
    begin: r'#\s*[A-Za-z]+',
    end: r'$',
    keywords: {
      'keyword': ['if', 'else', 'elif', 'endif', 'define', 'undef',
                   'warning', 'error', 'line', 'pragma', 'ifdef', 'ifndef',
                   'include', 'import', 'export'],
    },
    contains: <Mode>[
      Mode(scope: MarkastScopes.metaString, begin: r'<', end: r'>'),
      Mode(scope: MarkastScopes.metaString, begin: r'"', end: r'"'),
    ],
  );

  final strings = Mode(
    variants: <Mode>[
      // Raw string with delimiter: R"delim( ... )delim"
      Mode(scope: MarkastScopes.string, begin: r'(?:[uUL]|u8)?R"([^()\\\s]{0,16})\(',
           end: r'\)\1"'),
      Mode(scope: MarkastScopes.string, begin: r'(?:[uUL]|u8)?"', end: r'"',
           illegal: r'\\n', contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r"(?:[uUL]|u8)?'", end: r"'",
           illegal: r'\\n', contains: <Mode>[markastBackslashEscape]),
    ],
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class struct union enum',
    end: r'(?=[\{;])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(beginKeywords: 'public protected private virtual'),
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_]\w*'),
    ],
    relevance: 0,
  );

  return Mode(
    name: 'C++',
    aliases: <String>['cpp', 'c++', 'cc', 'cxx', 'hpp', 'hh', 'hxx', 'h++'],
    keywords: {
      'keyword':  cppKeywords,
      'literal':  cppLiterals,
      'built_in': cppBuiltins,
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
