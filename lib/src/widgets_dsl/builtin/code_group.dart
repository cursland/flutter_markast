/// Code-group widget — tabs over a sequence of fenced code blocks.
library;

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
}
