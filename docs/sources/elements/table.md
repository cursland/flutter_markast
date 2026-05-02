# Tabla

Una cuadrícula estructurada de filas y columnas con cabecera opcional y alineación por celda.

## Estructura AST

```json
{
  "type": "table",
  "head": [
    {
      "type": "table_row",
      "children": [
        { "type": "table_cell", "is_header": true, "align": "left",   "children": [{"type": "text", "value": "Nombre"}] },
        { "type": "table_cell", "is_header": true, "align": "center", "children": [{"type": "text", "value": "Tipo"}] },
        { "type": "table_cell", "is_header": true, "align": "right",  "children": [{"type": "text", "value": "Por defecto"}] }
      ]
    }
  ],
  "body": [
    {
      "type": "table_row",
      "children": [
        { "type": "table_cell", "children": [{"type": "text", "value": "blockSpacing"}] },
        { "type": "table_cell", "children": [{"type": "code_inline", "value": "double"}] },
        { "type": "table_cell", "children": [{"type": "text", "value": "16"}] }
      ]
    }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"table"` | ✓ | Tipo de nodo |
| `head` | `table_row[]` | — | Filas de cabecera |
| `body` | `table_row[]` | — | Filas de cuerpo |
| `table_cell.is_header` | bool | — | Renderiza como `<th>` en lugar de `<td>` |
| `table_cell.align` | `"left"`, `"center"`, `"right"` | — | Alineación del texto de la celda |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `tableDecoration` | `BoxDecoration` | Borde exterior y fondo de la tabla |
| `tableHeaderRowDecoration` | `BoxDecoration` | Fondo de la fila de cabecera |
| `tableHeaderTextStyle` | `TextStyle` | Estilo del texto de las celdas de cabecera |
| `tableCellTextStyle` | `TextStyle` | Estilo del texto de las celdas de cuerpo |
| `tableCellPadding` | `EdgeInsets` | Padding dentro de cada celda |
| `tableInnerBorderSide` | `BorderSide` | Estilo de las líneas internas de la cuadrícula |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  tableCellPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  tableHeaderTextStyle: const TextStyle(fontWeight: FontWeight.w700),
)
```
