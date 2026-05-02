# Negrita y Cursiva

Nodos de énfasis inline. Pueden anidarse y combinarse.

## Estructura AST

```json
{ "type": "bold",        "children": [{ "type": "text", "value": "negrita" }] }
{ "type": "italic",      "children": [{ "type": "text", "value": "cursiva" }] }
{ "type": "bold_italic", "children": [{ "type": "text", "value": "negrita y cursiva" }] }
```

| Tipo | HTML | Descripción |
|------|------|-------------|
| `bold` | `<strong>` | Énfasis fuerte |
| `italic` | `<em>` | Énfasis suave |
| `bold_italic` | `<strong><em>` | Ambos combinados |

Los tres aceptan `children` con cualquier nodo inline, permitiendo anidamiento: negrita dentro de cursiva, enlaces dentro de negrita, etc.

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `boldTextStyle` | `TextStyle` | Se combina con el estilo padre (por defecto `FontWeight.w700`) |
| `italicTextStyle` | `TextStyle` | Se combina con el estilo padre (por defecto `FontStyle.italic`) |
| `boldItalicTextStyle` | `TextStyle` | Peso y estilo combinados |

Estos estilos se **combinan** — heredan la familia tipográfica, tamaño y color del contexto y solo sobreescriben lo que se especifica.

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  boldTextStyle: const TextStyle(
    fontWeight: FontWeight.w800,
    color: Colors.black,
  ),
)
```
