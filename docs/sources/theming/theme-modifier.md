# themeModifier

`themeModifier` es la forma más sencilla de ajustar el tema predeterminado sin necesitar un `BuildContext` en el momento de la construcción.

## Sintaxis

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(
    blockSpacing: 24,
    listBulletMarker: '▸',
  ),
);
```

El callback recibe el `MarkastTheme` completamente resuelto (derivado automáticamente de `ThemeData`) y devuelve una copia modificada. Solo especificas lo que quieres cambiar — el resto se mantiene como fue derivado.

## Tipo

```dart
typedef MarkastThemeModifier = MarkastTheme Function(MarkastTheme base);
```

## themeModifier vs. tema explícito

| | `themeModifier` | `theme` |
|--|-----------------|---------|
| Recibe la base derivada automáticamente | ✓ | ✗ |
| Necesita BuildContext | ✗ | Depende |
| Reemplazo completo | ✗ | ✓ |
| Sigue los cambios de ThemeData | ✓ | ✗ |

Usa `themeModifier` para ajustes. Usa `theme` solo cuando necesites control total y mantengas el tema tú mismo.

## Objetos anidados

Para objetos de tema anidados como `MarkastHighlightTheme`, construye una nueva instancia directamente:

```dart
themeModifier: (base) => base.copyWith(
  highlightTheme: MarkastHighlightTheme(
    theme: MarkastCodeThemes.monokai,
  ),
)
```

## Deshabilitar una funcionalidad

Pasa `null` donde la propiedad lo acepta:

```dart
themeModifier: (base) => base.copyWith(
  highlightTheme: null, // deshabilita el resaltado de sintaxis
)
```
