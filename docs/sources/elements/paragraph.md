# Párrafo

El contenedor de bloque por defecto para contenido inline. La mayor parte del texto de cuerpo vive en nodos de párrafo.

## Estructura AST

```json
{
  "type": "paragraph",
  "children": [
    { "type": "text", "value": "Texto plano, " },
    { "type": "bold", "children": [{ "type": "text", "value": "negrita" }] },
    { "type": "text", "value": ", y " },
    { "type": "italic", "children": [{ "type": "text", "value": "cursiva" }] },
    { "type": "text", "value": " en línea." }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"paragraph"` | ✓ | Tipo de nodo |
| `children` | nodos inline | ✓ | Contenido del párrafo |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `bodyTextStyle` | `TextStyle` | Fuente base, tamaño y color de todo el texto del párrafo |
| `paragraphPadding` | `EdgeInsets` | Padding adicional alrededor de cada párrafo (por defecto `EdgeInsets.zero`) |
| `blockSpacing` | `double` | Espacio vertical tras el párrafo |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  bodyTextStyle: const TextStyle(fontSize: 16, height: 1.8),
  blockSpacing: 20,
)
```
