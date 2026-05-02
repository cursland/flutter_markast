# Enlace

Un hipervínculo inline con tooltip de título opcional.

## Estructura AST

```json
{
  "type": "link",
  "href": "https://flutter.dev",
  "title": "Sitio web de Flutter",
  "children": [
    { "type": "text", "value": "Flutter" }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"link"` | ✓ | Tipo de nodo |
| `href` | string | ✓ | URL de destino |
| `title` | string | — | Tooltip al pasar el cursor |
| `children` | nodos inline | ✓ | Texto visible del enlace |

## Hacer los enlaces interactivos

Los enlaces son **no interactivos por defecto** — pasa `onLinkTap` para habilitarlos:

```dart
markast.buildDocument(
  context,
  ast,
  onLinkTap: (url, title) => launchUrl(Uri.parse(url)),
)
```

El cursor cambia a puntero al pasar por encima en escritorio/web, independientemente de si `onLinkTap` está definido.

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `linkTextStyle` | `TextStyle` | Color, subrayado y decoración del texto del enlace |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  linkTextStyle: TextStyle(
    color: Colors.teal,
    decoration: TextDecoration.underline,
    decorationColor: Colors.teal,
  ),
)
```
