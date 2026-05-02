# Visión General del Tema

markast es completamente personalizable. Cada propiedad visual es un primitivo de Flutter — no hay clases personalizadas que aprender.

## Cómo se resuelven los temas

Cuando se llama a `buildDocument`, el tema se resuelve en orden de prioridad:

1. `theme` explícito pasado a `Markast(theme: ...)`
2. Callback `themeModifier` aplicado a la base derivada
3. `Theme.of(context).extension<MarkastTheme>()` (registrado en MaterialApp)
4. `MarkastTheme.fromTheme(Theme.of(context))` — fallback derivado automáticamente

En la mayoría de los casos usarás la opción 2 (`themeModifier`) o la opción 3 (mediante `ThemeData.extensions`).

## Tema derivado automáticamente

`MarkastTheme.fromTheme(ThemeData)` construye un tema completo a partir del `ThemeData` de tu app:

- Los estilos de encabezado provienen de `textTheme.headlineLarge/Medium/Small/titleLarge/Medium/Small`
- El estilo de cuerpo proviene de `textTheme.bodyMedium`
- El color de los enlaces proviene de `colorScheme.primary`
- El tema de resaltado es `monokai` (oscuro) o `xcode` (claro)

Esto significa que markast se adapta automáticamente al tema Material de tu app.

## Tema global mediante ThemeData.extensions

Registra el tema una vez en `MaterialApp` y todas las instancias de `Markast` lo recogerán:

```dart
MaterialApp(
  theme: ThemeData.light().copyWith(
    extensions: [
      MarkastTheme.fromTheme(ThemeData.light()).copyWith(
        blockSpacing: 24,
        listBulletMarker: '▸',
      ),
    ],
  ),
)
```

## Sobreescritura por instancia

Para personalizaciones puntuales sin tocar el tema de la app:

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(
    blockSpacing: 32,
    codeBlockShowCopyButton: false,
  ),
);
```

## Propiedades disponibles del tema

Consulta la referencia completa en la página [MarkastTheme](content/api/markast-theme.html).
