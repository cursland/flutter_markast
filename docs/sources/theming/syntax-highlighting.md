# Resaltado de Sintaxis

Los bloques de código se resaltan usando `re_highlight`, un port de Flutter de highlight.js. Se incluyen más de 180 temas y 180+ lenguajes.

## Temas por defecto

`MarkastTheme.fromTheme()` los establece automáticamente:

| Brillo de la app | Tema por defecto |
|------------------|-----------------|
| Oscuro | `MarkastCodeThemes.monokai` |
| Claro | `MarkastCodeThemes.xcode` |

## Cambiar el tema

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(
    highlightTheme: MarkastHighlightTheme(
      theme: MarkastCodeThemes.tokyoNightDark,
    ),
  ),
);
```

## Temas disponibles

Accede a todos los temas mediante `MarkastCodeThemes`:

```dart
// Temas oscuros
MarkastCodeThemes.monokai
MarkastCodeThemes.monokaiSublime
MarkastCodeThemes.nightOwl
MarkastCodeThemes.tokyoNightDark
MarkastCodeThemes.atomOneDark
MarkastCodeThemes.githubDark
MarkastCodeThemes.vsCode2015
MarkastCodeThemes.nord
MarkastCodeThemes.dracula     // vía base16
MarkastCodeThemes.shadesOfPurple

// Temas claros
MarkastCodeThemes.xcode
MarkastCodeThemes.atomOneLight
MarkastCodeThemes.githubLight
MarkastCodeThemes.tokyoNightLight
MarkastCodeThemes.stackoverflowLight
MarkastCodeThemes.idea

// Variantes Base16 (175 temas)
MarkastCodeThemes.base16.dracula
MarkastCodeThemes.base16.gruvboxDarkMedium
MarkastCodeThemes.base16.solarizedDark
MarkastCodeThemes.base16.solarizedLight
MarkastCodeThemes.base16.rosPineDawn
```

## Deshabilitar el resaltado

```dart
themeModifier: (base) => base.copyWith(highlightTheme: null)
```

## Lenguajes soportados

El lenguaje se establece mediante el campo `language` de un nodo `code_block`. Los alias comunes funcionan automáticamente:

| Alias | Equivale a |
|-------|-----------|
| `js` | `javascript` |
| `ts` | `typescript` |
| `py` | `python` |
| `sh` | `bash` |
| `yml` | `yaml` |
| `rb` | `ruby` |
| `kt` | `kotlin` |
| `cs` | `csharp` |
