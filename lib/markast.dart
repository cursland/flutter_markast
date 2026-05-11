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
export 'src/ast/factory.dart'
    show
        astVersion,
        document,
        heading,
        paragraph,
        blockquote,
        codeBlock,
        image,
        video,
        listNode,
        listItem,
        table,
        tableHead,
        tableBody,
        tableRow,
        tableCell,
        divider,
        widgetNode,
        htmlBlock,
        footnoteDef,
        text,
        bold,
        italic,
        boldItalic,
        codeInline,
        link,
        strikethrough,
        underline,
        inlineImage,
        softbreak,
        hardbreak,
        footnoteRef;
export 'src/ast/walker.dart'
    show walk, find, findAll, replace, NodeMapper, Visitor;
export 'src/ast/utils.dart'
    show
        extractText,
        childrenOf,
        slotsOf,
        hasWarnings,
        countNodes,
        isBlock,
        isInline;
export 'src/ast/schema.dart' show jsonSchema;

// ── Parser API ────────────────────────────────────────────────────────────────
export 'src/config.dart' show ParserConfig, defaultConfig;
export 'src/document.dart' show Document;
export 'src/parser_api.dart' show Parser, parse, ConfigurationError;

// ── Rules / diagnostics ───────────────────────────────────────────────────────
export 'src/rules/codes.dart';
export 'src/rules/rule.dart' show Diagnostic, Rule, Severity;
export 'src/rules/builtin.dart' show BuiltinRules;

// ── Transforms ────────────────────────────────────────────────────────────────
export 'src/transforms/transform.dart' show Transform, TransformPipeline;
export 'src/transforms/normalize.dart' show NormalizeText;
export 'src/transforms/slugify.dart' show SlugifyHeadings;
export 'src/transforms/toc.dart' show BuildTOC;
export 'src/transforms/linkify.dart' show Linkify;
export 'src/transforms/typography.dart' show SmartTypography;
export 'src/transforms/builtin.dart' show builtinTransforms;

// ── Widget DSL (parser-side; the renderer-side widgets live in src/widgets/) ──
export 'src/widgets_dsl/base.dart'
    show BaseWidget, WidgetParam, WidgetParamType, WidgetPropsValidation;
// `WidgetRegistry` is intentionally hidden here — the renderer-side
// `WidgetRegistry` in src/core/widget_registry.dart owns that name (it has
// been part of the public API since 0.0.1). Consumers that need the
// parser-side registry import it explicitly via
// `package:markast/src/widgets_dsl/registry.dart` or just use
// `Parser.registry` to access the instance their parser owns.
export 'src/widgets_dsl/registry.dart'
    show defaultRegistry, WidgetRegistrationError;
export 'src/widgets_dsl/builtin/admonition.dart'
    show
        Admonition,
        TipWidget,
        NoteWidget,
        InfoWidget,
        WarningWidget,
        CautionWidget,
        DangerWidget;
export 'src/widgets_dsl/builtin/badge.dart' show BadgeWidget;
export 'src/widgets_dsl/builtin/card.dart' show CardWidget;
export 'src/widgets_dsl/builtin/code_collapse.dart' show CodeCollapseWidget;
export 'src/widgets_dsl/builtin/code_group.dart' show CodeGroupWidget;
export 'src/widgets_dsl/builtin/steps.dart' show StepsWidget;
export 'src/widgets_dsl/builtin/tabs.dart' show TabsWidget;
export 'src/widgets_dsl/builtin/video.dart' show VideoWidget;

// ── Core ──────────────────────────────────────────────────────────────────────
export 'src/core/markast.dart';
export 'src/core/markast_controller.dart';
export 'src/core/markast_link.dart';
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
//
// Markast ships two interchangeable backends. They share one interface
// (MarkastHighlighter) so MarkastTheme.highlightTheme accepts either.
//
// Backend A — re_highlight + Markast's enhanced grammars (default):
//   final ht = MarkastHighlightTheme(theme: MarkastCodeThemes.atomOneDark);
//
// Backend B — TextMate / VSCode-quality (opt-in, async setup):
//   final theme = await MarkastTextMateThemes.darkPlus();
//   final ht    = await MarkastTextMateHighlight.create(theme: theme);
//
// Both expose a `highlight(code, language, baseStyle) -> TextSpan?` method
// usable directly from any widget — see also [MarkastCodeBlock].
//
export 'src/highlight/markast_highlighter.dart';
export 'src/highlight/markast_highlight_theme.dart';
export 'src/highlight/markast_highlight_catalog.dart';
export 'src/highlight/grammars/_shared.dart' show MarkastScopes;
export 'src/highlight/grammars/markast_grammars.dart';
export 'src/highlight/textmate/markast_textmate_highlight.dart';
export 'src/highlight/textmate/markast_textmate_catalog.dart';
// Re-export HighlighterTheme so consumers don't need a direct
// `package:syntax_highlight` import.
export 'package:syntax_highlight/syntax_highlight.dart' show HighlighterTheme;

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
export 'src/widgets/markast_code_block.dart';

// ── Utilities ─────────────────────────────────────────────────────────────────
export 'src/util/timed_network_image.dart';
