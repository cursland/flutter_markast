/// `WidgetContainerSyntax` — a custom `BlockSyntax` for `:::widget`
/// containers in the markast convention.
///
/// Recognises an opening line of the form `:::name ...` followed by an
/// arbitrary body and a closing `:::` line. Emits an `Element` whose tag is
/// `markast_widget`, carrying the widget name and the raw header tail in
/// attributes. The body is **parsed recursively** through the same document
/// so nested widgets and arbitrary markdown work inside.
///
/// Mirrors what the markdown-it-py `container_plugin` does on the Python
/// side: it produces a `container_<name>_open` / `..._close` token pair that
/// the markast builder later turns into a `widget` node.
library;

import 'package:markdown/markdown.dart' as md;

/// Regex matching the opening line: three-or-more colons followed by an
/// identifier (letters/digits/underscores/hyphens, must start with a word
/// char). The tail after the name is captured separately and parsed by the
/// builder via `parseProps`.
final RegExp containerOpenPattern = RegExp(
  r'^(?<colons>:{3,})\s*(?<name>[\w][\w-]*)\s*(?<info>.*?)\s*$',
);

/// Closing line: just `:::` (possibly indented up to 3 spaces, possibly with
/// trailing whitespace), nothing after.
final RegExp _containerClosePattern = RegExp(r'^\s{0,3}:{3,}\s*$');

class WidgetContainerSyntax extends md.BlockSyntax {
  const WidgetContainerSyntax();

  @override
  RegExp get pattern => containerOpenPattern;

  @override
  bool canParse(md.BlockParser parser) {
    // Mirror the markdown-it-py `container_plugin` behaviour: widgets are
    // only recognised at the top level of the document or inside another
    // widget's body — NOT inside blockquotes, lists, or other nested
    // containers. The plugin on the Python side achieves this by registering
    // openers at the block layer only; here we approximate it by checking
    // `parentSyntax`, which is non-null whenever we're nested.
    if (parser.parentSyntax != null) return false;
    final m = pattern.firstMatch(parser.current.content);
    if (m == null) return false;
    return m.namedGroup('name') != null && m.namedGroup('name')!.isNotEmpty;
  }

  @override
  md.Node? parse(md.BlockParser parser) {
    final match = pattern.firstMatch(parser.current.content)!;
    final colons = match.namedGroup('colons')!;
    final widgetName = match.namedGroup('name')!;
    final infoTail = (match.namedGroup('info') ?? '').trim();

    parser.advance();

    final bodyLines = <md.Line>[];
    var depth = 1;
    while (!parser.isDone) {
      final current = parser.current.content;
      // Track nested openers of the same fence flavour so we can close at the
      // correct depth.
      final openMatch = pattern.firstMatch(current);
      if (openMatch != null &&
          openMatch.namedGroup('name') != null &&
          openMatch.namedGroup('name')!.isNotEmpty) {
        depth += 1;
        bodyLines.add(parser.current);
        parser.advance();
        continue;
      }
      if (_containerClosePattern.hasMatch(current)) {
        depth -= 1;
        if (depth == 0) {
          parser.advance();
          break;
        }
        bodyLines.add(parser.current);
        parser.advance();
        continue;
      }
      bodyLines.add(parser.current);
      parser.advance();
    }

    final children = md.BlockParser(bodyLines, parser.document).parseLines();

    final el = md.Element('markast_widget', children);
    el.attributes['markast_widget_name'] = widgetName;
    el.attributes['markast_widget_info'] = infoTail;
    el.attributes['markast_widget_fence'] = colons;
    return el;
  }
}
