import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Java grammar.
///
/// Improvements:
///   * Annotations `@Override`, `@Deprecated("...")` painted as `meta`.
///   * `class Foo extends Bar implements Baz` — Foo as title, Bar/Baz as type.
///   * Generic type parameters `<T extends Comparable<T>>` highlighted.
///   * Text blocks (`"""..."""`).
final markastJavaGrammar = (() {
  const javaKeywords = <String>[
    'abstract', 'assert', 'break', 'case', 'catch', 'class', 'const',
    'continue', 'default', 'do', 'else', 'enum', 'extends', 'final',
    'finally', 'for', 'goto', 'if', 'implements', 'import', 'instanceof',
    'interface', 'native', 'new', 'package', 'private', 'protected',
    'public', 'return', 'static', 'strictfp', 'super', 'switch',
    'synchronized', 'this', 'throw', 'throws', 'transient', 'try',
    'volatile', 'while', 'yield', 'record', 'sealed', 'non-sealed',
    'permits', 'var',
  ];

  const javaLiterals = <String>['true', 'false', 'null'];

  const javaBuiltins = <String>[
    'boolean', 'byte', 'char', 'double', 'float', 'int', 'long', 'short',
    'void',
    'String', 'Integer', 'Boolean', 'Long', 'Double', 'Float', 'Character',
    'Object', 'Class', 'Exception', 'RuntimeException', 'Throwable',
    'List', 'ArrayList', 'Map', 'HashMap', 'Set', 'HashSet', 'Collection',
    'Iterator', 'Optional', 'Stream', 'CompletableFuture', 'Future',
    'Thread', 'Runnable', 'System', 'Math',
  ];

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"""', end: r'"""',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'", illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  final annotation = Mode(
    scope: MarkastScopes.meta,
    begin: r'@[A-Za-z_]\w*',
    contains: <Mode>[
      Mode(begin: r'\(', end: r'\)', contains: <Mode>[strings, markastNumber]),
    ],
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class interface enum record',
    end: r'(?=[\{<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(beginKeywords: 'extends implements permits'),
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w]*'),
    ],
  );

  return Mode(
    name: 'Java',
    aliases: <String>['java', 'jsp'],
    keywords: {
      'keyword':  javaKeywords,
      'literal':  javaLiterals,
      'built_in': javaBuiltins,
    },
    contains: <Mode>[
      lineComment(r'//'),
      markastBlockComment,
      strings,
      annotation,
      classDecl,
      markastNumber,
    ],
  );
})();
