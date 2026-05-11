/// `ParserConfig` — every option that influences how markast parses input.
///
/// Mirrors `markast.config.ParserConfig` on the Python side. Construct one
/// explicitly when you need non-default behaviour, or just pass keyword args
/// to [Parser] which builds one for you.
library;

class ParserConfig {
  const ParserConfig({
    this.features = const [
      'tables',
      'strikethrough',
      'tasklists',
      'autolinks',
      'footnotes',
    ],
    this.diagnoseHtmlBlocks = true,
    this.maxWidgetDepth = 16,
    this.verboseRenderer = false,
    this.jsonIndent = 2,
  });

  /// Markdown features that are active. Currently informational on the Dart
  /// side because `package:markdown`'s [ExtensionSet] is already configured
  /// statically by the tokenizer; the field is kept for API parity with the
  /// Python parser and so future evolutions can branch on it.
  final List<String> features;

  /// When true, emit a W007 diagnostic for any raw HTML block.
  final bool diagnoseHtmlBlocks;

  /// Maximum nesting depth for widget bodies before W009 fires. 0 disables.
  final int maxWidgetDepth;

  /// Reserved for future renderer hooks (Python parity).
  final bool verboseRenderer;

  /// Default indent used by `Document.toJson()`.
  final int jsonIndent;

  ParserConfig evolve({
    List<String>? features,
    bool? diagnoseHtmlBlocks,
    int? maxWidgetDepth,
    bool? verboseRenderer,
    int? jsonIndent,
  }) =>
      ParserConfig(
        features: features ?? this.features,
        diagnoseHtmlBlocks: diagnoseHtmlBlocks ?? this.diagnoseHtmlBlocks,
        maxWidgetDepth: maxWidgetDepth ?? this.maxWidgetDepth,
        verboseRenderer: verboseRenderer ?? this.verboseRenderer,
        jsonIndent: jsonIndent ?? this.jsonIndent,
      );
}

const ParserConfig defaultConfig = ParserConfig();
