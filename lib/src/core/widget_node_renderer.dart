import 'package:flutter/widgets.dart';

import 'render_context.dart';

/// Renders a `:::widget` container node into a [Widget].
///
/// Subclass, implement [name] and [build], then register on [Markast]:
/// ```dart
/// markast.registerWidget(MyWidgetRenderer());
/// ```
abstract class WidgetNodeRenderer {
  const WidgetNodeRenderer();

  /// The widget name that triggers this renderer (e.g. `"callout"`).
  String get name;

  /// Build a widget from [props] and [slots]. [props] holds the key/value
  /// attributes on the opening fence; [slots] maps slot names to their child
  /// node lists. Call `ctx.markast.buildMixedBody` to render slot children.
  Widget build(
    RenderContext ctx,
    Map<String, dynamic> props,
    Map<String, List<Map<String, dynamic>>> slots,
  );
}
