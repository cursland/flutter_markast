import 'package:re_highlight/re_highlight.dart';

/// Markast's enhanced HTML/XML grammar.
///
/// Improvements:
///   * Tag name painted as `name`, attribute names as `attr`, values as
///     `string`.
///   * `<!DOCTYPE …>` painted as `meta`.
///   * `<!-- … -->` comments painted as `comment`.
///   * `<script>` / `<style>` content delegated to JavaScript / CSS via
///     `subLanguage`.
final markastHtmlGrammar = (() {
  // Doctype
  final doctype = Mode(
    scope: 'meta',
    begin: r'<!DOCTYPE', end: r'>',
    relevance: 10,
    contains: <Mode>[
      Mode(begin: r'\[', end: r'\]'),
    ],
  );

  // Comment
  final comment = Mode(
    scope: 'comment',
    begin: r'<!--', end: r'-->',
  );

  // CDATA
  final cdata = Mode(
    scope: 'meta',
    begin: r'<!\[CDATA\[', end: r'\]\]>',
  );

  // Attribute value (string)
  final attrValue = Mode(
    scope: 'string',
    variants: <Mode>[
      Mode(begin: r'"', end: r'"'),
      Mode(begin: r"'", end: r"'"),
      Mode(begin: r'[A-Za-z0-9._:-]+'),
    ],
    relevance: 0,
  );

  // Attribute: name="value"
  final attribute = Mode(
    begin: r'\b[A-Za-z_:][A-Za-z0-9_.:-]*',
    scope: 'attr',
    relevance: 0,
    starts: Mode(
      end: r'(?=[\s/>])',
      relevance: 0,
      contains: <Mode>[
        Mode(begin: r'=\s*', end: r'(?=[\s/>])', excludeBegin: true,
             excludeEnd: true, contains: <Mode>[attrValue]),
      ],
    ),
  );

  // <script>...</script> with JS sublanguage
  final scriptTag = Mode(
    scope: 'tag',
    begin: r'<script(?=\s|>)', end: r'>',
    contains: <Mode>[
      Mode(scope: 'name', begin: r'(?<=<)script', relevance: 0),
      Mode(begin: r'>', endsParent: true, relevance: 0),
      attribute,
    ],
    starts: Mode(
      end: r'</script>',
      returnEnd: true,
      subLanguage: 'javascript',
      relevance: 0,
    ),
  );

  // <style>...</style> with CSS sublanguage
  final styleTag = Mode(
    scope: 'tag',
    begin: r'<style(?=\s|>)', end: r'>',
    contains: <Mode>[
      Mode(scope: 'name', begin: r'(?<=<)style', relevance: 0),
      Mode(begin: r'>', endsParent: true, relevance: 0),
      attribute,
    ],
    starts: Mode(
      end: r'</style>',
      returnEnd: true,
      subLanguage: 'css',
      relevance: 0,
    ),
  );

  // Generic tag
  final tag = Mode(
    scope: 'tag',
    begin: r'</?[A-Za-z][A-Za-z0-9_-]*',
    end: r'/?>',
    contains: <Mode>[
      Mode(scope: 'name', begin: r'(?<=[</])[A-Za-z][A-Za-z0-9_-]*',
           relevance: 0),
      attribute,
    ],
  );

  return Mode(
    name: 'HTML',
    aliases: <String>['html', 'xhtml', 'xml', 'svg'],
    caseInsensitive: true,
    contains: <Mode>[
      doctype,
      cdata,
      comment,
      scriptTag,
      styleTag,
      tag,
    ],
  );
})();
