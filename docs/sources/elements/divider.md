# Divisor

Una regla horizontal que separa secciones.

## Estructura AST

```json
{
  "type": "divider"
}
```

Sin hijos ni campos adicionales.

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `dividerColor` | `Color` | Color de la línea |
| `dividerThickness` | `double` | Grosor de la línea en píxeles lógicos (por defecto `1`) |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  dividerColor: Colors.purple.withOpacity(.3),
  dividerThickness: 2,
)
```
