# Bloque de Código

Un bloque de código delimitado con resaltado de sintaxis opcional, insignia de lenguaje, encabezado con nombre de archivo y botón de copiar.

## Estructura AST

```json
{
  "type": "code_block",
  "language": "dart",
  "value": "final markast = Markast();\nmarkast.buildDocument(context, ast);"
}
```

Con nombre de archivo:

```json
{
  "type": "code_block",
  "language": "dart",
  "filename": "lib/main.dart",
  "value": "void main() => runApp(const App());"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"code_block"` | ✓ | Tipo de nodo |
| `value` | string | ✓ | Contenido del código sin procesar |
| `language` | string | — | Identificador de lenguaje para el resaltado (`dart`, `python`, `json`, …) |
| `filename` | string | — | Se muestra en la barra de encabezado sobre el código |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Controla |
|-----------|------|---------|
| `codeBlockTextStyle` | `TextStyle` | Fuente y tamaño del texto del código |
| `codeBlockDecoration` | `BoxDecoration` | Fondo y borde del bloque completo |
| `codeBlockPadding` | `EdgeInsets` | Padding interno del área de código |
| `codeBlockHeaderDecoration` | `BoxDecoration` | Fondo de la barra de encabezado |
| `codeBlockHeaderPadding` | `EdgeInsets` | Padding de la barra de encabezado |
| `codeBlockFilenameTextStyle` | `TextStyle` | Estilo de la etiqueta de nombre de archivo |
| `codeBlockLanguageTextStyle` | `TextStyle` | Estilo del texto de la insignia de lenguaje |
| `codeBlockLanguageBadgeDecoration` | `BoxDecoration` | Fondo de la píldora de lenguaje |
| `codeBlockLanguageBadgePadding` | `EdgeInsets` | Padding dentro de la píldora de lenguaje |
| `codeBlockShowCopyButton` | `bool` | Mostrar u ocultar el botón de copiar (por defecto `true`) |
| `codeBlockCopyIconColor` | `Color` | Color del icono de copiar |
| `codeBlockCopyIconSize` | `double` | Tamaño del icono de copiar |
| `highlightTheme` | `MarkastHighlightTheme?` | Tema de resaltado de sintaxis — `null` deshabilita el resaltado |

## Resaltado de sintaxis

El resaltado está impulsado por `re_highlight`. Establece el tema mediante `MarkastTheme`:

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(
    highlightTheme: MarkastHighlightTheme(
      theme: MarkastCodeThemes.monokai,
    ),
  ),
);
```

`MarkastTheme.fromTheme()` selecciona automáticamente `monokai` (oscuro) o `xcode` (claro) según el brillo de tu app.

## Callback de copiar

Por defecto el botón de copiar escribe al portapapeles del sistema. Sobreescríbelo con `onCodeCopy`:

```dart
markast.buildDocument(
  context,
  ast,
  onCodeCopy: (code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Copiado!')),
    );
  },
);
```

## Deshabilitar el botón de copiar

```dart
themeModifier: (base) => base.copyWith(
  codeBlockShowCopyButton: false,
)
```
