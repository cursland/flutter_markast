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
}
