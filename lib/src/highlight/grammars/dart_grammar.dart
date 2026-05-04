import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Dart grammar.
///
/// Improvements over `re_highlight`'s built-in:
///   * Full Dart 3.x keyword set (sealed, base, mixin, when, late, …).
///   * Nullable type recognition (`int?`, `List<String>?`, …).
///   * Annotations: `@override`, `@Deprecated('message')` with the argument
///     painted as a string.
///   * String interpolation `$var` and `${expr}` paint the expression with the
///     full host grammar — strings inside `${...}` are recursively painted as
///     strings via re_highlight's `refs` mechanism.
///   * `class | mixin | enum | extension | typedef` declarations extract the
///     title as `title.class_`.
///   * `void foo(...)` / `T foo(...)` extracts the function name as
///     `title.function_`.
///   * `///` doc comments are rendered as inline markdown.
///   * Comprehensive number matcher (hex, exponent, type suffixes).
final markastDartGrammar = (() {
  // ── Keywords ────────────────────────────────────────────────────────────
  const dartKeywords = <String>[
    'abstract', 'as', 'assert', 'async', 'await', 'base', 'break',
    'case', 'catch', 'class', 'const', 'continue', 'covariant',
    'default', 'deferred', 'do', 'dynamic', 'else', 'enum', 'export',
    'extends', 'extension', 'external', 'factory', 'final', 'finally',
    'for', 'Function', 'get', 'hide', 'if', 'implements', 'import', 'in',
    'interface', 'is', 'late', 'library', 'mixin', 'new', 'on', 'operator',
    'part', 'required', 'rethrow', 'return', 'sealed', 'set', 'show',
    'static', 'super', 'switch', 'sync', 'this', 'throw', 'try', 'typedef',
    'var', 'void', 'when', 'while', 'with', 'yield',
  ];

  const dartLiterals = <String>['true', 'false', 'null'];

  const dartBuiltins = <String>[
    'bool', 'double', 'int', 'num', 'String', 'Object', 'dynamic', 'Never', 'Null', 'void',
    'List', 'Map', 'Set', 'Iterable', 'Iterator', 'Future', 'Stream',
    'StreamController', 'Completer', 'Symbol', 'Type', 'Function',
    'DateTime', 'Duration', 'RegExp', 'Match', 'Pattern', 'Uri',
    'StringBuffer', 'StringSink', 'Stopwatch', 'Comparable', 'Comparator',
    'Exception', 'Error', 'StackTrace',
    'print', 'identical', 'identityHashCode',
  ];

  // ── Recursive interpolation ────────────────────────────────────────────
  // ${expr} re-enters the host grammar. Strings inside the expression are
  // painted as strings via the '~strings' ref declared on the root Mode.
  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$\{',
    end: r'\}',
    keywords: {
      'keyword':  dartKeywords,
      'literal':  dartLiterals,
      'built_in': dartBuiltins,
    },
    contains: <Mode>[
      Mode(ref: '~strings'),
      markastNumber,
    ],
  );

  // Bare $var (no braces).
  final substVar = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$[A-Za-z_][A-Za-z0-9_]*',
    relevance: 0,
  );

  // ── Strings (5 variants) ────────────────────────────────────────────────
  final strings = Mode(
    scope: MarkastScopes.string,
    variants: <Mode>[
      // Raw triple
      Mode(begin: r"r'''", end: r"'''"),
      Mode(begin: r'r"""', end: r'"""'),
      // Raw single line
      Mode(begin: r"r'", end: r"'", illegal: r'\n'),
      Mode(begin: r'r"', end: r'"', illegal: r'\n'),
      // Interpolated triple
      Mode(begin: r"'''", end: r"'''", contains: <Mode>[
        markastBackslashEscape,
        substVar,
        substExpr,
      ]),
      Mode(begin: r'"""', end: r'"""', contains: <Mode>[
        markastBackslashEscape,
        substVar,
        substExpr,
      ]),
      // Interpolated single-line
      Mode(begin: r"'", end: r"'", illegal: r'\n', contains: <Mode>[
        markastBackslashEscape,
        substVar,
        substExpr,
      ]),
      Mode(begin: r'"', end: r'"', illegal: r'\n', contains: <Mode>[
        markastBackslashEscape,
        substVar,
        substExpr,
      ]),
    ],
  );

  // ── Doc comments ────────────────────────────────────────────────────────
  final docCommentLine = Mode(
    scope: MarkastScopes.comment,
    begin: r'/{3,}\s?',
    end: r'$',
    contains: <Mode>[
      Mode(subLanguage: 'markdown', begin: r'.', end: r'$', relevance: 0),
      markastDocTag,
    ],
    relevance: 0,
  );

  final docCommentBlock = Mode(
    scope: MarkastScopes.comment,
    begin: r'/\*\*(?!/)',
    end: r'\*/',
    contains: <Mode>[markastDocTag],
    subLanguage: 'markdown',
    relevance: 0,
  );

  // ── Annotations ─────────────────────────────────────────────────────────
  final annotation = Mode(
    scope: MarkastScopes.meta,
    begin: r'@[A-Za-z_][A-Za-z0-9_]*',
    contains: <Mode>[
      Mode(
        begin: r'\(',
        end: r'\)',
        contains: <Mode>[
          Mode(ref: '~strings'),
          markastNumber,
          Mode(scope: MarkastScopes.literal, begin: r'\b(true|false|null)\b'),
        ],
      ),
    ],
    relevance: 0,
  );

  // ── Class-like declarations ─────────────────────────────────────────────
  final classDeclaration = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class mixin enum extension typedef',
    end: r'(?=[\{=;])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(beginKeywords: 'extends implements with on'),
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][A-Za-z0-9_]*'),
      Mode(begin: r'<', end: r'>', keywords: {
        'keyword': ['extends', 'super'],
        'built_in': dartBuiltins,
      }),
    ],
  );

  // ── Function declarations ───────────────────────────────────────────────
  final functionDeclaration = Mode(
    scope: MarkastScopes.functionName,
    begin: r'\b([A-Za-z_][\w$]*\s*)?[A-Za-z_][\w$]*\s*(?=\()',
    returnBegin: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_][\w$]*(?=\s*\()'),
    ],
    relevance: 0,
  );

  // ── Final assembly ──────────────────────────────────────────────────────
  return Mode(
    name: 'Dart',
    aliases: <String>['dart'],
    refs: <String, dynamic>{
      '~strings': strings,
    },
    keywords: {
      'keyword':  dartKeywords,
      'literal':  dartLiterals,
      'built_in': dartBuiltins,
      r'$pattern': r'[A-Za-z_$][\w$]*\??',
    },
    contains: <Mode>[
      strings,
      docCommentLine,
      docCommentBlock,
      lineComment(r'//'),
      markastBlockComment,
      classDeclaration,
      annotation,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'=>', relevance: 0),
      functionDeclaration,
    ],
  );
})();
