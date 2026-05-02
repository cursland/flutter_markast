import 'package:flutter/widgets.dart';

import 'render_context.dart';

/// Renders an inline AST node into an [InlineSpan].
///
/// Inline renderers are composed inside one [Text.rich] per paragraph so
/// platform line-breaking, selection, and accessibility work natively.
///
/// Subclass, implement [type] and [build], then register on [Markast]:
/// ```dart
/// markast.registerInline(MyInlineRenderer());
/// ```
abstract class InlineRenderer {
  const InlineRenderer();

  /// The node `type` discriminator this renderer handles (e.g. `"bold"`).
  String get type;

  /// Build a span from [node]. [style] is the inherited text style from the
  /// parent span — merge your overlay on top of it rather than replacing it,
  /// so font family, size, and color cascade correctly.
  InlineSpan build(RenderContext ctx, Map<String, dynamic> node, TextStyle style);
}
