import 'package:re_highlight/re_highlight.dart';

/// Markast's enhanced Markdown grammar.
///
/// Improvements:
///   * Headings `#`–`######` painted as `section`.
///   * Bold (`**text**`, `__text__`) painted as `strong`.
///   * Italic (`*text*`, `_text_`) painted as `emphasis`.
///   * Inline code `` `code` `` painted as `code`.
///   * Fenced code blocks `` ``` `` painted as `code` (no inner highlighting
///     to avoid recursion when used inside doc comments of other languages).
///   * Links `[text](url)` and images `![alt](src)` — text/alt as `string`,
///     URL as `link`.
///   * List bullets `-` / `*` / `+` / `1.` painted as `bullet`.
///   * Blockquotes painted as `quote`.
///   * Horizontal rules `---` / `***` painted as `meta`.
final markastMarkdownGrammar = (() {
  // Heading: # to ###### at start of line
  final heading = Mode(
    scope: 'section',
    variants: <Mode>[
      Mode(begin: r'^#{1,6}\s+', end: r'$'),
      Mode(begin: r'^.+?\n[=-]{2,}\s*$'),
    ],
  );

  // Horizontal rule
  final hr = Mode(
    scope: 'meta',
    begin: r'^[-*_]{3,}\s*$',
    relevance: 10,
  );

  // Fenced code block (don't recurse — keep it as a single string token)
  final fencedCode = Mode(
    scope: 'code',
    begin: r'^```[^\n]*$',
    end: r'^```$',
    relevance: 10,
  );

  // Indented code block
  final indentedCode = Mode(
    scope: 'code',
    begin: r'^(    |\t)',
    end: r'$',
    relevance: 0,
  );

  // Inline code
  final inlineCode = Mode(
    scope: 'code',
    begin: r'`{1,3}',
    end: r'`{1,3}',
    relevance: 0,
  );

  // Bold
  final strong = Mode(
    scope: 'strong',
    variants: <Mode>[
      Mode(begin: r'\*\*([^\n]+?)\*\*'),
      Mode(begin: r'__([^\n]+?)__'),
    ],
  );

  // Italic
  final emphasis = Mode(
    scope: 'emphasis',
    variants: <Mode>[
      Mode(begin: r'\*([^\*\n]+?)\*'),
      Mode(begin: r'_([^_\n]+?)_'),
    ],
  );

  // Strikethrough
  final strike = Mode(
    scope: 'deletion',
    begin: r'~~([^\n]+?)~~',
  );

  // Link / image
  final link = Mode(
    scope: 'link',
    variants: <Mode>[
      // Image: ![alt](url)
      Mode(begin: r'!\[', end: r'\]\([^)]+\)',
           contains: <Mode>[
             Mode(scope: 'string', begin: r'!\['),
             Mode(scope: 'link', begin: r'\(', end: r'\)'),
           ]),
      // Link: [text](url)
      Mode(begin: r'\[', end: r'\]\([^)]+\)',
           contains: <Mode>[
             Mode(scope: 'string', begin: r'\['),
             Mode(scope: 'link', begin: r'\(', end: r'\)'),
           ]),
      // Reference link: [text][ref]
      Mode(begin: r'\[[^\]]+\]\[[^\]]*\]'),
    ],
    relevance: 0,
  );

  // Blockquote: > line
  final quote = Mode(
    scope: 'quote',
    begin: r'^>\s+',
    end: r'$',
    relevance: 0,
  );

  // List bullet
  final bullet = Mode(
    scope: 'bullet',
    begin: r'^\s*([-*+]|\d+\.)\s+',
    relevance: 0,
  );

  // HTML-like tag
  final tag = Mode(
    scope: 'tag',
    begin: r'</?[A-Za-z][^>]*>',
    relevance: 0,
  );

  return Mode(
    name: 'Markdown',
    aliases: <String>['md', 'mkdown', 'mkd', 'markdown'],
    contains: <Mode>[
      heading,
      hr,
      fencedCode,
      indentedCode,
      inlineCode,
      strong,
      emphasis,
      strike,
      link,
      quote,
      bullet,
      tag,
    ],
  );
})();
