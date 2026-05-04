import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced YAML grammar.
///
/// Improvements:
///   * Document markers `---` / `...` painted as `meta`.
///   * Keys painted as `attr`.
///   * Anchors `&name` and aliases `*name` painted as `symbol`.
///   * Type tags `!!str`, `!Custom` painted as `type`.
///   * Folded `>` and literal `|` block scalar indicators.
final markastYamlGrammar = (() {
  const yamlLiterals = <String>['true', 'True', 'TRUE',
                                 'false', 'False', 'FALSE',
                                 'null', 'Null', 'NULL', '~',
                                 'yes', 'Yes', 'YES',
                                 'no', 'No', 'NO',
                                 'on', 'On', 'ON',
                                 'off', 'Off', 'OFF'];

  // Document markers
  final docMarker = Mode(
    scope: MarkastScopes.meta,
    begin: r'^---|^\.\.\.',
    relevance: 10,
  );

  // Key: line. Captures from line start to the colon.
  final key = Mode(
    scope: MarkastScopes.attr,
    variants: <Mode>[
      Mode(begin: r'^[\s-]*[A-Za-z_][\w\-./]*(?=\s*:(\s|$))'),
      Mode(begin: r'"[^"]*"(?=\s*:)'),
      Mode(begin: r"'[^']*'(?=\s*:)"),
    ],
    relevance: 0,
  );

  // Anchor / alias / merge
  final anchor = Mode(
    scope: MarkastScopes.symbol,
    begin: r'[&*][A-Za-z_][\w-]*',
    relevance: 0,
  );

  // Tag: !!str, !Custom
  final tag = Mode(
    scope: MarkastScopes.type,
    begin: r'!{1,2}[\w/]+',
    relevance: 0,
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'",
           contains: <Mode>[Mode(begin: r"''")]),
    ],
  );

  // Block scalar indicator
  final blockScalar = Mode(
    scope: MarkastScopes.string,
    begin: r'[|>][+-]?\d?\s*$',
    end: r'^(?=\S)|^(?=---|\.\.\.|\s*$)',
    endsWithParent: true,
    relevance: 0,
  );

  return Mode(
    name: 'YAML',
    aliases: <String>['yml', 'yaml'],
    caseInsensitive: true,
    keywords: {
      'literal': yamlLiterals,
    },
    contains: <Mode>[
      lineComment(r'#'),
      docMarker,
      anchor,
      tag,
      key,
      strings,
      blockScalar,
      markastNumber,
    ],
  );
})();
