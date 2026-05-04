import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced CSS grammar.
///
/// Improvements:
///   * Selectors split: tag (`div`), class (`.foo`), id (`#bar`),
///     pseudo (`:hover`, `::before`), attr (`[type="text"]`).
///   * At-rules `@media`, `@import`, `@keyframes` painted as `keyword`.
///   * Property names painted as `attr`, values get colour, hex / rgb / units
///     painted as `number`.
///   * `!important` painted as `meta`.
///   * `var(--foo)` and CSS custom properties painted as `variable`.
final markastCssGrammar = (() {
  final hexColor = Mode(
    scope: MarkastScopes.number,
    begin: r'#[A-Fa-f0-9]{3,8}\b',
    relevance: 0,
  );

  final unit = Mode(
    scope: MarkastScopes.number,
    begin: r'\b\d+(\.\d+)?(px|em|rem|%|vh|vw|vmin|vmax|deg|rad|turn|ms|s|ch|ex|fr|pt|pc|cm|mm|in)?\b',
    relevance: 0,
  );

  // !important
  final important = Mode(
    scope: MarkastScopes.meta,
    begin: r'!important\b',
    relevance: 10,
  );

  // CSS custom property var(--name)
  final cssVar = Mode(
    scope: MarkastScopes.variable,
    begin: r'--[A-Za-z_][\w-]*',
    relevance: 0,
  );

  // At-rule: @media, @import, @keyframes
  final atRule = Mode(
    scope: MarkastScopes.keyword,
    begin: r'@[A-Za-z-]+',
    relevance: 0,
  );

  // Selectors
  final selectorClass = Mode(
    scope: MarkastScopes.selectorClass,
    begin: r'\.[A-Za-z_][\w-]*',
    relevance: 0,
  );
  final selectorId = Mode(
    scope: MarkastScopes.selectorId,
    begin: r'#[A-Za-z_][\w-]*',
    relevance: 0,
  );
  final selectorPseudo = Mode(
    scope: MarkastScopes.selectorPseudo,
    begin: r'::?[A-Za-z-]+(\([^)]*\))?',
    relevance: 0,
  );
  final selectorAttr = Mode(
    scope: MarkastScopes.selectorAttr,
    begin: r'\[', end: r'\]',
    contains: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"'),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'"),
    ],
    relevance: 0,
  );

  // Property: foo-name:
  final property = Mode(
    scope: MarkastScopes.attribute,
    begin: r'\b[A-Za-z-][A-Za-z0-9-]*\s*(?=:)',
    relevance: 0,
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"'),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'"),
    ],
  );

  return Mode(
    name: 'CSS',
    aliases: <String>['css', 'scss', 'sass', 'less'],
    caseInsensitive: true,
    contains: <Mode>[
      markastBlockComment,
      atRule,
      hexColor,
      cssVar,
      important,
      selectorClass,
      selectorId,
      selectorPseudo,
      selectorAttr,
      property,
      strings,
      unit,
    ],
  );
})();
