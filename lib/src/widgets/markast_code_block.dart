import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/markast_theme.dart';

/// A standalone, themed code block widget.
///
/// Use this anywhere in your app — outside of markdown rendering — to display
/// syntax-highlighted code with the same visual chrome (header bar, language
/// badge, filename, copy button) used by `markast.buildDocument`.
///
/// ```dart
/// MarkastCodeBlock(
///   code: 'final markast = Markast();',
///   language: 'dart',
///   filename: 'example.dart',
///   theme: Markast().resolveTheme(context),
/// )
/// ```
///
/// If [theme] is null, the widget resolves it from
/// `Theme.of(context).extension<MarkastTheme>()` falling back to
/// `MarkastTheme.fromTheme(Theme.of(context))`. Pass an explicit [theme] to
/// override (e.g. to use a different highlight palette than the rest of your
/// document).
class MarkastCodeBlock extends StatelessWidget {
  const MarkastCodeBlock({
    super.key,
    required this.code,
    this.language = '',
    this.filename,
    this.theme,
    this.onCopy,
    this.showHeader,
    this.showCopyButton,
  });

  /// The source code to render.
  final String code;

  /// Language identifier (e.g. `dart`, `js`, `python`). Empty string disables
  /// highlighting and the language badge.
  final String language;

  /// Optional filename to display in the header bar (e.g. `main.dart`).
  final String? filename;

  /// Theme to use for layout and syntax colours. When null the widget falls
  /// back to `Theme.of(context).extension<MarkastTheme>()`.
  final MarkastTheme? theme;

  /// Override the default copy behaviour. When null, the copy button writes
  /// the code to the system clipboard via [Clipboard.setData].
  final void Function(String code)? onCopy;

  /// Force-show or hide the header bar. When null the header is shown if
  /// either [language] or [filename] is non-empty.
  final bool? showHeader;

  /// Force-show or hide the copy button. When null defaults to
  /// `theme.codeBlockShowCopyButton`.
  final bool? showCopyButton;

  MarkastTheme _resolveTheme(BuildContext context) {
    if (theme != null) return theme!;
    final flutterTheme = Theme.of(context);
    return flutterTheme.extension<MarkastTheme>() ??
        MarkastTheme.fromTheme(flutterTheme);
  }

  void _handleCopy() {
    if (onCopy != null) {
      onCopy!(code);
    } else {
      Clipboard.setData(ClipboardData(text: code));
    }
  }

  Widget _buildCodeText(MarkastTheme t) {
    if (language.isNotEmpty) {
      final ht = t.highlightTheme;
      if (ht != null) {
        final span = ht.highlight(code, language, t.codeBlockTextStyle);
        if (span != null) return Text.rich(span);
      }
    }
    return Text(code, style: t.codeBlockTextStyle);
  }

  @override
  Widget build(BuildContext context) {
    final t = _resolveTheme(context);
    final hasHeader = showHeader ?? (language.isNotEmpty || filename != null);
    final showCopy = showCopyButton ?? t.codeBlockShowCopyButton;

    return Container(
      decoration: t.codeBlockDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasHeader)
            Container(
              padding: t.codeBlockHeaderPadding,
              decoration: t.codeBlockHeaderDecoration,
              child: Row(
                children: [
                  if (filename != null)
                    Text(filename!, style: t.codeBlockFilenameTextStyle),
                  if (filename != null && language.isNotEmpty)
                    const SizedBox(width: 8),
                  if (language.isNotEmpty)
                    Container(
                      padding: t.codeBlockLanguageBadgePadding,
                      decoration: t.codeBlockLanguageBadgeDecoration,
                      child: Text(
                        language,
                        style: t.codeBlockLanguageTextStyle,
                      ),
                    ),
                  const Spacer(),
                  if (showCopy)
                    IconButton(
                      iconSize: t.codeBlockCopyIconSize,
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copy',
                      icon: Icon(
                        Icons.copy,
                        color: t.codeBlockCopyIconColor,
                      ),
                      onPressed: _handleCopy,
                    ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: t.codeBlockPadding,
            child: _buildCodeText(t),
          ),
        ],
      ),
    );
  }
}
