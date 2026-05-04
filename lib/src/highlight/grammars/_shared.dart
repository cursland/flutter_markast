import 'package:re_highlight/re_highlight.dart';

/// Shared scope vocabulary used by every Markast grammar.
///
/// These names match the highlight.js theme conventions. Every theme in
/// `MarkastCodeThemes` (atom-one-dark, monokai, github, etc.) defines styles
/// for these scopes — using anything else here means the token will fall back
/// to the base (uncolored) text style.
abstract final class MarkastScopes {
  // Lexical
  static const comment      = 'comment';
  static const docTag       = 'doctag';
  static const quote        = 'quote';

  // Literals
  static const string       = 'string';
  static const subst        = 'subst';        // ${expr} inside strings
  static const regexp       = 'regexp';
  static const number       = 'number';
  static const literal      = 'literal';      // true / false / null

  // Identifiers
  static const keyword      = 'keyword';
  static const builtIn      = 'built_in';
  static const type         = 'type';
  static const variable     = 'variable';
  static const symbol       = 'symbol';
  static const params       = 'params';
  static const property     = 'property';
  static const attr         = 'attr';
  static const attribute    = 'attribute';

  // Declarations
  static const className    = 'class';
  static const functionName = 'function';
  static const title        = 'title';
  static const titleClass   = 'title.class_';
  static const titleFn      = 'title.function_';
  static const meta         = 'meta';
  static const metaString   = 'meta-string';

  // Markup
  static const tag          = 'tag';
  static const name         = 'name';
  static const section      = 'section';
  static const bullet       = 'bullet';
  static const link         = 'link';
  static const emphasis     = 'emphasis';
  static const strong       = 'strong';
  static const code         = 'code';
  static const formula      = 'formula';

  // Selectors (CSS)
  static const selectorTag    = 'selector-tag';
  static const selectorClass  = 'selector-class';
  static const selectorId     = 'selector-id';
  static const selectorAttr   = 'selector-attr';
  static const selectorPseudo = 'selector-pseudo';

  // Diff / template
  static const addition          = 'addition';
  static const deletion          = 'deletion';
  static const templateTag       = 'template-tag';
  static const templateVariable  = 'template-variable';
}

/// Standard `TODO/FIXME/NOTE/...` doctag inside any comment.
final markastDocTag = Mode(
  scope: MarkastScopes.docTag,
  begin: r'\b(TODO|FIXME|NOTE|BUG|XXX|HACK|OPTIMIZE|WARN|REVIEW)\b:?',
  relevance: 0,
);

/// Builds a line-comment mode that recognizes a doctag and `[ref]` style links.
Mode lineComment(String prefix) => Mode(
  scope: MarkastScopes.comment,
  begin: prefix,
  end: r'$',
  contains: <Mode>[
    markastDocTag,
    Mode(begin: r'`[^`]+`', relevance: 0),
  ],
);

/// Builds a `/* ... */` style block comment with doctag support.
final markastBlockComment = Mode(
  scope: MarkastScopes.comment,
  begin: r'/\*',
  end: r'\*/',
  contains: <Mode>[
    markastDocTag,
    Mode(begin: r'`[^`]+`', relevance: 0),
  ],
);

/// `\\.` escape inside any string body.
final markastBackslashEscape = Mode(begin: r'\\[\s\S]', relevance: 0);

/// Comprehensive number matcher: hex, octal, binary, scientific, decimal,
/// optional sign, optional underscores (Rust/Java/Python), optional type
/// suffixes (L, LL, U, f, d, n …).
final markastNumber = Mode(
  scope: MarkastScopes.number,
  variants: <Mode>[
    // Hex with optional digit separators and type suffix
    Mode(begin: r'\b0[xX][0-9a-fA-F][0-9a-fA-F_]*[lLuUfFdDnN]?\b'),
    // Binary
    Mode(begin: r'\b0[bB][01][01_]*[lLuUnN]?\b'),
    // Octal
    Mode(begin: r'\b0[oO]?[0-7][0-7_]*[lLuUnN]?\b'),
    // Float with exponent / decimal
    Mode(begin: r'\b\d[\d_]*(\.\d[\d_]*)?([eE][+-]?\d[\d_]*)?[fFdDmMnN]?\b'),
  ],
  relevance: 0,
);

/// Builds an `${...}` interpolation mode that itself can re-enter the host
/// language for nested expressions.
Mode interpolation({required String begin, required String end, List<Mode>? contains}) {
  return Mode(
    scope: MarkastScopes.subst,
    begin: begin,
    end: end,
    contains: contains ?? const <Mode>[],
  );
}

/// Bare `$identifier` interpolation token (Dart, Bash, Perl, etc.).
final markastDollarVar = Mode(
  scope: MarkastScopes.subst,
  begin: r'\$[A-Za-z_][A-Za-z0-9_]*',
  relevance: 0,
);
