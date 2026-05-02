# Cita en Bloque

Un bloque con sangría y borde lateral de acento, usado típicamente para citas destacadas o contenido referenciado.

## Estructura AST

```json
{
  "type": "blockquote",
  "children": [
    {
      "type": "paragraph",
      "children": [{ "type": "text", "value": "Ser o no ser." }]
    }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"blockquote"` | ✓ | Tipo de nodo |
| `children` | nodos de bloque | ✓ | Contenido — párrafos, listas, incluso citas anidadas |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `blockquoteDecoration` | `BoxDecoration` | Fondo y borde lateral del bloque de cita |
| `blockquotePadding` | `EdgeInsets` | Padding interno (por defecto `LTRB(16, 8, 8, 8)`) |
| `blockquoteTextStyle` | `TextStyle` | Estilo del texto — normalmente color atenuado y cursiva |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  blockquoteDecoration: BoxDecoration(
    border: Border(
      left: BorderSide(color: Colors.purple, width: 4),
    ),
    color: Colors.purple.withOpacity(.05),
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(6),
      bottomRight: Radius.circular(6),
    ),
  ),
  blockquoteTextStyle: const TextStyle(fontStyle: FontStyle.italic),
)
```
