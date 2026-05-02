import 'package:flutter/widgets.dart';

import 'render_context.dart';

/// Renders a block-level AST node into a [Widget].
///
/// Subclass, implement [type] and [build], then register on [Markast]:
/// ```dart
/// markast.registerBlock(MyBlockRenderer());
/// ```
/// Later registrations for the same [type] override earlier ones.
abstract class BlockRenderer {
  const BlockRenderer();

  /// The node `type` discriminator this renderer handles (e.g. `"heading"`).
  String get type;

  /// Build a widget from [node]. [ctx] carries the theme, context, and all
  /// per-render state. Call `ctx.markast.buildBlocks` / `buildInlines` to
  /// recurse into children.
  Widget build(RenderContext ctx, Map<String, dynamic> node);
}
