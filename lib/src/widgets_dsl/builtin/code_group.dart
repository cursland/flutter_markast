/// Code-group widget — tabs over a sequence of fenced code blocks.
library;

import '../../ast/node_types.dart';
import '../base.dart';

class CodeGroupWidget extends BaseWidget {
  @override
  String get name => 'code-group';

  @override
  Map<String, WidgetParam> get params => {
        'default_tab': WidgetParam(
          description: 'Filename of tab to show first.',
        ),
      };

  @override
  String toMarkdown(
    Map<String, dynamic> node,
    String Function(List<Map<String, dynamic>>) renderChildren,
  ) {
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    var header = ':::code-group';
    final defaultTab = props['default_tab'];
    if (defaultTab != null && '$defaultTab'.isNotEmpty) {
      header += ' default_tab="$defaultTab"';
    }

    final parts = <String>[header, ''];
    final slots = (node['slots'] as Map<String, dynamic>?) ?? const {};
    final defaultSlot = (slots['default'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    for (final block in defaultSlot) {
      if (block['type'] != NodeType.codeBlock) continue;
      var info = (block['language'] as String?) ?? '';
      final filename = block['filename'] as String?;
      if (filename != null && filename.isNotEmpty) info += ' [$filename]';
      final highlightLines = (block['highlight_lines'] as List?)?.cast<int>();
      if (highlightLines != null && highlightLines.isNotEmpty) {
        info += '{${_formatHighlight(highlightLines)}}';
      }
      parts.addAll([
        '```$info',
        (block['value'] as String?) ?? '',
        '```',
        '',
      ]);
    }
    parts.add(':::');
    return parts.join('\n');
  }
}

String _formatHighlight(List<int> lines) {
  if (lines.isEmpty) return '';
  final sorted = lines.toSet().toList()..sort();
  final out = <String>[];
  var s = sorted.first;
  var e = sorted.first;
  for (var i = 1; i < sorted.length; i++) {
    final x = sorted[i];
    if (x == e + 1) {
      e = x;
    } else {
      out.add(s == e ? '$s' : '$s-$e');
      s = e = x;
    }
  }
  out.add(s == e ? '$s' : '$s-$e');
  return out.join(',');
}
