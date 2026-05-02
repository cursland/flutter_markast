# Imagen en Línea

Una imagen integrada dentro de un flujo de texto — usada para iconos, emojis o pequeños gráficos dentro de una oración.

## Estructura AST

```json
{ "type": "inline_image", "src": "assets/icon.png", "alt": "icono de check" }
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"inline_image"` | ✓ | Tipo de nodo |
| `src` | string | ✓ | URL o ruta de asset de la imagen |
| `alt` | string | — | Descripción de accesibilidad |
| `title` | string | — | Tooltip al pasar el cursor |

## Comportamiento

Las imágenes en línea se renderizan como `WidgetSpan` dentro de un árbol de `TextSpan`. La altura se controla con `inlineImageHeightFactor` relativo al tamaño del texto circundante.

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `inlineImageHeightFactor` | `double` | Alto de la imagen como multiplicador del tamaño de fuente actual (por defecto `1.1`) |

## Builder de imagen personalizado

El callback `imageBuilder` también aplica a las imágenes en línea:

```dart
markast.buildDocument(
  context,
  ast,
  imageBuilder: (src, {width, height, fit = BoxFit.contain, semanticLabel}) {
    return CachedNetworkImage(imageUrl: src, height: height);
  },
)
```
