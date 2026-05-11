/// Steps widget — numbered procedural sequences, each step a named slot.
library;

import '../base.dart';

class StepsWidget extends BaseWidget {
  @override
  String get name => 'steps';

  @override
  List<String> get slots => const [];

  @override
  bool get allowUnknownProps => true;

  @override
  Map<String, WidgetParam> get params => {
        'start': WidgetParam(
          type: WidgetParamType.int_,
          defaultValue: 1,
          description: 'Number to start counting from.',
        ),
      };

  @override
  String toMarkdown(
    Map<String, dynamic> node,
    String Function(List<Map<String, dynamic>>) renderChildren,
  ) {
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    final slotsData = (node['slots'] as Map<String, dynamic>?) ?? const {};

    var header = ':::steps';
    final start = props['start'];
    if (start is int && start != 1) header += ' start=$start';

    final parts = <String>[header, ''];
    final defaultSlot = (slotsData['default'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (defaultSlot.isNotEmpty) {
      parts.addAll([renderChildren(defaultSlot), '']);
    }

    for (final entry in slotsData.entries) {
      if (entry.key == 'default') continue;
      final slotChildren =
          (entry.value as List?)?.cast<Map<String, dynamic>>() ??
              const <Map<String, dynamic>>[];
      if (slotChildren.isEmpty) continue;
      parts.addAll(['# ${entry.key}', '', renderChildren(slotChildren), '']);
    }

    parts.add(':::');
    return parts.join('\n');
  }
}
