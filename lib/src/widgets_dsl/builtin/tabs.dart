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
}
