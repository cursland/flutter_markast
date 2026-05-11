/// Map of built-in transform names to their factories. Mirrors
/// `BUILTIN_TRANSFORMS` in `markast.transforms.__init__`.
library;

import 'linkify.dart';
import 'normalize.dart';
import 'slugify.dart';
import 'toc.dart';
import 'transform.dart';
import 'typography.dart';

final Map<String, Transform Function()> builtinTransforms = {
  'normalize': () => const NormalizeText(),
  'slugify': () => const SlugifyHeadings(),
  'toc': () => const BuildTOC(),
  'linkify': () => const Linkify(),
  'smarttypography': () => const SmartTypography(),
};
