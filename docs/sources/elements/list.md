# Lista

Listas ordenadas y desordenadas, con soporte para anidamiento y elementos de lista de tareas.

## Estructura AST

### Lista desordenada

```json
{
  "type": "list",
  "ordered": false,
  "children": [
    {
      "type": "list_item",
      "children": [{ "type": "text", "value": "Primer elemento" }]
    },
    {
      "type": "list_item",
      "children": [{ "type": "text", "value": "Segundo elemento" }]
    }
  ]
}
```

### Lista ordenada

```json
{
  "type": "list",
  "ordered": true,
  "start": 1,
  "children": [...]
}
```

### Elemento de lista de tareas

```json
{
  "type": "list_item",
  "checked": true,
  "children": [{ "type": "text", "value": "Tarea completada" }]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `type` | `"list"` | ✓ | Tipo de nodo |
| `ordered` | bool | ✓ | `true` para numerada, `false` para viñetas |
| `start` | int | — | Número inicial para listas ordenadas (por defecto `1`) |
| `children` | `list_item[]` | ✓ | Elementos de la lista |
| `list_item.checked` | bool | — | Presente en elementos de lista de tareas |

## Propiedades del tema en Flutter

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `listMarkerTextStyle` | `TextStyle` | Estilo de la viñeta o número |
| `listMarkerWidth` | `double` | Ancho de la columna del marcador (por defecto `22`) |
| `listItemSpacing` | `double` | Espacio vertical entre elementos (por defecto `6`) |
| `listBulletMarker` | `String` | Carácter de viñeta para listas desordenadas (por defecto `•`) |

## Personalización

```dart
themeModifier: (base) => base.copyWith(
  listBulletMarker: '▸',
  listItemSpacing: 8,
  listMarkerWidth: 24,
)
```
