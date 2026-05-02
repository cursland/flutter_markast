# Nota al Pie

Las notas al pie son un sistema de dos partes: una referencia inline (`footnote_ref`) en el texto y una definición de bloque (`footnote_def`) al final del documento.

## Definición de nota — Estructura AST

```json
{
  "type": "footnote_def",
  "label": "1",
  "children": [
    {
      "type": "paragraph",
      "children": [{ "type": "text", "value": "Este es el texto de la nota al pie." }]
    }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"footnote_def"` | ✓ | Tipo de nodo |
| `label` | string | ✓ | Identificador único — debe coincidir con el label de `footnote_ref` |
| `children` | nodos de bloque | ✓ | Contenido de la nota al pie |

## Referencia de nota — Estructura AST

```json
{ "type": "footnote_ref", "label": "1" }
```

Se coloca inline dentro de un párrafo. Renderiza como un número superíndice que enlaza a la definición.

## Ejemplo completo

```json
{
  "type": "document",
  "children": [
    {
      "type": "paragraph",
      "children": [
        { "type": "text", "value": "Flutter es genial" },
        { "type": "footnote_ref", "label": "1" },
        { "type": "text", "value": "." }
      ]
    },
    {
      "type": "footnote_def",
      "label": "1",
      "children": [
        { "type": "paragraph", "children": [{ "type": "text", "value": "Según sus creadores." }] }
      ]
    }
  ]
}
```

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `footnoteDefLabelTextStyle` | `TextStyle` | Estilo de la etiqueta en la definición |
| `footnoteDefSpacing` | `double` | Espacio entre definiciones de notas |
| `footnoteRefTextStyle` | `TextStyle` | Estilo de la referencia superíndice |
