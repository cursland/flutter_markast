# Referencia a Nota al Pie

Un superíndice inline que enlaza a una definición de nota al pie al final del documento.

## Estructura AST

```json
{ "type": "footnote_ref", "label": "1" }
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"footnote_ref"` | ✓ | Tipo de nodo |
| `label` | string | ✓ | Debe coincidir con un `footnote_def` con el mismo label |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `footnoteRefTextStyle` | `TextStyle` | Estilo del número superíndice |

## Ejemplo completo de nota al pie

Consulta la página [Nota al Pie](content/elements/footnote.html) para el ejemplo completo combinando `footnote_ref` y `footnote_def`.
