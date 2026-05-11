/// Video embed widget.
library;

import '../base.dart';

class VideoWidget extends BaseWidget {
  @override
  String get name => 'video';

  @override
  Map<String, WidgetParam> get params => {
        'src': WidgetParam(required: true, description: 'Video URL.'),
        'poster': WidgetParam(description: 'Poster image URL.'),
        'controls': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: true,
          description: 'Show playback controls.',
        ),
        'autoplay': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: false,
          description: 'Autoplay on load.',
        ),
        'loop': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: false,
          description: 'Loop playback.',
        ),
        'muted': WidgetParam(
          type: WidgetParamType.bool_,
          defaultValue: false,
          description: 'Start muted.',
        ),
        'width': WidgetParam(description: 'CSS width (e.g. 100%, 640px).'),
        'height': WidgetParam(description: 'CSS height.'),
        'caption': WidgetParam(description: 'Caption text shown below.'),
      };

  @override
  String toMarkdown(
    Map<String, dynamic> node,
    String Function(List<Map<String, dynamic>>) renderChildren,
  ) {
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    final tokens = <String>['src="${props['src'] ?? ''}"'];

    for (final key in const ['poster', 'width', 'height', 'caption']) {
      final v = props[key];
      if (v != null && '$v'.isNotEmpty) tokens.add('$key="$v"');
    }
    for (final key in const ['controls', 'autoplay', 'loop', 'muted']) {
      final v = props[key];
      if (v == true) {
        tokens.add(key);
      } else if (v == false && props.containsKey(key)) {
        tokens.add('$key=false');
      }
    }

    return ':::video ${tokens.join(' ')}\n:::';
  }
}
