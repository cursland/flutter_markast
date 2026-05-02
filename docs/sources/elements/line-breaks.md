# Saltos de Línea

Existen dos tipos de saltos para controlar el flujo dentro del contenido inline.

## Tipos

| Tipo | HTML | Comportamiento |
|------|------|----------------|
| `softbreak` | nueva línea | Se colapsa a un espacio en la mayoría de los renderers |
| `hardbreak` | `<br>` | Fuerza un salto de línea visible |

## Estructura AST

```json
{
  "type": "paragraph",
  "children": [
    { "type": "text",      "value": "Primera línea" },
    { "type": "hardbreak" },
    { "type": "text",      "value": "Segunda línea" }
  ]
}
```

```json
{
  "type": "paragraph",
  "children": [
    { "type": "text",     "value": "Texto" },
    { "type": "softbreak" },
    { "type": "text",     "value": "unido" }
  ]
}
```

## Comportamiento en Flutter

- `hardbreak` → inserta `\n` en el árbol de `TextSpan`, forzando una nueva línea
- `softbreak` → inserta un carácter de espacio

Ninguno tiene propiedades de tema.
