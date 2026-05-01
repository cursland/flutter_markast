<div align="center">

<img src="https://raw.githubusercontent.com/cursland/markast/docs/assets/favicon.svg" width="72" alt="markast">

# markast

**markast AST → native Flutter widgets**

Render the typed JSON tree produced by the [markast](https://github.com/cursland/markast) Python parser into native Flutter widgets. No HTML or WebView rendering, fully themeable, extensible via custom renderers.

[![Version](https://img.shields.io/badge/version-0.0.1-6d52ff)](https://www.cursland.com)
[![Flutter](https://img.shields.io/badge/flutter->=1.17.0-6d52ff)](pubspec.yaml)
[![License](https://img.shields.io/badge/license-MIT-6d52ff)](LICENSE)

</div>

---

```dart
import 'package:markast/markast.dart';

final markast = Markast();

Widget build(BuildContext context) {
  return markast.buildDocument(context, jsonAst, onLinkTap: (url, _) {
    launchUrl(Uri.parse(url));
  });
}
```

## How it works

The [markast Python parser](https://www.cursland.com) converts Markdown into a typed JSON AST. This package consumes that JSON and renders it as native Flutter widgets.

```
Markdown  →  markast (Python)  →  JSON AST  →  markast (Flutter)  →  Widgets
```

Any parser that produces JSON following the same node convention is also compatible — the renderer dispatches purely on the `type` field of each node.

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
