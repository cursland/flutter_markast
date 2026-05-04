import 'package:flutter/widgets.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';
import '../../widgets/markast_code_block.dart';

/// Renders a fenced code block from a markast AST node.
///
/// Delegates the visual layout and highlighting to [MarkastCodeBlock] — see
/// that widget for the rendering contract. This renderer only adapts the
/// AST node shape (`{value, language, filename}`) to the widget's API and
/// forwards the [RenderContext.onCodeCopy] callback.
class CodeBlockNodeRenderer extends BlockRenderer {
  const CodeBlockNodeRenderer();

  @override
  String get type => NodeType.codeBlock;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    return MarkastCodeBlock(
      code:     (node['value']    as String?) ?? '',
      language: (node['language'] as String?) ?? '',
      filename:  node['filename'] as String?,
      theme:    ctx.theme,
      onCopy:   ctx.onCodeCopy,
    );
  }
}
