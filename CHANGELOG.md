## 0.0.3

### Added — AST → Markdown

Cierra el roundtrip completo: ya se puede serializar de vuelta el AST a texto Markdown canónico. Junto con el parser de 0.1.0 permite usar el AST como source of truth (almacenar JSON, abrir en un editor de texto convirtiéndolo a MD, volver a parsear al guardar).

- **`MarkdownRenderer`** (`lib/src/render/markdown_renderer.dart`) — recorre el AST y emite Markdown. Subclaseable: override `_block_*` / `_inline_*` para personalizar.
- **`Document.toMarkdown({renderer, registry})`** — atajo de instancia. Acepta un renderer o registry custom.
- **`BaseWidget.toMarkdown(node, renderChildren)`** — nuevo método con implementación por defecto (`:::name k="v"` + slots con `# slot-name`). Overrides en `BadgeWidget`, `VideoWidget`, `CodeGroupWidget`, `CodeCollapseWidget`, `TabsWidget`, `StepsWidget` que usan formas custom.
- **`formatProps(props)`** — helper expuesto para que widgets custom puedan reusar la misma política de comillas.

### Tests

- `test/roundtrip_test.dart` — verifica que `parse(md).toMarkdown()` re-parseada produce un AST estructuralmente equivalente.

## 0.0.2

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
