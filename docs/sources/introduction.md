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

Cualquier parser que produzca este formato es compatible. El parser oficial de Python es la implementación de referencia, y desde la versión 0.1.0 el paquete Flutter incluye su propio parser Dart para construir el AST en la app sin necesidad de un servidor.

## Paquetes

| Paquete | Plataforma | Propósito |
|---------|------------|-----------|
| `markast` (Python) | Parser | Convierte Markdown → AST JSON, HTML o de vuelta a Markdown |
| `markast` (Flutter) | Parser + Renderer | Parsea Markdown → AST en Dart y lo renderiza como widgets nativos |

Convertir (Markdown → AST) y renderizar (AST → widgets) son procesos independientes. Puedes generar el JSON en Dart, en Python o cargarlo desde un asset/API — al renderer le da igual.

## Pipeline

```
article.md ─┐
            ├─►  AST JSON  ─►  widgets / HTML / Markdown
JSON asset ─┘
```

Tres orígenes válidos del AST:

* En la app Flutter: `parse('# Hola')` (motor Dart, sin servidor).
* En el build server: `python -m markast parse article.md --format json`.
* Cualquier backend que emita JSON respetando el `type` discriminator.

## Sobre esta documentación

Cada página de este sitio está escrita en Markdown, analizada con la librería Python `markast` y convertida a HTML usando `build.py`. El AST JSON también se genera junto a cada página — puedes verlo reemplazando `.html` por `.json` en la ruta del contenido.
