# Código en Línea

Un span monoespaciado para referencias de código cortas dentro de una oración.

## Estructura AST

```json
{ "type": "code_inline", "value": "buildDocument" }
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"code_inline"` | ✓ | Tipo de nodo |
| `value` | string | ✓ | El texto de código sin procesar |

A diferencia de los nodos de bloque, el código inline no tiene `children` — solo un string `value`.

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `codeInlineTextStyle` | `TextStyle` | Fuente monoespaciada y tamaño |
| `codeInlineDecoration` | `BoxDecoration` | Fondo y borde de la píldora de código |
| `codeInlinePadding` | `EdgeInsets` | Padding interno (por defecto `horizontal: 5, vertical: 2`) |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  codeInlineTextStyle: TextStyle(
    fontFamily: 'JetBrains Mono',
    fontSize: 13,
  ),
  codeInlineDecoration: BoxDecoration(
    color: Colors.deepPurple.withOpacity(.08),
    borderRadius: BorderRadius.circular(4),
    border: Border.all(color: Colors.deepPurple.withOpacity(.2)),
  ),
)
```
