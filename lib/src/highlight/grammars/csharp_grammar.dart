import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced C# grammar.
///
/// Improvements:
///   * Interpolated strings: `$"text {expr}"` and verbatim `@"…"` and
///     `$@"…"` / `@$"…"` combos.
///   * Attributes `[Serializable]` / `[Obsolete("msg")]` painted as `meta`.
///   * `class Foo : Bar`, `interface IFoo`, `record`, `struct` extract title.
final markastCSharpGrammar = (() {
  const csKeywords = <String>[
    'abstract', 'add', 'alias', 'as', 'ascending', 'async', 'await', 'base',
    'break', 'by', 'case', 'catch', 'checked', 'class', 'const', 'continue',
    'default', 'delegate', 'descending', 'do', 'dynamic', 'else', 'enum',
    'equals', 'event', 'explicit', 'extern', 'false', 'finally', 'fixed',
    'for', 'foreach', 'from', 'get', 'global', 'goto', 'group', 'if',
    'implicit', 'in', 'init', 'interface', 'internal', 'into', 'is', 'join',
    'let', 'lock', 'namespace', 'new', 'on', 'operator', 'orderby', 'out',
    'override', 'params', 'partial', 'private', 'protected', 'public',
    'readonly', 'record', 'ref', 'remove', 'required', 'return', 'sealed',
    'select', 'set', 'sizeof', 'stackalloc', 'static', 'struct', 'switch',
    'this', 'throw', 'true', 'try', 'typeof', 'unchecked', 'unsafe', 'using',
    'value', 'var', 'virtual', 'void', 'volatile', 'when', 'where', 'while',
    'with', 'yield', 'nameof',
  ];

  const csLiterals = <String>['true', 'false', 'null', 'default'];

  const csBuiltins = <String>[
    'bool', 'byte', 'char', 'decimal', 'double', 'float', 'int', 'long',
    'object', 'sbyte', 'short', 'string', 'uint', 'ulong', 'ushort', 'nint',
    'nuint',
    'String', 'Object', 'Boolean', 'Char', 'Int32', 'Int64', 'Double',
    'Decimal', 'Guid', 'DateTime', 'TimeSpan', 'Type',
    'List', 'Dictionary', 'IEnumerable', 'IList', 'IDictionary', 'Task',
    'ValueTask', 'Action', 'Func', 'Predicate', 'Span', 'ReadOnlySpan',
    'Console', 'Math',
  ];

  // Strings: regular, verbatim @"...", interpolated $"...{x}...",
  // verbatim+interpolated $@"..." or @$"..."
  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\{(?!\{)',
    end: r'\}',
    contains: <Mode>[markastNumber, Mode(ref: '~strings')],
    keywords: {
      'keyword':  csKeywords,
      'literal':  csLiterals,
      'built_in': csBuiltins,
    },
  );

  final strings = Mode(
    variants: <Mode>[
      // $@"..." or @$"..." (verbatim + interpolated)
      Mode(scope: MarkastScopes.string,
           begin: r'(\$@|@\$)"', end: r'"',
           contains: <Mode>[substExpr]),
      // @"..." verbatim
      Mode(scope: MarkastScopes.string, begin: r'@"', end: r'"',
           contains: <Mode>[Mode(begin: r'""')]),
      // $"..." interpolated
      Mode(scope: MarkastScopes.string, begin: r'\$"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape, substExpr]),
      // Regular
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"', illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'", illegal: r'\\n',
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  final attribute = Mode(
    scope: MarkastScopes.meta,
    begin: r'\[(?!\s*\d)',
    end: r'\]',
    contains: <Mode>[strings, markastNumber],
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class interface struct enum record',
    end: r'(?=[\{:<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w]*'),
    ],
  );

  return Mode(
    name: 'C#',
    aliases: <String>['cs', 'c#', 'csharp'],
    refs: <String, dynamic>{'~strings': strings},
    keywords: {
      'keyword':  csKeywords,
      'literal':  csLiterals,
      'built_in': csBuiltins,
    },
    contains: <Mode>[
      lineComment(r'///'),
      lineComment(r'//'),
      markastBlockComment,
      strings,
      attribute,
      classDecl,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'=>', relevance: 0),
    ],
  );
})();
