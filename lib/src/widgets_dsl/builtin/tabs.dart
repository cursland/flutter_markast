/// Tabs widget — each named slot is a tab.
library;

import '../base.dart';

class TabsWidget extends BaseWidget {
  @override
  String get name => 'tabs';

  /// Any slot name is accepted; we do not restrict.
  @override
  List<String> get slots => const [];

  @override
  bool get allowUnknownProps => true;

  @override
  Map<String, WidgetParam> get params => {
        'default': WidgetParam(
          description: 'Slot name of the tab to open first.',
        ),
        'vertical': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: false,
          description: 'Render tabs vertically (clients may ignore).',
        ),
      };

  @override
  String toMarkdown(
    Map<String, dynamic> node,
    String Function(List<Map<String, dynamic>>) renderChildren,
  ) {
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    final slotsData = (node['slots'] as Map<String, dynamic>?) ?? const {};

    var header = ':::tabs';
    final defaultProp = props['default'];
    if (defaultProp != null && '$defaultProp'.isNotEmpty) {
      header += ' default="$defaultProp"';
    }
    if (props['vertical'] == true) header += ' vertical';

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
