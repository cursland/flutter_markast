// Roundtrip smoke test: parse(md).toMarkdown() should re-parse into an AST
// that's structurally equivalent to the original.
//
// The serialiser normalises whitespace, list markers, setext→atx, etc. — so
// byte-equal MD is NOT the goal. The goal is: AST → MD → AST converges.
//
// Run with: dart run test/roundtrip_test.dart
//
// ignore_for_file: avoid_print

import 'dart:io';

import 'package:markast/src/parser_api.dart';

void main() {
  final samples = <String>[
    // Headings + inline
    '# Heading 1\n\n## Heading 2\n\nA paragraph with **bold**, *italic*, '
        '***both***, `code`, ~~strike~~ and [a link](https://x.dev).',

    // Lists, ordered + tasklist
    '- Plain item\n- Another item with **bold**\n\n'
        '1. First\n2. Second\n3. Third\n\n'
        '- [ ] Unchecked\n- [x] Checked',

    // Fenced code with language and filename
    '```dart [main.dart]\nvoid main() => print(\'hi\');\n```',

    // Table with alignment
    '| Col A | Col B | Col C |\n'
        '|:------|:-----:|------:|\n'
        '| a     | b     | c     |\n'
        '| d     | e     | f     |',

    // Blockquote with nested content
    '> A quote\n>\n> With a second paragraph.',

    // Divider + image
    '---\n\n![alt](https://example.com/img.png)',

    // Widget (admonition + card)
    ':::tip title="Pro tip"\nBody **content**.\n:::',

    // Footnote definition + reference
    'Reference[^a] inline.\n\n[^a]: The definition.',
  ];

  var ok = 0;
  var fail = 0;

  for (final src in samples) {
    final once = parse(src).toMap();
    final md = parse(src).toMarkdown();
    final twice = parse(md).toMap();
    final diff = _structuralDiff(once, twice, r'$');

    if (diff.isEmpty) {
      ok += 1;
      print('  ok   ${_summary(src)}');
    } else {
      fail += 1;
      print('  FAIL ${_summary(src)}');
      for (final d in diff.take(5)) {
        print('       $d');
      }
      if (diff.length > 5) print('       … ${diff.length - 5} more');
      print('       md=${_summary(md)}');
    }
  }

  print('');
  print('roundtrip: $ok ok, $fail fail');
  if (fail > 0) exit(1);
}

/// Compare two AST values structurally. We ignore warning differences and
/// `id` fields (which the slugify transform adds non-deterministically when
/// the same content appears more than once across runs of the same input).
List<String> _structuralDiff(Object? a, Object? b, String path) {
  final out = <String>[];
  if (a is Map && b is Map) {
    final keys = <Object?>{...a.keys, ...b.keys}..removeAll({'warnings', 'id'});
    for (final k in keys) {
      out.addAll(_structuralDiff(a[k], b[k], '$path.$k'));
    }
  } else if (a is List && b is List) {
    if (a.length != b.length) {
      out.add('$path: list ${a.length} vs ${b.length}');
    }
    final n = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < n; i++) {
      out.addAll(_structuralDiff(a[i], b[i], '$path[$i]'));
    }
  } else if (a != b) {
    out.add('$path: ${_short(a)} vs ${_short(b)}');
  }
  return out;
}

String _short(Object? v) {
  final s = v.toString();
  return s.length > 60 ? '${s.substring(0, 60)}…' : s;
}

String _summary(String s) {
  final flat = s.replaceAll('\n', '⏎');
  return flat.length > 60 ? '${flat.substring(0, 60)}…' : flat;
}
