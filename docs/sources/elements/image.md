# Imagen

Una imagen a nivel de bloque con texto alternativo y título de pie de foto opcionales.

## Estructura AST

```json
{
  "type": "image",
  "src": "https://example.com/photo.jpg",
  "alt": "Un paisaje",
  "title": "Foto de Unsplash"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"image"` | ✓ | Tipo de nodo |
| `src` | string | ✓ | URL o ruta de asset de la imagen |
| `alt` | string | — | Descripción de accesibilidad |
| `title` | string | — | Pie de foto mostrado bajo la imagen |
| `width` | number | — | Ancho de visualización objetivo |
| `height` | number | — | Alto de visualización objetivo |

## Detección del origen

El cargador por defecto detecta automáticamente el tipo de origen:

| Prefijo | Cargador |
|---------|---------|
| `http://` o `https://` | `Image.network` con timeout |
| `file://` | `Image.file` |
| cualquier otro | `Image.asset` |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `imageBorderRadius` | `BorderRadius` | Redondeo de las esquinas de la imagen |
| `imageFit` | `BoxFit` | Cómo ocupa la imagen su espacio (por defecto `BoxFit.contain`) |
| `imageTitleTextStyle` | `TextStyle` | Estilo del texto del pie de foto |
| `imageTitlePadding` | `EdgeInsets` | Espacio entre imagen y pie de foto |
| `imagePlaceholderDecoration` | `BoxDecoration` | Fondo mostrado mientras carga |
| `imagePlaceholderTextStyle` | `TextStyle` | Estilo del texto alternativo en el placeholder |
| `imagePlaceholderHeight` | `double` | Alto del placeholder antes de cargar (por defecto `120`) |

## Builder de imagen personalizado

Reemplaza el widget por defecto para cualquier nodo de imagen:

```dart
markast.buildDocument(
  context,
  ast,
  imageBuilder: (src, {width, height, fit = BoxFit.contain, semanticLabel}) {
    return CachedNetworkImage(
      imageUrl: src,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => const CircularProgressIndicator(),
    );
  },
)
```

## Personalizar el marco

```dart
themeModifier: (base) => base.copyWith(
  imageBorderRadius: BorderRadius.circular(12),
  imageFit: BoxFit.cover,
)
```
