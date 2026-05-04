import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced JSON grammar.
///
/// Improvements:
///   * Object keys (strings followed by `:`) painted as `attr`, distinguishing
///     them from value strings.
///   * `true` / `false` / `null` painted as `literal`.
///   * Comments tolerated (JSON5 / JSONC).
final markastJsonGrammar = (() {
  // Key: a string followed by colon
  final key = Mode(
    scope: MarkastScopes.attr,
    begin: r'"',
    end: r'"(?=\s*:)',
    contains: <Mode>[markastBackslashEscape],
    relevance: 1,
  );

  final stringValue = Mode(
    scope: MarkastScopes.string,
    begin: r'"',
    end: r'"',
    contains: <Mode>[markastBackslashEscape],
  );

  return Mode(
    name: 'JSON',
    aliases: <String>['json', 'jsonc', 'json5'],
    keywords: {
      'literal': ['true', 'false', 'null'],
    },
    contains: <Mode>[
      // JSONC tolerates comments
      lineComment(r'//'),
      markastBlockComment,
      key,
      stringValue,
      markastNumber,
    ],
    illegal: r'\S',
  );
})();
