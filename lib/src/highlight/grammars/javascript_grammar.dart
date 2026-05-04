import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced JavaScript grammar.
///
/// Improvements over the built-in:
///   * Template literals with `${...}` interpolation re-entering host grammar.
///   * Tagged templates: `` html`<div>${value}</div>` `` — tag painted as
///     `template-tag`.
///   * JSX attributes painted as `attr` (when nested inside `<Tag .../>`).
///   * `class Foo extends Bar` — names painted as `title.class_` / type.
///   * `function name()` and `name = () =>` — names painted as
///     `title.function_`.
///   * Decorators (TC39 stage 3): `@Component(...)` painted as `meta`.
final markastJavaScriptGrammar = (() {
  const jsKeywords = <String>[
    'as', 'async', 'await', 'break', 'case', 'catch', 'class', 'const',
    'continue', 'debugger', 'default', 'delete', 'do', 'else', 'export',
    'extends', 'finally', 'for', 'from', 'function', 'get', 'if', 'import',
    'in', 'instanceof', 'let', 'new', 'of', 'return', 'set', 'static',
    'super', 'switch', 'this', 'throw', 'try', 'typeof', 'var', 'void',
    'while', 'with', 'yield',
  ];

  const jsLiterals = <String>['true', 'false', 'null', 'undefined', 'NaN', 'Infinity'];

  const jsBuiltins = <String>[
    'Array', 'ArrayBuffer', 'Boolean', 'DataView', 'Date', 'Error',
    'EvalError', 'Float32Array', 'Float64Array', 'Function', 'Generator',
    'GeneratorFunction', 'Int8Array', 'Int16Array', 'Int32Array', 'Map',
    'Math', 'Number', 'Object', 'Promise', 'Proxy', 'RangeError',
    'ReferenceError', 'Reflect', 'RegExp', 'Set', 'String', 'Symbol',
    'SyntaxError', 'TypeError', 'URIError', 'Uint8Array', 'Uint8ClampedArray',
    'Uint16Array', 'Uint32Array', 'WeakMap', 'WeakSet',
    'console', 'document', 'window', 'globalThis', 'process', 'require',
    'module', 'exports', '__dirname', '__filename',
    'JSON', 'Intl', 'parseInt', 'parseFloat', 'isNaN', 'isFinite',
    'encodeURI', 'encodeURIComponent', 'decodeURI', 'decodeURIComponent',
  ];

  // ── Template literal interpolation ──────────────────────────────────────
  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$\{',
    end: r'\}',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  jsKeywords,
      'literal':  jsLiterals,
      'built_in': jsBuiltins,
    },
  );

  // ── Strings ─────────────────────────────────────────────────────────────
  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'", illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      // Template literal
      Mode(scope: MarkastScopes.string, begin: r'`', end: r'`',
           contains: <Mode>[markastBackslashEscape, substExpr]),
    ],
  );

  // ── Decorator ───────────────────────────────────────────────────────────
  final decorator = Mode(
    scope: MarkastScopes.meta,
    begin: r'@[A-Za-z_$][\w$]*',
    contains: <Mode>[
      Mode(
        begin: r'\(',
        end: r'\)',
        contains: <Mode>[strings, markastNumber],
      ),
    ],
    relevance: 0,
  );

  // ── class / function declarations ───────────────────────────────────────
  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class',
    end: r'(?=[\{])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(beginKeywords: 'extends'),
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_$][\w$]*'),
    ],
  );

  final fnDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'function',
    end: r'(?=\()',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_$][\w$]*'),
    ],
  );

  // ── Regex literal (conservative: must follow common pre-token) ──────────
  final regexLiteral = Mode(
    scope: MarkastScopes.regexp,
    begin: r'(?<=[=(,!&|?:;\[\{\}]|^|\breturn\s+)/(?![/*])',
    end: r'/[gimsuy]*',
    contains: <Mode>[
      markastBackslashEscape,
      Mode(begin: r'\[', end: r'\]', relevance: 0,
           contains: <Mode>[markastBackslashEscape]),
    ],
    relevance: 0,
  );

  return Mode(
    name: 'JavaScript',
    aliases: <String>['js', 'jsx', 'mjs', 'cjs'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  jsKeywords,
      'literal':  jsLiterals,
      'built_in': jsBuiltins,
    },
    contains: <Mode>[
      strings,
      lineComment(r'//'),
      markastBlockComment,
      decorator,
      classDecl,
      fnDecl,
      regexLiteral,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'=>', relevance: 0),
    ],
  );
})();
