## 0.1.0

### Added — Markdown → AST en Dart

El paquete ahora puede parsear Markdown directamente, igualando la capacidad del parser de Python. Convertir y renderizar siguen siendo procesos independientes — el JSON producido es el mismo formato que consume `Markast().buildDocument(...)`.

- **`parse(text)`** y **`Parser`** — entrada pública equivalente a `markast.parse` / `markast.Parser` de Python.
- **`Document`** — fachada con `toMap()`, `toJson()`, `walk()`, `find()`, `findAll()`, `hasErrors`.
- **`ParserConfig`** — `features`, `diagnoseHtmlBlocks`, `maxWidgetDepth`, `jsonIndent`.
- **AST helpers** — `lib/src/ast/factory.dart` (constructores de nodos), `walker.dart` (`walk`/`find`/`findAll`/`replace`/`Visitor`), `utils.dart` (`extractText`, `countNodes`, `hasWarnings`, …), `schema.dart` (`jsonSchema()`).
- **Reglas (W001–W009)** — diagnósticos que nunca rompen el parse (imagen en heading, prop inválido, widget desconocido, footnote colgante, anidamiento profundo).
- **Widget DSL parser-side** — `BaseWidget`, `WidgetParam`, `WidgetRegistry`, `defaultRegistry` + builtins (`tip`/`note`/`info`/`warning`/`caution`/`danger`, `card`, `video`, `code-group`, `code-collapse`, `tabs`, `steps`, `badge`).
- **Transforms** — `NormalizeText` (`normalize`), `SlugifyHeadings` (`slugify`), `BuildTOC` (`toc`), `Linkify` (`linkify`), `SmartTypography` (`smarttypography`).
- **Nuevas constantes en `NodeType`** — `headingAllowedInline`, `tableCellAllowedInline`.
- **Smoke test** — `test/parity_smoke.dart` compara contra el JSON de referencia generado por el parser Python.

### Notas

- Motor markdown subyacente: [`package:markdown`](https://pub.dev/packages/markdown) `^7.2.2` (CommonMark + GFM tables/strikethrough/tasklists/autolinks/footnotes). Custom `BlockSyntax` para los contenedores `:::widget`.
- El renderer-side `WidgetRegistry` (en `src/core/widget_registry.dart`) sigue siendo el que se exporta como `WidgetRegistry`. El nuevo registry parser-side (`src/widgets_dsl/registry.dart`) se accede vía `Parser.registry` o importándolo explícitamente.

## 0.0.1

Initial release.
