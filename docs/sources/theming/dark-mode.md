# Modo Oscuro

markast sigue automáticamente el brillo de tu app cuando se usa `MarkastTheme.fromTheme()`.

## Cómo funciona

`fromTheme()` lee `ThemeData.brightness` para seleccionar los valores predeterminados apropiados:

- App oscura → tema de resaltado `monokai`, colores de texto apropiados para modo oscuro
- App clara → tema de resaltado `xcode`, colores de texto apropiados para modo claro

## Automático con MaterialApp

Si tu app tiene tema claro y oscuro, markast se adapta a cada uno:

```dart
MaterialApp(
  theme: ThemeData.light(),
  darkTheme: ThemeData.dark(),
  themeMode: ThemeMode.system,
  // markast lee el brillo del tema activo
)
```

No se necesita ninguna configuración adicional.

## Tema oscuro manual

Si necesitas un `MarkastTheme` oscuro personalizado:

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      MarkastTheme.fromTheme(ThemeData.light()).copyWith(
        highlightTheme: MarkastHighlightTheme(theme: MarkastCodeThemes.xcode),
      ),
    ],
  ),
  darkTheme: ThemeData.dark().copyWith(
    extensions: [
      MarkastTheme.fromTheme(ThemeData.dark()).copyWith(
        highlightTheme: MarkastHighlightTheme(theme: MarkastCodeThemes.monokai),
      ),
    ],
  ),
)
```

## Forzar un tema específico

Pasa un tema explícito a `Markast()` para ignorar completamente el brillo de la app:

```dart
final markast = Markast(
  theme: MarkastTheme.fromTheme(ThemeData.dark()),
);
```
