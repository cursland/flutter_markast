/// Badge widget — a compact, inline-feeling pill with a label and color.
library;

import '../base.dart';

class BadgeWidget extends BaseWidget {
  @override
  String get name => 'badge';

  @override
  Map<String, WidgetParam> get params => {
        'label': WidgetParam(required: true, description: 'Badge text.'),
        'color': WidgetParam(
          defaultValue: 'gray',
          choices: const [
            'gray',
            'red',
            'green',
            'blue',
            'yellow',
            'purple',
          ],
          description: 'Accent color.',
        ),
      };
}
