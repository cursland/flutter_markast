import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced TypeScript grammar.
///
/// Builds on top of the JavaScript grammar with:
///   * TS-specific keywords: `interface`, `type`, `namespace`, `module`,
///     `enum`, `readonly`, `keyof`, `infer`, `is`, `satisfies`, `abstract`,
///     `declare`, `public`, `private`, `protected`, `override`, `out`, `in`.
///   * Type annotations: `: Foo<T>` — Foo painted as `type`.
///   * Decorators (e.g. `@Component(...)`).
///   * `interface Foo {}` / `type Foo =` extract title.
final markastTypeScriptGrammar = (() {
  const tsKeywords = <String>[
    // JS
    'as', 'async', 'await', 'break', 'case', 'catch', 'class', 'const',
    'continue', 'debugger', 'default', 'delete', 'do', 'else', 'export',
    'extends', 'finally', 'for', 'from', 'function', 'get', 'if', 'import',
    'in', 'instanceof', 'let', 'new', 'of', 'return', 'set', 'static',
    'super', 'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void',
    'while', 'with', 'yield',
    // TS
    'abstract', 'declare', 'enum', 'implements', 'interface', 'is', 'keyof',
    'module', 'namespace', 'never', 'override', 'private', 'protected',
    'public', 'readonly', 'type', 'unique', 'unknown', 'satisfies', 'infer',
    'asserts', 'out',
  ];

  const tsLiterals = <String>['true', 'false', 'null', 'undefined', 'NaN', 'Infinity'];

  const tsBuiltins = <String>[
    // Primitives
    'string', 'number', 'boolean', 'object', 'any', 'unknown', 'never', 'void',
    'bigint', 'symbol',
    // Utility types
    'Partial', 'Required', 'Readonly', 'Record', 'Pick', 'Omit', 'Exclude',
    'Extract', 'NonNullable', 'Parameters', 'ConstructorParameters',
    'ReturnType', 'InstanceType', 'ThisParameterType', 'OmitThisParameter',
    'Awaited', 'Uppercase', 'Lowercase', 'Capitalize', 'Uncapitalize',
    // Common
    'Array', 'Date', 'Error', 'Function', 'Map', 'Math', 'Object', 'Promise',
    'Proxy', 'RegExp', 'Set', 'String', 'Symbol', 'WeakMap', 'WeakSet',
    'console', 'document', 'window', 'globalThis', 'process',
    'JSON', 'Intl',
  ];

  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$\{',
    end: r'\}',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  tsKeywords,
      'literal':  tsLiterals,
      'built_in': tsBuiltins,
    },
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'", illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r'`', end: r'`',
           contains: <Mode>[markastBackslashEscape, substExpr]),
    ],
  );

  final decorator = Mode(
    scope: MarkastScopes.meta,
    begin: r'@[A-Za-z_$][\w$]*',
    contains: <Mode>[
      Mode(begin: r'\(', end: r'\)', contains: <Mode>[strings, markastNumber]),
    ],
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class interface',
    end: r'(?=[\{])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(beginKeywords: 'extends implements'),
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_$][\w$]*'),
    ],
  );

  final typeAlias = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'type',
    end: r'(?==)',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_$][\w$]*'),
    ],
  );

  final fnDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'function',
    end: r'(?=[\(<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_$][\w$]*'),
    ],
  );

  return Mode(
    name: 'TypeScript',
    aliases: <String>['ts', 'tsx', 'mts', 'cts'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  tsKeywords,
      'literal':  tsLiterals,
      'built_in': tsBuiltins,
    },
    contains: <Mode>[
      strings,
      lineComment(r'//'),
      markastBlockComment,
      decorator,
      classDecl,
      typeAlias,
      fnDecl,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'=>', relevance: 0),
    ],
  );
})();
