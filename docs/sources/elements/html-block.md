# Bloque HTML

Un bloque HTML sin procesar que se pasa tal cual. Solo tiene significado en contextos web — en Flutter se renderiza como un bloque de código con estilo que muestra el HTML sin procesar.

## Estructura AST

```json
{
  "type": "html_block",
  "value": "<div class=\"callout\">Contenido HTML personalizado</div>"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"html_block"` | ✓ | Tipo de nodo |
| `value` | string | ✓ | HTML sin procesar a renderizar |

## Comportamiento en Flutter

El renderer de Flutter muestra el código HTML fuente en un cuadro con estilo, ya que el HTML no puede renderizarse como widgets nativos. Usa un renderer de bloque personalizado si necesitas manejar el HTML de otra forma:

```dart
class HtmlBlockRenderer extends BlockRenderer {
  const HtmlBlockRenderer();

  @override
  String get type => 'html_block';

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final html = (node['value'] as String?) ?? '';
    return WebViewWidget(html: html); // tu implementación de web view
  }
}

final markast = Markast()
  ..registerBlock(const HtmlBlockRenderer());
```

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `htmlBlockDecoration` | `BoxDecoration` | Decoración del contenedor de visualización alternativa |
| `htmlBlockPadding` | `EdgeInsets` | Padding dentro del contenedor alternativo |
| `htmlBlockTextStyle` | `TextStyle` | Estilo del texto del código HTML sin procesar |
