/// Admonition widgets: tip, note, warning, info, caution, danger.
///
/// Six flavours share an identical contract — only their [name] and
/// default labelling differ. Mirrors `markast.widgets.builtin.admonition`.
library;

import '../base.dart';

class Admonition extends BaseWidget {
  @override
  String get name => '';

  String get defaultIcon => '';
  String get defaultTitle => '';

  @override
  Map<String, WidgetParam> get params => {
        'title': WidgetParam(
          description: 'Optional title shown in the header.',
        ),
        'icon': WidgetParam(
          description: 'Icon name (consumer-defined).',
        ),
      };
}

class TipWidget extends Admonition {
  @override
  String get name => 'tip';
  @override
  String get defaultIcon => 'lightbulb';
  @override
  String get defaultTitle => 'Tip';
}

class NoteWidget extends Admonition {
  @override
  String get name => 'note';
  @override
  String get defaultIcon => 'note';
  @override
  String get defaultTitle => 'Note';
}

class InfoWidget extends Admonition {
  @override
  String get name => 'info';
  @override
  String get defaultIcon => 'info';
  @override
  String get defaultTitle => 'Info';
}

class WarningWidget extends Admonition {
  @override
  String get name => 'warning';
  @override
  String get defaultIcon => 'warning';
  @override
  String get defaultTitle => 'Warning';
}

class CautionWidget extends Admonition {
  @override
  String get name => 'caution';
  @override
  String get defaultIcon => 'caution';
  @override
  String get defaultTitle => 'Caution';
}

class DangerWidget extends Admonition {
  @override
  String get name => 'danger';
  @override
  String get defaultIcon => 'danger';
  @override
  String get defaultTitle => 'Danger';
}
