# Inicio Rápido

## 1. Crear un AST

Tres formas equivalentes de obtener el JSON:

### a) Parsear Markdown en Dart (desde 0.0.2)

```dart
import 'package:markast/markast.dart';

final doc = parse('# ¡Hola!\n\nEsto es **markast**.');
final ast = doc.toMap();         // listo para buildDocument
print(doc.toJson(indent: 2));
print(doc.toMarkdown());          // roundtrip: AST → Markdown canónico
```

Con opciones avanzadas:

```dart
final parser = Parser(
  transforms: ['normalize', 'slugify', 'toc'],
  widgets: [() => MyCalloutWidget()],
);
final doc = parser.parse(markdownSource);
```

> `Document.toMarkdown()` cierra el roundtrip — útil cuando el AST es el formato de almacenamiento canónico (por ejemplo, dentro de un `.zip`) y necesitas mostrarlo en un editor de texto para que el usuario lo modifique antes de re-parsearlo.

### b) Generar el JSON en Python (build server / CMS)

```python
from markast import parse

doc = parse("# ¡Hola!\n\nEsto es **markast**.")
print(doc.to_json())
```

### c) Cargar JSON desde un asset

Útil cuando el contenido viene pre-procesado en el bundle de la app — ver paso 3.

## 2. Renderizar en Flutter

```dart
import 'package:markast/markast.dart';

final _markast = Markast();

// Ejemplo mínimo
Widget build(BuildContext context) {
  return _markast.buildDocument(context, {
    'type': 'document',
    'children': [
      {
        'type': 'heading',
        'level': 1,
        'children': [{'type': 'text', 'value': '¡Hola!'}],
      },
      {
        'type': 'paragraph',
        'children': [
          {'type': 'text', 'value': 'Esto es '},
          {
            'type': 'bold',
            'children': [{'type': 'text', 'value': 'markast'}],
          },
          {'type': 'text', 'value': '.'},
        ],
      },
    ],
  });
}
```

## 3. Cargar desde un archivo JSON

En una app real normalmente cargarás el AST desde un asset o una API:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';

Future<Map<String, dynamic>> loadDoc(String asset) async {
  final raw = await rootBundle.loadString(asset);
  return jsonDecode(raw) as Map<String, dynamic>;
}

// En tu widget:
FutureBuilder<Map<String, dynamic>>(
  future: loadDoc('assets/docs/article.json'),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const CircularProgressIndicator();
    return _markast.buildDocument(context, snapshot.data!);
  },
)
```

## 4. Gestionar enlaces

Los enlaces son no interactivos por defecto. Pasa `onLinkTap` para habilitarlos:

```dart
_markast.buildDocument(
  context,
  ast,
  onLinkTap: (url, title) => launchUrl(Uri.parse(url)),
)
```

## 5. Personalizar el tema

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(
    blockSpacing: 24,
    highlightTheme: MarkastHighlightTheme(
      theme: MarkastCodeThemes.monokai,
    ),
  ),
);
```
