# Callout

Un bloque resaltado para consejos, advertencias y otros mensajes destacados. Construido como un widget de markast.

## Estructura AST

```json
{
  "type": "widget",
  "widget": "callout",
  "props": { "type": "tip", "title": "Consejo pro" },
  "slots": {
    "default": [
      {
        "type": "paragraph",
        "children": [{ "type": "text", "value": "Usa themeModifier para ajustar los valores predeterminados." }]
      }
    ]
  }
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `widget` | `"callout"` | ✓ | Nombre del widget |
| `props.type` | string | ✓ | Estilo visual: `info`, `tip`, `warn`, `error`, `success` |
| `props.title` | string | — | Texto de encabezado en negrita |
| `slots.default` | nodos de bloque | — | Contenido del cuerpo |

## Tipos de callout

| Tipo | Color | Usar para |
|------|-------|-----------|
| `info` | Azul | Información neutral |
| `tip` | Verde | Sugerencias útiles |
| `warn` | Ámbar | Precauciones y advertencias |
| `error` | Rojo | Errores y cambios incompatibles |
| `success` | Verde | Resultados positivos |

## Propiedades del tema en Flutter

Cada tipo tiene su propio registro de estilo (`MarkastCalloutStyle`):

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `calloutInfo` | `MarkastCalloutStyle` | Icono, color del icono, estilo del título, decoración para `info` |
| `calloutWarn` | `MarkastCalloutStyle` | Lo mismo para `warn` |
| `calloutError` | `MarkastCalloutStyle` | Lo mismo para `error` |
| `calloutSuccess` | `MarkastCalloutStyle` | Lo mismo para `success` |
| `calloutPadding` | `EdgeInsets` | Padding interno (todos los tipos) |
| `calloutTitleSpacing` | `double` | Espacio entre el título y el cuerpo |
| `calloutTitleIconSize` | `double` | Tamaño del icono en la fila del título |

## Personalizar un tipo de callout

```dart
themeModifier: (base) => base.copyWith(
  calloutWarn: (
    icon: Icons.warning_amber_rounded,
    iconColor: Colors.orange,
    titleStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      color: Colors.orange,
    ),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(.08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withOpacity(.3)),
    ),
  ),
)
```
