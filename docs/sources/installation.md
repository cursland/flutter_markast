# Instalación

## Paquete Flutter

Agrega `markast` a tu `pubspec.yaml`:

```yaml
dependencies:
  markast: ^0.1.0
```

Luego ejecuta:

```bash
flutter pub get
```

Desde 0.1.0 el paquete incluye un **parser Markdown → AST nativo en Dart** además del renderer. No necesitas Python en producción si el contenido se parsea en la app.

### Verificar la instalación

```dart
import 'package:markast/markast.dart';

void main() {
  final doc = parse('# Hola, **markast**!');
  print(doc.toJson(indent: 2));
}
```

### Ruta local (desarrollo)

Si estás trabajando con una copia local de la librería:

```yaml
dependencies:
  markast:
    path: ../flutter_markast
```

## Parser Python (opcional)

Si prefieres pre-procesar Markdown en un build server o CMS, instala el parser Python:

```bash
pip install markast
```

Produce exactamente el mismo formato JSON que `parse()` en Dart, así que el renderer Flutter es idéntico para ambos orígenes.

```python
from markast import parse

doc = parse("# Hola, **markast**!")
print(doc.to_json())
```

## Requisitos

| Paquete | Versión mínima |
|---------|----------------|
| Flutter SDK | 3.0.0 |
| Dart SDK | 3.0.0 |
| `package:markdown` | ^7.2.2 (transitivo) |
| Python (opcional) | 3.9+ |
| `markast` (Python, opcional) | latest |
