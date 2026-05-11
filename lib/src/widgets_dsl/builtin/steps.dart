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
}
