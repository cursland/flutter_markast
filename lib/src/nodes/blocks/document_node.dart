import 'package:flutter/material.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';

/// The document renderer produces content with **natural height** and no
/// internal scroll — like a GitHub README: the page grows vertically and the
/// embedding screen decides whether to scroll the whole viewport.
///
/// Wrap `markast.buildDocument(...)` in a [SingleChildScrollView] (or any
/// other scroll widget) at the call site to enable scrolling.
class DocumentNodeRenderer extends BlockRenderer {
  const DocumentNodeRenderer();

  @override
  String get type => NodeType.document;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final children = ctx.markast.buildBlocks(
      ctx,
      node['children'] as List<dynamic>?,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final padding = ctx.theme.paddingFor(width);
        final clamp = width >
            ctx.theme.maxContentWidth + padding.horizontal;

        Widget body = Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < children.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        i == children.length - 1 ? 0 : ctx.theme.blockSpacing,
                  ),
                  child: children[i],
                ),
            ],
          ),
        );

        if (clamp) {
          body = Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ctx.theme.maxContentWidth + padding.horizontal,
              ),
              child: body,
            ),
          );
        }
        return body;
      },
    );
  }
}
