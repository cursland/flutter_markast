import 'dart:async';

import 'package:flutter/widgets.dart';

/// `Image.network` has no built-in timeout. When a host hangs (Cloudflare
/// 524, slow CDN, dropped connection without an RST) the spinner stays
/// forever and `errorBuilder` never fires. This wrapper races the image
/// stream against a [timeout] timer; whichever wins decides the result.
///
/// On success: the image renders normally.
/// On stream error: [errorBuilder] is shown.
/// On timeout: [errorBuilder] is shown.
class TimedNetworkImage extends StatefulWidget {
  const TimedNetworkImage({
    super.key,
    required this.url,
    required this.errorBuilder,
    this.loadingBuilder,
    this.fit,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.timeout = const Duration(seconds: 8),
  });

  final String url;
  final WidgetBuilder errorBuilder;
  final WidgetBuilder? loadingBuilder;
  final BoxFit? fit;
  final Alignment alignment;
  final String? semanticLabel;
  final Duration timeout;

  @override
  State<TimedNetworkImage> createState() => _TimedNetworkImageState();
}

class _TimedNetworkImageState extends State<TimedNetworkImage> {
  late Future<bool> _ok;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _ok = _race();
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  Future<bool> _race() {
    final completer = Completer<bool>();
    _stream = NetworkImage(widget.url).resolve(const ImageConfiguration());
    _listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(true);
      },
      onError: (e, st) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    _stream!.addListener(_listener!);
    return completer.future
        .timeout(widget.timeout, onTimeout: () => false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _ok,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return widget.loadingBuilder?.call(context) ?? const SizedBox();
        }
        if (snap.data != true) return widget.errorBuilder(context);
        return Image.network(
          widget.url,
          fit: widget.fit,
          alignment: widget.alignment,
          semanticLabel: widget.semanticLabel,
          errorBuilder: (ctx, e, s) => widget.errorBuilder(ctx),
        );
      },
    );
  }
}
