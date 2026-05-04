import 'package:flutter/widgets.dart';

/// Controls anchor-based in-document navigation for a rendered markast
/// document.
///
/// Create one instance per screen, pass it to [Markast.buildDocument], and
/// call [scrollTo] from your [onLinkTap] handler when an anchor link is
/// tapped. Dispose the controller from [State.dispose] to release all keys.
///
/// ```dart
/// class _PageState extends State<Page> {
///   final _controller = MarkastController();
///
///   @override
///   void dispose() {
///     _controller.dispose();
///     super.dispose();
///   }
///
///   void _onLink(String url, String? title) {
///     final link = MarkastLink.parse(url);
///     switch (link.type) {
///       case MarkastLinkType.anchor:
///         _controller.scrollTo(link.anchor!);
///       case MarkastLinkType.external:
///         launchUrl(Uri.parse(url));
///       case MarkastLinkType.document:
///         _loadDocument(link.path!);
///     }
///   }
///
///   @override
///   Widget build(BuildContext context) => markast.buildDocument(
///     context, ast,
///     controller: _controller,
///     onLinkTap: _onLink,
///   );
/// }
/// ```
///
/// ### How anchor registration works
///
/// Headings are registered automatically during the render pass whenever a
/// heading node carries an `id` field. The markast Python parser populates
/// this field when the `slugify` transform is active:
///
/// ```python
/// parser = Parser(transforms=['slugify'], widgets=[...])
/// ```
///
/// Each `id` value maps to a stable [GlobalKey] that tracks the heading's
/// position in the widget tree and is reused across rebuilds.
class MarkastController {
  final Map<String, GlobalKey> _anchors = {};

  // ── Internal API (used by HeadingNodeRenderer) ──────────────────────────────

  /// Registers a heading [slug] and returns a stable [GlobalKey].
  ///
  /// Safe to call multiple times with the same slug — the same key is returned
  /// on every call, preserving stability across rebuilds.
  GlobalKey registerAnchor(String slug) =>
      _anchors.putIfAbsent(slug, GlobalKey.new);

  // ── Public API ───────────────────────────────────────────────────────────────

  /// Whether [slug] was registered during the current render pass.
  bool hasAnchor(String slug) => _anchors.containsKey(slug);

  /// All slugs registered in the current document.
  Set<String> get anchors => Set.unmodifiable(_anchors.keys);

  /// Scrolls the nearest [Scrollable] ancestor until the heading identified
  /// by [slug] is visible in the viewport.
  ///
  /// - [alignment] controls where in the viewport the heading lands:
  ///   `0.0` = top edge (default), `0.5` = centre, `1.0` = bottom edge.
  /// - Does nothing if [slug] is unknown or the widget is not yet mounted.
  Future<void> scrollTo(
    String slug, {
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOut,
    double alignment = 0.0,
  }) async {
    final ctx = _anchors[slug]?.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration:  duration,
      curve:     curve,
      alignment: alignment,
    );
  }

  /// Releases all registered [GlobalKey]s.
  ///
  /// Call from [State.dispose] when the screen that owns this controller is
  /// removed from the widget tree.
  void dispose() => _anchors.clear();
}
