# Renderers Personalizados

Reemplaza o extiende cualquier renderer oficial, o añade soporte para tipos de nodos completamente nuevos.

## Renderer de bloque

Extiende `BlockRenderer` e implementa `type` + `build`:

```dart
import 'package:markast/markast.dart';

class MyHeadingRenderer extends BlockRenderer {
  const MyHeadingRenderer();

  @override
  String get type => 'heading';

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final level = (node['level'] as int?) ?? 1;
    final style = switch (level) {
      1 => ctx.theme.h1TextStyle,
      2 => ctx.theme.h2TextStyle,
      _ => ctx.theme.h3TextStyle,
    };
    final spans = ctx.markast.buildInlines(
      ctx,
      node['children'] as List?,
      style,
    );
    return Padding(
      padding: ctx.theme.headingPadding,
      child: Text.rich(TextSpan(style: style, children: spans)),
    );
  }
}
```

Regístralo en tu instancia de `Markast`:

```dart
final markast = Markast()
  ..registerBlock(const MyHeadingRenderer());
```

## Renderer de inline

Extiende `InlineRenderer` e implementa `type` + `build`:

```dart
class MyHighlightRenderer extends InlineRenderer {
  const MyHighlightRenderer();

  @override
  String get type => 'highlight';  // tipo de nodo personalizado

  @override
  InlineSpan build(
    RenderContext ctx,
    Map<String, dynamic> node,
    TextStyle style,
  ) {
    final children = ctx.markast.buildInlines(
      ctx,
      node['children'] as List?,
      style,
    );
    return TextSpan(
      style: style.copyWith(backgroundColor: Colors.yellow.withOpacity(.4)),
      children: children,
    );
  }
}
```

## Renderer de widget

Extiende `WidgetNodeRenderer` para manejar los nodos `:::widget` del parser Python:

```dart
class BannerWidgetRenderer extends WidgetNodeRenderer {
  const BannerWidgetRenderer();

  @override
  String get name => 'banner';

  @override
  Widget build(
    RenderContext ctx,
    Map<String, dynamic> props,
    Map<String, List<Map<String, dynamic>>> slots,
  ) {
    final title = props['title'] as String? ?? '';
    return Container(
      color: Colors.blue.shade100,
      padding: const EdgeInsets.all(16),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
```

La sintaxis Markdown correspondiente (parser Python):

```
:::widget banner title="Bienvenido"
:::
```

## RenderContext

Cada renderer recibe un `RenderContext` con:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `context` | `BuildContext` | Contexto de build de Flutter |
| `theme` | `MarkastTheme` | Tema resuelto |
| `markast` | `Markast` | La instancia del renderer (para llamadas recursivas) |
| `onLinkTap` | callback? | Manejador de toque en enlace |
| `imageBuilder` | callback? | Fábrica de imágenes personalizada |
| `videoBuilder` | callback? | Fábrica de videos personalizada |
| `onCodeCopy` | callback? | Manejador del botón de copiar |
| `scratch` | `Map<String, dynamic>` | Estado mutable compartido entre renderers (usado para indexar notas al pie) |
