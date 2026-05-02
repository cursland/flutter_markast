# Encabezado

Un nodo de encabezado se corresponde con `<h1>`–`<h6>` en HTML y con un widget `Text` con estilo escalado en Flutter. El nivel controla la jerarquía visual.

## Estructura AST

```json
{
  "type": "heading",
  "level": 2,
  "children": [
    { "type": "text", "value": "Título de sección" }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"heading"` | ✓ | Tipo de nodo |
| `level` | `1`–`6` | ✓ | Nivel del encabezado |
| `children` | nodos inline | ✓ | Contenido del encabezado — puede incluir negrita, cursiva, código, enlaces |
| `id` | string | — | Atributo id HTML para anclas (`<h2 id="...">`) |

## Propiedades del tema en Flutter

Controla la apariencia de los encabezados mediante `MarkastTheme`:

| Propiedad | Tipo | Controla |
|-----------|------|---------|
| `h1TextStyle` | `TextStyle` | Tamaño, peso, color de `<h1>` |
| `h2TextStyle` | `TextStyle` | Tamaño, peso, color de `<h2>` |
| `h3TextStyle` | `TextStyle` | Tamaño, peso, color de `<h3>` |
| `h4TextStyle` | `TextStyle` | Tamaño, peso, color de `<h4>` |
| `h5TextStyle` | `TextStyle` | Tamaño, peso, color de `<h5>` |
| `h6TextStyle` | `TextStyle` | Tamaño, peso, color de `<h6>` |
| `headingPadding` | `EdgeInsets` | Espacio superior e inferior en todos los niveles |

`MarkastTheme.fromTheme()` deriva automáticamente los seis estilos a partir de `ThemeData.textTheme` de tu app, por lo que respetan tu tema Material de serie.

## Personalización

```dart
final markast = Markast(
  themeModifier: (base) => base.copyWith(
    h1TextStyle: const TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    h2TextStyle: const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w700,
    ),
    headingPadding: const EdgeInsets.only(top: 32, bottom: 8),
  ),
);
```

## Con id de ancla

El campo `id` genera un ancla HTML y es útil para enlaces profundos dentro del documento:

```json
{
  "type": "heading",
  "level": 2,
  "id": "instalacion",
  "children": [{ "type": "text", "value": "Instalación" }]
}
```

Renderiza como `<h2 id="instalacion">Instalación</h2>`, enlazable mediante `#instalacion`.

## Hijos inline

Los hijos de un encabezado siguen las mismas reglas que los inline de un párrafo — negrita, cursiva, código y enlaces son todos válidos:

```json
{
  "type": "heading",
  "level": 3,
  "children": [
    { "type": "text", "value": "El método " },
    { "type": "code_inline", "value": "buildDocument" }
  ]
}
```
