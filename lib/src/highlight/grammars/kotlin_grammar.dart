import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Kotlin grammar.
///
/// Improvements:
///   * String templates: `"$var"` and `"${expr}"` paint subst correctly.
///   * Annotations and `@param:Annotation` use-site targets.
///   * `fun name()`, `class Foo`, `object Foo`, `interface Foo` extract title.
///   * Raw strings (`"""…"""`) and char literals.
final markastKotlinGrammar = (() {
  const ktKeywords = <String>[
    'abstract', 'actual', 'annotation', 'as', 'break', 'by', 'catch', 'class',
    'companion', 'const', 'constructor', 'continue', 'crossinline', 'data',
    'do', 'dynamic', 'else', 'enum', 'expect', 'external', 'false', 'final',
    'finally', 'for', 'fun', 'get', 'if', 'import', 'in', 'infix', 'init',
    'inline', 'inner', 'interface', 'internal', 'is', 'lateinit', 'noinline',
    'null', 'object', 'open', 'operator', 'out', 'override', 'package',
    'private', 'protected', 'public', 'reified', 'return', 'sealed', 'set',
    'super', 'suspend', 'tailrec', 'this', 'throw', 'true', 'try', 'typealias',
    'typeof', 'val', 'value', 'var', 'vararg', 'when', 'where', 'while',
  ];

  const ktLiterals = <String>['true', 'false', 'null'];

  const ktBuiltins = <String>[
    'Any', 'Array', 'Boolean', 'Byte', 'Char', 'Double', 'Float', 'Int',
    'Long', 'Nothing', 'Number', 'Short', 'String', 'Unit',
    'List', 'Map', 'Set', 'MutableList', 'MutableMap', 'MutableSet',
    'Sequence', 'Iterable', 'Pair', 'Triple', 'Result', 'Lazy',
    'println', 'print', 'arrayOf', 'listOf', 'mapOf', 'setOf', 'lazy',
  ];

  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$\{',
    end: r'\}',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  ktKeywords,
      'literal':  ktLiterals,
      'built_in': ktBuiltins,
    },
  );

  final substVar = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$[A-Za-z_]\w*',
    relevance: 0,
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"""', end: r'"""',
           contains: <Mode>[substVar, substExpr]),
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape, substVar, substExpr]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'", illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  final annotation = Mode(
    scope: MarkastScopes.meta,
    begin: r'@(?:[a-z]+:)?[A-Za-z_]\w*',
    contains: <Mode>[
      Mode(begin: r'\(', end: r'\)', contains: <Mode>[strings, markastNumber]),
    ],
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class interface object enum',
    end: r'(?=[\{:<\(])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w]*'),
    ],
  );

  final funDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'fun',
    end: r'(?=[\(<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
    ],
  );

  return Mode(
    name: 'Kotlin',
    aliases: <String>['kotlin', 'kt', 'kts'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  ktKeywords,
      'literal':  ktLiterals,
      'built_in': ktBuiltins,
    },
    contains: <Mode>[
      lineComment(r'//'),
      markastBlockComment,
      strings,
      annotation,
      classDecl,
      funDecl,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'->', relevance: 0),
    ],
  );
})();
