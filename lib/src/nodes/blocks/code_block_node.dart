import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../ast/node_types.dart';
import '../../core/block_renderer.dart';
import '../../core/render_context.dart';
import '../../theme/markast_theme.dart';

/// Renders a fenced code block with optional syntax highlighting, a header
/// bar (language badge + filename), and a copy button.
///
/// Syntax highlighting requires [MarkastTheme.highlightTheme] to be set.
/// The copy action calls [RenderContext.onCodeCopy] if provided, otherwise
/// falls back to [Clipboard.setData].
class CodeBlockNodeRenderer extends BlockRenderer {
  const CodeBlockNodeRenderer();

  @override
  String get type => NodeType.codeBlock;

  @override
  Widget build(RenderContext ctx, Map<String, dynamic> node) {
    final value    = (node['value']    as String?) ?? '';
    final language = (node['language'] as String?) ?? '';
    final filename =  node['filename'] as String?;
    final theme    = ctx.theme;
    final hasHeader = language.isNotEmpty || filename != null;

    return Container(
      decoration: theme.codeBlockDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader)
            Container(
              padding: theme.codeBlockHeaderPadding,
              decoration: theme.codeBlockHeaderDecoration,
              child: Row(
                children: [
                  if (filename != null)
                    Text(filename, style: theme.codeBlockFilenameTextStyle),
                  if (filename != null && language.isNotEmpty)
                    const SizedBox(width: 8),
                  if (language.isNotEmpty)
                    Container(
                      padding: theme.codeBlockLanguageBadgePadding,
                      decoration: theme.codeBlockLanguageBadgeDecoration,
                      child: Text(
                        language,
                        style: theme.codeBlockLanguageTextStyle,
                      ),
                    ),
                  const Spacer(),
                  if (theme.codeBlockShowCopyButton)
                    IconButton(
                      iconSize: theme.codeBlockCopyIconSize,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy',
                      icon: Icon(
                        Icons.copy,
                        color: theme.codeBlockCopyIconColor,
                      ),
                      onPressed: () => _copy(ctx, value),
                    ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: theme.codeBlockPadding,
            child: _buildCode(theme, value, language),
          ),
        ],
      ),
    );
  }

  void _copy(RenderContext ctx, String code) {
    if (ctx.onCodeCopy != null) {
      ctx.onCodeCopy!(code);
    } else {
      Clipboard.setData(ClipboardData(text: code));
    }
  }

  Widget _buildCode(MarkastTheme theme, String value, String language) {
    if (language.isNotEmpty) {
      final ht = theme.highlightTheme;
      if (ht != null) {
        final span = ht.highlight(value, language, theme.codeBlockTextStyle);
        if (span != null) return Text.rich(span);
      }
    }
    return Text(value, style: theme.codeBlockTextStyle);
  }
}
