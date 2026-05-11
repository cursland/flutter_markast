// Stand-alone smoke test: parse the same input.md the Python parser is
// known to consume in D:\AST\testing\, write the produced JSON next to it
// as dart_output.json, and print a short diff summary against output.json.
//
// Usage: dart run test/parity_smoke.dart
//
// Intentionally not a flutter_test — we want a quick comparison loop that
// produces an artifact on disk for easy eyeballing during development.
// stdout is the intended output channel, so the avoid_print lint is OFF.
// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// We import the parser/document modules directly so this CLI smoke test
// stays Flutter-free; the umbrella `markast.dart` also pulls in the
// renderer-side `Markast` widget which depends on dart:ui.
import 'package:markast/src/parser_api.dart';

void main() {
  const inputPath = r'D:\AST\testing\input.md';
  const referencePath = r'D:\AST\testing\output.json';
  const outputPath = r'D:\AST\testing\dart_output.json';

  final input = File(inputPath).readAsStringSync();
  final doc = parse(input);
  final dartJson = doc.toJson(indent: 2);
  File(outputPath).writeAsStringSync(dartJson);
  print('Wrote $outputPath (${dartJson.length} bytes)');

  if (!File(referencePath).existsSync()) {
    print('Reference output.json not found — skipping diff.');
    return;
  }
  final ref = File(referencePath).readAsStringSync();
  final refDecoded = jsonDecode(ref);
  final dartDecoded = jsonDecode(dartJson);

  final diff = _diff(refDecoded, dartDecoded, '\$');
  if (diff.isEmpty) {
    print('Parity: IDENTICAL ✓');
  } else {
    print('Parity diff (first 40 entries):');
    for (final d in diff.take(40)) {
      print('  $d');
    }
    print('… total diffs: ${diff.length}');
  }
}

List<String> _diff(Object? a, Object? b, String path) {
  final out = <String>[];
  if (a is Map && b is Map) {
    final keys = <Object?>{...a.keys, ...b.keys};
    for (final k in keys) {
      out.addAll(_diff(a[k], b[k], '$path.$k'));
    }
  } else if (a is List && b is List) {
    if (a.length != b.length) {
      out.add('$path: list length ${a.length} (py) vs ${b.length} (dart)');
    }
    final n = a.length < b.length ? a.length : b.length;
    for (var i = 0; i < n; i++) {
      out.addAll(_diff(a[i], b[i], '$path[$i]'));
    }
  } else if (a != b) {
    out.add('$path: ${_repr(a)} (py) vs ${_repr(b)} (dart)');
  }
  return out;
}

String _repr(Object? v) {
  if (v == null) return 'null';
  if (v is String) {
    final s = v.length > 80 ? '${v.substring(0, 80)}…' : v;
    return jsonEncode(s);
  }
  return jsonEncode(v);
}
