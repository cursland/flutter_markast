# Video

Un reproductor de video a nivel de bloque con imagen de portada e control de relación de aspecto opcionales.

## Estructura AST

```json
{
  "type": "video",
  "src": "https://example.com/clip.mp4",
  "poster": "https://example.com/thumb.jpg",
  "caption": "Demo de la app"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"video"` | ✓ | Tipo de nodo |
| `src` | string | ✓ | URL o ruta de asset del video |
| `poster` | string | — | Imagen de portada mostrada antes de la reproducción |
| `caption` | string | — | Texto mostrado bajo el reproductor |

## Comportamiento por defecto

Por defecto markast renderiza un marco de placeholder con la imagen de portada y un botón de play. La reproducción real se delega al callback `videoBuilder` — el predeterminado no reproduce automáticamente.

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `videoFrameDecoration` | `BoxDecoration` | Borde y fondo del contenedor exterior |
| `videoSrcTextStyle` | `TextStyle` | Estilo del texto del pie de foto |
| `videoSrcPadding` | `EdgeInsets` | Padding alrededor del pie de foto |
| `videoPlayButtonDecoration` | `BoxDecoration` | Fondo del círculo del botón de play |
| `videoPlayButtonSize` | `double` | Tamaño del contenedor del botón de play (por defecto `56`) |
| `videoPlayIconColor` | `Color` | Color del icono de play (por defecto blanco) |
| `videoPlayIconSize` | `double` | Tamaño del icono de play (por defecto `32`) |
| `videoAspectRatio` | `double` | Relación de aspecto del reproductor (por defecto `16/9`) |

## Reproductor de video personalizado

Reemplaza el contenido del reproductor con tu propio widget (p.ej. `video_player`, `chewie`, `youtube_player_flutter`):

```dart
markast.buildDocument(
  context,
  ast,
  videoBuilder: (src, {poster, aspectRatio = 16 / 9}) {
    return VideoPlayerWidget(
      url: src,
      thumbnail: poster,
      aspectRatio: aspectRatio,
    );
  },
)
```

El `videoBuilder` recibe solo el área de contenido. La decoración del marco exterior y el pie de foto siguen controlados por `MarkastTheme`.
