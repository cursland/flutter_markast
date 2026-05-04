/// The three structural categories of a link URL inside a markast document.
enum MarkastLinkType {
  /// An in-document anchor (`#slug`). Resolved by [MarkastController.scrollTo].
  anchor,

  /// A relative path to another document (`./other.md`, `../dir/file.md`,
  /// or a bare path without a URI scheme). Resolved by the host application
  /// (load the referenced file, push a route, etc.).
  document,

  /// An absolute URI with a scheme (`https://`, `mailto:`, `tel:`, …).
  /// Resolved by the host application (typically `url_launcher`).
  external,
}

/// A parsed representation of a link URL encountered inside a markast document.
///
/// Use [MarkastLink.parse] inside your [onLinkTap] handler to classify the
/// URL and dispatch to the appropriate action:
///
/// ```dart
/// void _onLink(String url, String? title) {
///   final link = MarkastLink.parse(url);
///   switch (link.type) {
///     case MarkastLinkType.anchor:
///       _controller.scrollTo(link.anchor!);
///     case MarkastLinkType.document:
///       _router.open(link.path!, anchor: link.anchor);
///     case MarkastLinkType.external:
///       launchUrl(Uri.parse(link.raw));
///   }
/// }
/// ```
class MarkastLink {
  const MarkastLink._({
    required this.type,
    required this.raw,
    this.anchor,
    this.path,
  });

  /// The structural category of this link.
  final MarkastLinkType type;

  /// The original, unmodified URL string as it appears in the AST.
  final String raw;

  /// The anchor slug (without the leading `#`).
  ///
  /// Set for [MarkastLinkType.anchor] links, and optionally for
  /// [MarkastLinkType.document] links that carry a fragment
  /// (e.g. `./guide.md#installation` → `anchor = 'installation'`).
  /// `null` otherwise.
  final String? anchor;

  /// The path portion of a [MarkastLinkType.document] link, with any
  /// fragment stripped.
  ///
  /// Examples:
  /// - `./guide.md#section` → `'./guide.md'`
  /// - `../api/reference.md` → `'../api/reference.md'`
  ///
  /// `null` for anchor-only and external links.
  final String? path;

  /// Parses [url] and returns a [MarkastLink] with its [type] and derived
  /// fields populated.
  ///
  /// Classification rules:
  ///
  /// 1. Starts with `#` → [MarkastLinkType.anchor].
  /// 2. Matches `scheme://` (e.g. `https://`, `mailto:`, `tel:`) →
  ///    [MarkastLinkType.external].
  /// 3. Everything else → [MarkastLinkType.document] (relative path, with
  ///    optional `#fragment` separated out into [anchor]).
  factory MarkastLink.parse(String url) {
    // ── Anchor ───────────────────────────────────────────────────────────────
    if (url.startsWith('#')) {
      return MarkastLink._(
        type:   MarkastLinkType.anchor,
        raw:    url,
        anchor: url.substring(1),
      );
    }

    // ── External (has URI scheme) ─────────────────────────────────────────────
    if (_schemePattern.hasMatch(url)) {
      return MarkastLink._(type: MarkastLinkType.external, raw: url);
    }

    // ── Document (relative path, optional fragment) ───────────────────────────
    final hash = url.indexOf('#');
    if (hash == -1) {
      return MarkastLink._(
        type: MarkastLinkType.document,
        raw:  url,
        path: url,
      );
    }
    return MarkastLink._(
      type:   MarkastLinkType.document,
      raw:    url,
      path:   url.substring(0, hash),
      anchor: url.substring(hash + 1),
    );
  }

  // Matches any URI scheme: one letter followed by letters/digits/+/-/. and ':'
  static final _schemePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9+\-.]*:');

  @override
  String toString() => 'MarkastLink(type: $type, raw: "$raw")';
}
