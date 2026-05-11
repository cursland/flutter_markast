/// `SlugifyHeadings` — give every heading a stable, kebab-case `id` derived
/// from its plain-text content. Duplicate slugs within a single document are
/// disambiguated with a numeric suffix (`-2`, `-3`...).
///
/// Mirrors `markast.transforms.slugify`.
library;

import '../ast/node_types.dart';
import '../ast/utils.dart';
import '../ast/walker.dart';
import '../config.dart';
import 'transform.dart';

class SlugifyHeadings extends Transform {
  const SlugifyHeadings();

  @override
  String get name => 'slugify';

  @override
  Map<String, dynamic> apply(Map<String, dynamic> doc, ParserConfig config) {
    final seen = <String>{};
    for (final node in walk(doc)) {
      if (node['type'] != NodeType.heading) continue;
      final base = slugify(extractText(node));
      final root = base.isEmpty ? 'section' : base;
      var slug = root;
      var i = 2;
      while (seen.contains(slug)) {
        slug = '$root-$i';
        i++;
      }
      seen.add(slug);
      node['id'] = slug;
    }
    return doc;
  }

  /// Convert arbitrary text into a kebab-case slug. Mirrors the Python
  /// `slugify` step by step (NFKD-normalise, strip diacritics, drop
  /// punctuation, collapse whitespace/underscores).
  static String slugify(String text) {
    var s = text.trim().toLowerCase();
    s = _stripDiacritics(s);
    s = s.replaceAll(RegExp(r'[^\w\s-]'), '');
    s = s.replaceAll(RegExp(r'[\s_]+'), '-');
    s = s.replaceAll(RegExp(r'^-+|-+$'), '');
    return s;
  }
}

/// Strip combining marks (diacritics) from a string. Dart's standard library
/// doesn't ship a full NFKD normaliser, so we use a hand-coded mapping for
/// the Latin-script characters that the markast slugifier needs to handle
/// (the same set you'd get from `unicodedata.normalize('NFKD', s)` + strip
/// combining chars on the Python side). Anything outside the table is left
/// untouched.
String _stripDiacritics(String s) {
  const map = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
    'ç': 'c', 'č': 'c', 'ć': 'c',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i',
    'ñ': 'n', 'ń': 'n',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ø': 'o', 'ō': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ů': 'u',
    'ý': 'y', 'ÿ': 'y',
    'ž': 'z', 'ź': 'z', 'ż': 'z',
    'š': 's', 'ś': 's', 'ß': 'ss',
    'ł': 'l',
    'ř': 'r',
    'ť': 't',
    'ď': 'd',
  };
  final buf = StringBuffer();
  for (final ch in s.split('')) {
    buf.write(map[ch] ?? ch);
  }
  return buf.toString();
}
