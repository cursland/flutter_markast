/// markast — Flutter renderer for the markast AST convention.
///
/// Consumes the typed JSON tree produced by the markast Python parser (or any
/// parser following the same node convention) and renders it as native Flutter
/// widgets. Fully themeable, extensible via custom renderers.
///
/// ```dart
/// final markast = Markast();
///
/// Widget build(BuildContext context) {
///   return markast.buildDocument(context, jsonAst,
///     onLinkTap: (url, _) => launchUrl(Uri.parse(url)),
///   );
/// }
/// ```
library;

// ── AST ───────────────────────────────────────────────────────────────────────
export 'src/ast/node_types.dart';

// ── Core ──────────────────────────────────────────────────────────────────────
export 'src/core/markast.dart';
export 'src/core/render_context.dart'
    show RenderContext, MarkastImageBuilder, MarkastVideoBuilder;
export 'src/core/block_renderer.dart';
export 'src/core/inline_renderer.dart';
export 'src/core/widget_node_renderer.dart';
export 'src/core/node_registry.dart';
export 'src/core/widget_registry.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
export 'src/theme/markast_theme.dart';

// ── Syntax highlighting ───────────────────────────────────────────────────────
export 'src/highlight/markast_highlight_theme.dart';
export 'src/highlight/markast_highlight_catalog.dart';

// ── Official renderers (exported so consumers can subclass or compose) ────────
export 'src/nodes/blocks/blockquote_node.dart';
export 'src/nodes/blocks/code_block_node.dart';
export 'src/nodes/blocks/divider_node.dart';
export 'src/nodes/blocks/document_node.dart';
export 'src/nodes/blocks/footnote_def_node.dart';
export 'src/nodes/blocks/heading_node.dart';
export 'src/nodes/blocks/html_block_node.dart';
export 'src/nodes/blocks/image_node.dart';
export 'src/nodes/blocks/list_node.dart';
export 'src/nodes/blocks/paragraph_node.dart';
export 'src/nodes/blocks/table_node.dart';
export 'src/nodes/blocks/video_node.dart';
export 'src/nodes/blocks/widget_node.dart';

export 'src/nodes/inline/bold_inline.dart';
export 'src/nodes/inline/bold_italic_inline.dart';
export 'src/nodes/inline/break_inline.dart';
export 'src/nodes/inline/code_inline.dart';
export 'src/nodes/inline/footnote_ref_inline.dart';
export 'src/nodes/inline/inline_image.dart';
export 'src/nodes/inline/italic_inline.dart';
export 'src/nodes/inline/link_inline.dart';
export 'src/nodes/inline/strikethrough_inline.dart';
export 'src/nodes/inline/text_inline.dart';
export 'src/nodes/inline/underline_inline.dart';

export 'src/widgets/callout_widget.dart';

// ── Utilities ─────────────────────────────────────────────────────────────────
export 'src/util/timed_network_image.dart';
