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
}
