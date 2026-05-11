/// Parse a widget header line into a raw props map and a fenced-code info
/// string into language / filename / highlight components.
///
/// Mirrors `markast.parser.props` byte for byte where it matters for the
/// produced JSON.
library;

final RegExp _propRe = RegExp(
  r'''(?<key>[\w][\w-]*)=(?:"(?<dq>[^"]*)"|'(?<sq>[^']*)'|(?<bare>[^\s"']+))''',
);

/// Parse the trailing portion of a widget header (after `:::name`) into a
/// `{prop: rawString}` map.
///
/// Recognises three quoting styles:
///   key="quoted with spaces"  |  key='single-quoted'  |  key=bare
///
/// Anything before the first `key=` (and after the widget name) is captured
/// as the implicit `title` prop unless an explicit `title=` is given.
Map<String, String> parseProps(String info, String widgetName) {
  var s = info.trim();
  if (s.startsWith(widgetName)) {
    s = s.substring(widgetName.length).trim();
  }

  final props = <String, String>{};
  for (final m in _propRe.allMatches(s)) {
    final key = m.namedGroup('key')!;
    final val = m.namedGroup('dq') ??
        m.namedGroup('sq') ??
        m.namedGroup('bare') ??
        '';
    props[key] = val;
  }

  final firstMatch = _propRe.firstMatch(s);
  final leading =
      firstMatch == null ? s.trim() : s.substring(0, firstMatch.start).trim();
  if (leading.isNotEmpty && !props.containsKey('title')) {
    props['title'] = leading;
  }

  return props;
}

/// Parse a fenced-code info string into `{language, filename, highlight_lines}`.
///
/// Recognised forms:
///   ts                                  → language only
///   ts [nuxt.config.ts]                 → language + filename
///   ts [nuxt.config.ts]{4-5,7}          → language + filename + highlights
///   {1,3-5}                             → highlights only
Map<String, dynamic> parseFenceInfo(String info) {
  final out = <String, dynamic>{
    'language': '',
    'filename': null,
    'highlight_lines': <int>[],
  };
  final s = info.trim();
  if (s.isEmpty) return out;

  final m = RegExp(
    r'^(?<lang>[^\s\[{]*)'
    r'(?:\s*\[(?<file>[^\]]*)\])?'
    r'(?:\s*\{(?<lines>[^}]*)\})?',
  ).firstMatch(s);

  if (m == null) return out;

  out['language'] = m.namedGroup('lang') ?? '';
  final f = m.namedGroup('file');
  out['filename'] = (f != null && f.isNotEmpty) ? f : null;
  out['highlight_lines'] = parseHighlightLines(m.namedGroup('lines') ?? '');
  return out;
}

/// Parse "1,3-5,7" into `[1, 3, 4, 5, 7]`. Robust against junk.
List<int> parseHighlightLines(String s) {
  final result = <int>[];
  for (final raw in s.split(',')) {
    final part = raw.trim();
    if (part.isEmpty) continue;
    if (part.contains('-')) {
      final idx = part.indexOf('-');
      final a = int.tryParse(part.substring(0, idx).trim());
      final b = int.tryParse(part.substring(idx + 1).trim());
      if (a == null || b == null) continue;
      for (var i = a; i <= b; i++) {
        result.add(i);
      }
    } else {
      final n = int.tryParse(part);
      if (n != null) result.add(n);
    }
  }
  return result;
}
