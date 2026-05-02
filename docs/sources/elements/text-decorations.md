# Tachado y Subrayado

Decoraciones inline para texto eliminado o resaltado.

## Estructura AST

```json
{ "type": "strikethrough", "children": [{ "type": "text", "value": "precio antiguo" }] }
{ "type": "underline",     "children": [{ "type": "text", "value": "importante" }] }
```

| Tipo | HTML | Caso de uso |
|------|------|-------------|
| `strikethrough` | `<del>` | Contenido eliminado, texto tachado |
| `underline` | `<u>` | Énfasis, anotaciones de documento |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `strikethroughTextStyle` | `TextStyle` | Estilo de decoración (por defecto `TextDecoration.lineThrough`) |
| `underlineTextStyle` | `TextStyle` | Estilo de decoración (por defecto `TextDecoration.underline`) |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  strikethroughTextStyle: TextStyle(
    decoration: TextDecoration.lineThrough,
    color: Colors.red.withOpacity(.6),
  ),
  underlineTextStyle: TextStyle(
    decoration: TextDecoration.underline,
    decorationColor: Colors.blue,
    decorationThickness: 2,
  ),
)
```
