import 'widget_node_renderer.dart';

/// Maps widget names to [WidgetNodeRenderer] instances. O(1) lookup via [Map].
/// Later registrations for the same name override earlier ones.
class WidgetRegistry {
  final Map<String, WidgetNodeRenderer> _renderers = {};

  /// Register a single widget renderer, replacing any existing one for [WidgetNodeRenderer.name].
  void register(WidgetNodeRenderer renderer) =>
      _renderers[renderer.name] = renderer;

  /// Bulk-register widget renderers.
  void registerAll(Iterable<WidgetNodeRenderer> renderers) {
    for (final r in renderers) { register(r); }
  }

  /// Returns the registered [WidgetNodeRenderer] for [name], or null if none.
  WidgetNodeRenderer? rendererFor(String name) => _renderers[name];
}
