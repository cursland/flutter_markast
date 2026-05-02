# Introducción

markast es una librería de renderizado de documentos multiplataforma construida sobre un **AST JSON tipado**. El contenido se escribe en Markdown, se analiza en un árbol estructurado y se renderiza de forma nativa en cada plataforma — widgets de Flutter en móvil/escritorio, HTML semántico en la web.

## Idea central

En lugar de pasar cadenas de HTML o Markdown sin procesar a un renderer, markast utiliza una representación intermedia bien definida:

```json
{
  "type": "document",
  "children": [
    {
      "type": "heading",
      "level": 1,
      "children": [{ "type": "text", "value": "Hola mundo" }]
    },
    {
      "type": "paragraph",
      "children": [
        { "type": "text", "value": "Este es un texto " },
        { "type": "bold", "children": [{ "type": "text", "value": "en negrita" }] },
        { "type": "text", "value": "." }
      ]
    }
  ]
}
```

Cualquier parser que produzca este formato es compatible. El parser oficial de Python es la implementación de referencia.

## Paquetes

| Paquete | Plataforma | Propósito |
|---------|------------|-----------|
| `markast` (Python) | Parser | Convierte Markdown → AST JSON, HTML o de vuelta a Markdown |
| `markast` (Flutter) | Renderer | Renderiza un AST JSON como widgets nativos de Flutter |

## Pipeline

```
article.md
    │
    ▼  python build.py
    ├── article.html   ← este sitio usa este archivo
    └── article.json   ← la app Flutter usa este archivo
```

## Sobre esta documentación

Cada página de este sitio está escrita en Markdown, analizada con la librería Python `markast` y convertida a HTML usando `build.py`. El AST JSON también se genera junto a cada página — puedes verlo reemplazando `.html` por `.json` en la ruta del contenido.
