import 'block_renderer.dart';
import 'inline_renderer.dart';

/// Maps node `type` strings to renderer instances. O(1) lookup via [Map].
/// Later registrations for the same type override earlier ones — this is how
/// consumers replace an official renderer with a custom one.
class NodeRegistry {
  final Map<String, BlockRenderer>  _blocks  = {};
  final Map<String, InlineRenderer> _inlines = {};

  /// Register a single block renderer, replacing any existing one for [BlockRenderer.type].
  void registerBlock(BlockRenderer renderer) =>
      _blocks[renderer.type] = renderer;

  /// Register a single inline renderer, replacing any existing one for [InlineRenderer.type].
  void registerInline(InlineRenderer renderer) =>
      _inlines[renderer.type] = renderer;

  /// Bulk-register block renderers.
  void registerAllBlocks(Iterable<BlockRenderer> renderers) {
    for (final r in renderers) { registerBlock(r); }
  }

  /// Bulk-register inline renderers.
  void registerAllInlines(Iterable<InlineRenderer> renderers) {
    for (final r in renderers) { registerInline(r); }
  }

  /// Returns the registered [BlockRenderer] for [type], or null if none.
  BlockRenderer? blockFor(String type) => _blocks[type];

  /// Returns the registered [InlineRenderer] for [type], or null if none.
  InlineRenderer? inlineFor(String type) => _inlines[type];
}
