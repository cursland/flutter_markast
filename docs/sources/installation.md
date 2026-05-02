# Instalación

## Paquete Flutter

Agrega `markast` a tu `pubspec.yaml`:

```yaml
dependencies:
  markast: ^1.0.0
```

Luego ejecuta:

```bash
flutter pub get
```

### Ruta local (desarrollo)

Si estás trabajando con una copia local de la librería:

```yaml
dependencies:
  markast:
    path: ../markast_flutter
```

## Parser Python

Instala con pip para convertir archivos Markdown a JSON:

```bash
pip install markast
```

### Verificar la instalación

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
| Python | 3.9+ |
| markast (Python) | latest |
