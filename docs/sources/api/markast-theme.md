# MarkastTheme

`MarkastTheme` es un `ThemeExtension` que controla cada aspecto visual de los renderers oficiales. Todos los campos son primitivos de Flutter — no hay clases personalizadas que aprender.

## Crear un tema

Siempre parte de `fromTheme()` y sobreescribe lo que necesites:

```dart
MarkastTheme.fromTheme(Theme.of(context)).copyWith(
  blockSpacing: 24,
  listBulletMarker: '▸',
)
```

O mediante `themeModifier` en la instancia de `Markast`:

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(blockSpacing: 24),
);
```

## Propiedades de layout

| Propiedad | Tipo | Por defecto | Descripción |
|-----------|------|-------------|-------------|
| `maxContentWidth` | `double` | `720` | Ancho máximo del documento |
| `documentPadding` | `EdgeInsets` | `LTRB(20,16,20,32)` | Padding por defecto del documento |
| `compactDocumentPadding` | `EdgeInsets` | `LTRB(16,12,16,28)` | Padding en pantallas pequeñas |
| `wideDocumentPadding` | `EdgeInsets` | `LTRB(24,24,24,48)` | Padding en pantallas anchas |
| `compactBreakpoint` | `double` | `600` | Ancho por debajo del cual se usa el padding compacto |
| `wideBreakpoint` | `double` | `1024` | Ancho por encima del cual se usa el padding amplio |
| `blockSpacing` | `double` | `16` | Espacio vertical entre elementos de bloque |

## Tipografía

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `bodyTextStyle` | `TextStyle` | Estilo base para párrafos y texto de cuerpo |
| `h1TextStyle` – `h6TextStyle` | `TextStyle` | Estilos de encabezado por nivel |
| `headingPadding` | `EdgeInsets` | Espacio alrededor de todos los encabezados |
| `boldTextStyle` | `TextStyle` | Se combina con el estilo padre para negrita |
| `italicTextStyle` | `TextStyle` | Se combina con el estilo padre para cursiva |
| `boldItalicTextStyle` | `TextStyle` | Negrita + cursiva combinados |
| `strikethroughTextStyle` | `TextStyle` | Decoración de tachado |
| `underlineTextStyle` | `TextStyle` | Decoración de subrayado |
| `linkTextStyle` | `TextStyle` | Color y decoración para enlaces |
| `codeInlineTextStyle` | `TextStyle` | Fuente y tamaño para código en línea |
| `codeInlineDecoration` | `BoxDecoration` | Fondo y borde del código en línea |
| `codeInlinePadding` | `EdgeInsets` | Padding interno del código en línea |

## Bloque de código

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `codeBlockTextStyle` | `TextStyle` | Fuente monoespaciada y tamaño |
| `codeBlockDecoration` | `BoxDecoration` | Fondo y borde del bloque |
| `codeBlockPadding` | `EdgeInsets` | Padding interno del área de código |
| `codeBlockHeaderDecoration` | `BoxDecoration` | Fondo de la barra de encabezado |
| `codeBlockShowCopyButton` | `bool` | Mostrar u ocultar el botón de copiar |
| `codeBlockCopyIconColor` | `Color` | Color del icono de copiar |
| `highlightTheme` | `MarkastHighlightTheme?` | Tema de resaltado de sintaxis |

## Listas

| Propiedad | Tipo | Por defecto | Descripción |
|-----------|------|-------------|-------------|
| `listMarkerTextStyle` | `TextStyle` | — | Estilo de las viñetas o números |
| `listMarkerWidth` | `double` | `22` | Ancho reservado para la columna del marcador |
| `listItemSpacing` | `double` | `6` | Espacio entre elementos de la lista |
| `listBulletMarker` | `String` | `'•'` | Carácter usado para viñetas de listas desordenadas |

## Resaltado de sintaxis

```dart
themeModifier: (base) => base.copyWith(
  highlightTheme: MarkastHighlightTheme(
    theme: MarkastCodeThemes.monokai,        // oscuro
    // theme: MarkastCodeThemes.xcode,       // claro
    // theme: MarkastCodeThemes.base16.dracula,
  ),
)
```

`MarkastTheme.fromTheme()` selecciona automáticamente `monokai` (oscuro) o `xcode` (claro). Pasa `null` para deshabilitar el resaltado completamente.
