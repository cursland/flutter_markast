import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced PHP grammar.
///
/// Improvements:
///   * `<?php`, `?>` tags painted as `meta`.
///   * Variables `$foo` painted as `variable`.
///   * Double-quoted string interpolation: `"$var"` and `"{$obj->prop}"`.
///   * Heredoc and Nowdoc `<<<EOT ... EOT`.
///   * Attributes `#[Route('/path')]` painted as `meta`.
///   * `class Foo extends Bar`, `interface Foo`, `trait Foo`, `function name`.
final markastPhpGrammar = (() {
  const phpKeywords = <String>[
    'abstract', 'and', 'array', 'as', 'break', 'callable', 'case', 'catch',
    'class', 'clone', 'const', 'continue', 'declare', 'default', 'die', 'do',
    'echo', 'else', 'elseif', 'empty', 'enddeclare', 'endfor', 'endforeach',
    'endif', 'endswitch', 'endwhile', 'enum', 'extends', 'final', 'finally',
    'fn', 'for', 'foreach', 'function', 'global', 'goto', 'if', 'implements',
    'include', 'include_once', 'instanceof', 'insteadof', 'interface', 'isset',
    'list', 'match', 'namespace', 'new', 'or', 'print', 'private', 'protected',
    'public', 'readonly', 'require', 'require_once', 'return', 'static',
    'switch', 'throw', 'trait', 'try', 'unset', 'use', 'var', 'while', 'xor',
    'yield', 'self', 'parent', 'this',
  ];

  const phpLiterals = <String>['true', 'false', 'null', 'TRUE', 'FALSE', 'NULL'];

  const phpBuiltins = <String>[
    'string', 'int', 'integer', 'float', 'double', 'bool', 'boolean', 'object',
    'mixed', 'void', 'never', 'iterable', 'callable', 'self', 'static',
    'array',
    'ArrayObject', 'Closure', 'Generator', 'Iterator', 'Countable', 'Throwable',
    'Exception', 'Error', 'TypeError', 'ValueError', 'RuntimeException',
    'echo', 'print', 'isset', 'unset', 'empty', 'count', 'array_map',
    'array_filter', 'array_keys', 'array_values', 'json_encode', 'json_decode',
    'str_replace', 'strlen', 'substr', 'sprintf', 'printf',
  ];

  // Variable interpolation inside double quotes: "$var" or "{$obj->prop}"
  final substVar = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$[A-Za-z_]\w*(?:->\w+|\[[^\]]+\])*',
    relevance: 0,
  );

  final substExpr = Mode(
    scope: MarkastScopes.subst,
    begin: r'\{\$',
    end: r'\}',
    contains: <Mode>[markastNumber],
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"',
           contains: <Mode>[markastBackslashEscape, substVar, substExpr]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'",
           contains: <Mode>[markastBackslashEscape]),
      // Heredoc
      Mode(scope: MarkastScopes.string, begin: r'<<<\s*"?(\w+)"?', end: r'$',
           contains: <Mode>[substVar, substExpr]),
    ],
  );

  final phpTag = Mode(
    scope: MarkastScopes.meta,
    variants: <Mode>[
      Mode(begin: r'<\?(?:php|=)?'),
      Mode(begin: r'\?>'),
    ],
  );

  // PHP 8 attributes
  final attribute = Mode(
    scope: MarkastScopes.meta,
    begin: r'#\[',
    end: r'\]',
    contains: <Mode>[strings, markastNumber],
  );

  final variable = Mode(
    scope: MarkastScopes.variable,
    begin: r'\$[A-Za-z_]\w*',
    relevance: 0,
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'class interface trait enum',
    end: r'(?=[\{])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(beginKeywords: 'extends implements'),
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Za-z_]\w*'),
    ],
  );

  final fnDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'function',
    end: r'(?=\()',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
    ],
  );

  return Mode(
    name: 'PHP',
    aliases: <String>['php', 'php3', 'php4', 'php5', 'php6', 'php7', 'php8'],
    caseInsensitive: true,
    keywords: {
      'keyword':  phpKeywords,
      'literal':  phpLiterals,
      'built_in': phpBuiltins,
    },
    contains: <Mode>[
      phpTag,
      lineComment(r'//'),
      lineComment(r'#'),
      markastBlockComment,
      attribute,
      strings,
      variable,
      classDecl,
      fnDecl,
      markastNumber,
    ],
  );
})();
