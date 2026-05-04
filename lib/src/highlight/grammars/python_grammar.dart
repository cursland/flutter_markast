import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Python grammar.
///
/// Improvements over the built-in:
///   * Full f-string support: `f"{expr}"` highlights the expression as a
///     subst block with re-entrant numbers / strings / keywords.
///   * Decorators (`@app.route(...)`) painted as `meta`, with arguments
///     re-entering the host grammar.
///   * `class Foo(Base):` — `Foo` painted as `title.class_`, `Base` as type.
///   * `def foo(...)` — `foo` painted as `title.function_`.
///   * All triple-quoted variants, byte strings, raw strings, raw f-strings.
///   * `self`, `cls` painted as variables.
final markastPythonGrammar = (() {
  const pyKeywords = <String>[
    'and', 'as', 'assert', 'async', 'await', 'break', 'class', 'continue',
    'def', 'del', 'elif', 'else', 'except', 'finally', 'for', 'from',
    'global', 'if', 'import', 'in', 'is', 'lambda', 'match', 'case',
    'nonlocal', 'not', 'or', 'pass', 'raise', 'return', 'try', 'while',
    'with', 'yield',
  ];

  const pyLiterals = <String>['True', 'False', 'None', 'NotImplemented', 'Ellipsis'];

  const pyBuiltins = <String>[
    'abs', 'all', 'any', 'ascii', 'bin', 'bool', 'bytearray', 'bytes',
    'callable', 'chr', 'classmethod', 'compile', 'complex', 'delattr',
    'dict', 'dir', 'divmod', 'enumerate', 'eval', 'exec', 'filter', 'float',
    'format', 'frozenset', 'getattr', 'globals', 'hasattr', 'hash', 'help',
    'hex', 'id', 'input', 'int', 'isinstance', 'issubclass', 'iter', 'len',
    'list', 'locals', 'map', 'max', 'memoryview', 'min', 'next', 'object',
    'oct', 'open', 'ord', 'pow', 'print', 'property', 'range', 'repr',
    'reversed', 'round', 'set', 'setattr', 'slice', 'sorted', 'staticmethod',
    'str', 'sum', 'super', 'tuple', 'type', 'vars', 'zip',
    // Common stdlib that's often "feels built-in"
    'self', 'cls',
  ];

  // ── F-string interpolation ──────────────────────────────────────────────
  final fSubst = Mode(
    scope: MarkastScopes.subst,
    begin: r'\{(?!\{)',
    end: r'\}',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  pyKeywords,
      'literal':  pyLiterals,
      'built_in': pyBuiltins,
    },
  );

  // ── Strings (regular + f-string + raw + bytes) ──────────────────────────
  final strings = Mode(
    scope: MarkastScopes.string,
    variants: <Mode>[
      // Triple f-strings
      Mode(begin: r'(f|F|rf|fr|FR|RF)"""', end: r'"""', contains: <Mode>[
        markastBackslashEscape, fSubst,
      ]),
      Mode(begin: r"(f|F|rf|fr|FR|RF)'''", end: r"'''", contains: <Mode>[
        markastBackslashEscape, fSubst,
      ]),
      // Single-line f-strings
      Mode(begin: r'(f|F|rf|fr|FR|RF)"', end: r'"', illegal: r'\n', contains: <Mode>[
        markastBackslashEscape, fSubst,
      ]),
      Mode(begin: r"(f|F|rf|fr|FR|RF)'", end: r"'", illegal: r'\n', contains: <Mode>[
        markastBackslashEscape, fSubst,
      ]),
      // Triple regular / byte / raw
      Mode(begin: r'(b|B|r|R|br|BR|rb|RB|u|U)?"""', end: r'"""',
           contains: <Mode>[markastBackslashEscape]),
      Mode(begin: r"(b|B|r|R|br|BR|rb|RB|u|U)?'''", end: r"'''",
           contains: <Mode>[markastBackslashEscape]),
      // Single-line regular / byte / raw
      Mode(begin: r'(b|B|r|R|br|BR|rb|RB|u|U)?"', end: r'"', illegal: r'\n',
           contains: <Mode>[markastBackslashEscape]),
      Mode(begin: r"(b|B|r|R|br|BR|rb|RB|u|U)?'", end: r"'", illegal: r'\n',
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  // ── Decorators ──────────────────────────────────────────────────────────
  final decorator = Mode(
    scope: MarkastScopes.meta,
    begin: r'@[A-Za-z_][\w.]*',
    contains: <Mode>[
      Mode(
        begin: r'\(',
        end: r'\)',
        contains: <Mode>[
          strings,
          markastNumber,
          Mode(scope: MarkastScopes.literal, begin: r'\b(True|False|None)\b'),
        ],
      ),
    ],
    relevance: 0,
  );

  // ── class / def ─────────────────────────────────────────────────────────
  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class',
    end: r'(?=[\(:])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_]\w*'),
    ],
  );

  final defDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'def',
    end: r'(?=\()',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
    ],
  );

  return Mode(
    name: 'Python',
    aliases: <String>['python', 'py', 'gyp', 'ipython'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  pyKeywords,
      'literal':  pyLiterals,
      'built_in': pyBuiltins,
    },
    illegal: r'(</|->|\?)|=>',
    contains: <Mode>[
      strings,
      lineComment(r'#'),
      decorator,
      classDecl,
      defDecl,
      markastNumber,
    ],
  );
})();
