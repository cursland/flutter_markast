/// Collapsible code block widget — wraps any block content in a foldable region.
library;

import '../base.dart';

class CodeCollapseWidget extends BaseWidget {
  @override
  String get name => 'code-collapse';

  @override
  Map<String, WidgetParam> get params => {
        'summary': WidgetParam(
          defaultValue: 'Show code',
          description: 'Label shown on the toggle button.',
        ),
        'open': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: false,
          description: 'Whether the region starts expanded.',
        ),
      };

  @override
  String toMarkdown(
    Map<String, dynamic> node,
    String Function(List<Map<String, dynamic>>) renderChildren,
  ) {
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    var header =
        ':::code-collapse summary="${props['summary'] ?? 'Show code'}"';
    if (props['open'] == true) header += ' open';

    final parts = <String>[header, ''];
    final slots = (node['slots'] as Map<String, dynamic>?) ?? const {};
    final defaultSlot = (slots['default'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (defaultSlot.isNotEmpty) {
      parts.addAll([renderChildren(defaultSlot), '']);
    }
    parts.add(':::');
    return parts.join('\n');
  }
}
