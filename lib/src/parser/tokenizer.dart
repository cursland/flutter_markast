/// Tokenizer — wraps `package:markdown` and exposes a single `tokenize`
/// method that returns the top-level `List<md.Node>` for a markdown string.
///
/// Equivalent of `markast.parser.tokenizer.Tokenizer`. We pre-build the
/// `md.Document` per parser so a long-running app reuses the same syntax set
/// across many parses.
library;

import 'package:markdown/markdown.dart' as md;

import '../widgets_dsl/registry.dart';
import 'container_syntax.dart';

class Tokenizer {
  Tokenizer(this._registry) {
    _document = _buildDocument();
  }

  final WidgetRegistry _registry;
  late final md.Document _document;

  md.Document get document => _document;

  md.Document _buildDocument() {
    // Build the syntax set explicitly so we can:
    //  * Enable GFM tables, strikethrough, autolinks, tasklists, footnotes.
    //  * Insert the markast :::widget container syntax with high priority.
    //  * Keep header IDs OUT (markast attaches its own ids via the slugify
    //    transform, see lib/src/transforms/slugify.dart). Auto-generated
    //    ids from package:markdown would otherwise pollute the AST.
    final base = md.ExtensionSet.gitHubFlavored;

    final blockSyntaxes = <md.BlockSyntax>[
      const WidgetContainerSyntax(),
      ...base.blockSyntaxes,
    ];
    final inlineSyntaxes = <md.InlineSyntax>[
      ...base.inlineSyntaxes,
    ];

    return md.Document(
      extensionSet: md.ExtensionSet(blockSyntaxes, inlineSyntaxes),
      // Don't encode HTML — we'll feed the raw inline content to text nodes
      // and let the renderer handle escaping when it produces a string.
      encodeHtml: false,
    );
  }

  /// Parse [text] into top-level `md.Node` instances.
  List<md.Node> tokenize(String text) {
    return _document.parse(text);
  }

  /// Whether the given widget [name] is registered. Used by the builder to
  /// decide whether to emit the W003 diagnostic.
  bool isWidgetRegistered(String name) => _registry.has(name);
}
