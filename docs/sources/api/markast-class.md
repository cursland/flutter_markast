# Clase Markast

El punto de entrada principal para el renderizado. Con una instancia por app es suficiente.

## Constructores

### `Markast()`

Crea una instancia precargada con todos los renderers oficiales.

```dart
final markast = Markast();

// Con ajustes de tema
final markast = Markast(
  themeModifier: (base) => base.copyWith(blockSpacing: 24),
);

// Con reemplazo completo del tema
final markast = Markast(
  theme: MarkastTheme.fromTheme(myThemeData),
);
```

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `theme` | `MarkastTheme?` | Reemplaza por completo el tema derivado automáticamente |
| `themeModifier` | `MarkastThemeModifier?` | Callback para ajustar el tema derivado automáticamente |

### `Markast.empty()`

Crea una instancia **sin renderers**. Úsalo cuando quieras registrar solo tus propios renderers:

```dart
final markast = Markast.empty()
  ..registerBlock(MyHeadingRenderer())
  ..registerBlock(MyParagraphRenderer());
```

## Métodos

### `buildDocument`

Renderiza el nodo raíz de un AST JSON de markast en un árbol de widgets.

```dart
Widget buildDocument(
  BuildContext context,
  Map<String, dynamic> document, {
  void Function(String url, String? title)? onLinkTap,
  MarkastImageBuilder? imageBuilder,
  MarkastVideoBuilder? videoBuilder,
  void Function(String code)? onCodeCopy,
})
```

| Parámetro | Descripción |
|-----------|-------------|
| `context` | `BuildContext` de Flutter — se usa para resolver el tema |
| `document` | El nodo raíz `{"type": "document", ...}` |
| `onLinkTap` | Se llama al tocar un enlace. Los enlaces no son interactivos si es `null` |
| `imageBuilder` | Fábrica de widgets personalizada para imágenes |
| `videoBuilder` | Fábrica de widgets personalizada para videos |
| `onCodeCopy` | Se llama al tocar el botón de copiar. Por defecto usa `Clipboard.setData` |

### `registerBlock`

Registra un renderer de bloque personalizado, reemplazando el existente para el mismo `type`.

```dart
markast.registerBlock(MyVideoRenderer());
```

### `registerInline`

Registra un renderer de inline personalizado.

```dart
markast.registerInline(MyHighlightRenderer());
```

### `registerWidget`

Registra un renderer de widget personalizado.

```dart
markast.registerWidget(MyCarouselRenderer());
```

### `resolveTheme`

Devuelve el `MarkastTheme` resuelto para un contexto dado. Útil si necesitas el tema fuera de una llamada de renderizado.

```dart
final theme = markast.resolveTheme(context);
```

Orden de prioridad:
1. `theme` explícito pasado al constructor
2. `themeModifier` aplicado al tema base
3. `Theme.of(context).extension<MarkastTheme>()`
4. `MarkastTheme.fromTheme(Theme.of(context))`
