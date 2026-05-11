/// Card widget — a container with optional `header` and `footer` slots.
library;

import '../base.dart';

class CardWidget extends BaseWidget {
  @override
  String get name => 'card';

  @override
  List<String> get slots => const ['header', 'footer'];

  @override
  Map<String, WidgetParam> get params => {
        'title': WidgetParam(
          description: 'Card title shown in the header.',
        ),
        'color': WidgetParam(
          description: 'Accent color hint for clients.',
        ),
        'elevated': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: false,
          description: 'Show a subtle shadow.',
        ),
      };
}
