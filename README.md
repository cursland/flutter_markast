<div align="center">

<img src="https://raw.githubusercontent.com/cursland/markast/docs/assets/favicon.svg" width="72" alt="markast">

# markast

**Markdown → typed AST → native Flutter widgets**

Parse Markdown into a typed JSON AST and render it as native Flutter widgets — no HTML, no WebView, fully themeable, extensible via custom renderers. The parsing and rendering pipelines are independent: build the AST in Dart, in Python, or anywhere else.

[![Version](https://img.shields.io/badge/version-0.0.3-6d52ff)](https://www.cursland.com)
[![Flutter](https://img.shields.io/badge/flutter->=1.17.0-6d52ff)](pubspec.yaml)
[![License](https://img.shields.io/badge/license-MIT-6d52ff)](LICENSE)

</div>

---

```dart
import 'package:markast/markast.dart';

final markast = Markast();

Widget build(BuildContext context) {
  // Build the AST in Dart, or load JSON from any compatible source.
  final ast = parse('# Hola\n\nUn párrafo con **negrita**.').toMap();

  return markast.buildDocument(context, ast, onLinkTap: (url, _) {
    launchUrl(Uri.parse(url));
  });
}
```

## How it works

markast splits the work into two independent stages:

```
Markdown  ─┐
           ├─►  JSON AST  ─►  Widgets
JSON file  ─┘
```

You can produce the AST any of these ways:

| Source | Function |
|---|---|
| Markdown in your Flutter app | `parse(text)` — this package |
| Markdown server-side | The [Python `markast` parser](https://github.com/cursland/markast) |
| A CMS / API | Any backend that emits JSON following the node convention |
| Hand-written | Construct nodes directly with the `factory.dart` helpers |

The renderer dispatches purely on the `type` field of each node, so all four sources are interchangeable.

## Parsing in Dart

```dart
import 'package:markast/markast.dart';

final doc = parse('# Heading\n\nWith **bold** text and [a link](https://x.dev).');

doc.toMap();                  // Map<String, dynamic> ready for buildDocument
doc.toJson(indent: 2);        // JSON string
doc.toMarkdown();             // roundtrip: AST → canonical Markdown
doc.warnings;                 // diagnostics — W001…W009 codes
doc.find(NodeType.heading);   // walk the tree
```

For non-default behaviour — custom widgets, transform pipelines, alternate rule sets — construct a `Parser` explicitly:

```dart
final parser = Parser(
  transforms: ['normalize', 'slugify', 'toc'],
  widgets: [() => MyCustomWidget()],
);
final doc = parser.parse(markdownSource);
```

Built-in widget containers (`:::name`): `tip`, `note`, `info`, `warning`, `caution`, `danger`, `card`, `video`, `code-group`, `code-collapse`, `tabs`, `steps`, `badge`. Mirrors the Python parser one-for-one.

Available transforms: `normalize` (merge adjacent text), `slugify` (kebab-case `id` on every heading), `toc` (nested TOC in `meta.toc`), `linkify` (turn bare URLs into links), `smarttypography` (curly quotes, en/em dashes).

## Theming

Every visual detail is configurable through `MarkastTheme`:

```dart
Markast(
  theme: MarkastTheme(
    h1TextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
    codeBlockDecoration: BoxDecoration(color: Color(0xFF161823)),
    highlightTheme: MarkastHighlightTheme(theme: MarkastCodeThemes.nord),
  ),
);
```

## Extending

Register custom renderers for any node type, including `:::widget` blocks:

```dart
markast.registerBlock(MyVideoRenderer());
markast.registerWidget(MyCarouselRenderer());
```

## License

MIT
