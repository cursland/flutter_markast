/// markast — Flutter renderer for the markast AST.
///
/// Consumes the JSON produced by the markast Python parser and renders it as
/// native Flutter widgets. Fully themeable, extensible via custom renderers,
/// and designed to work in isolation from the parser.
///
/// ```dart
/// final markast = Markast();
/// final widget = markast.buildDocument(context, jsonAst);
/// ```
library;
