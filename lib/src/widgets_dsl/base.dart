/// [BaseWidget] and [WidgetParam] — the parser-side widget DSL.
///
/// A *widget* here is a class describing how a `:::name` container in
/// markdown should be parsed (which props are accepted, which slots exist,
/// what types those props coerce to). Visual rendering is handled by the
/// Flutter `lib/src/widgets/` UI renderers — these two concerns are kept
/// independent on purpose, mirroring the Python split between parser-side
/// `BaseWidget` and the rendering layer.
library;

import 'dart:convert' show jsonDecode;

import '../rules/codes.dart';
import '../rules/rule.dart';

/// Validator callback. Receives the casted value and returns `null` on
/// success or an error message string on failure.
typedef WidgetParamValidator = String? Function(Object? value);

/// Recognised primitive types a [WidgetParam] can coerce to. Mirrors the
/// Python `WidgetParam.type_` field, which accepts native Python `type`
/// objects. In Dart we use string discriminators to keep the surface flat.
class WidgetParamType {
  WidgetParamType._();
  static const String str = 'str';
  static const String int_ = 'int';
  static const String float = 'float';
  static const String bool_ = 'bool';
  static const String list = 'list';
  static const String dict = 'dict';
  // Enum support is handled via [WidgetParam.choices].
}

/// A typed parameter descriptor for widget props.
class WidgetParam {
  WidgetParam({
    this.type = WidgetParamType.str,
    this.defaultValue,
    this.required = false,
    this.description = '',
    this.choices,
    this.validator,
  });

  /// Logical type discriminator — one of [WidgetParamType] string constants.
  final String type;

  /// Default value when the prop is omitted in markdown. `null` means "no
  /// default" (still recorded as `null` in the produced AST so clients can
  /// distinguish "absent" from "present").
  final Object? defaultValue;

  /// If true, a missing prop raises a W005 diagnostic.
  final bool required;

  /// Free-form description used in [BaseWidget.schema] and IDE tools.
  final String description;

  /// Optional discrete set of acceptable values. Anything else raises W004.
  final List<Object?>? choices;

  /// Custom validator. See [WidgetParamValidator].
  final WidgetParamValidator? validator;

  /// Coerce a raw string (as it appears in markdown) into the param's
  /// declared type. Throws [FormatException] on malformed input — the caller
  /// converts that into a W004 diagnostic.
  Object? cast(String raw) {
    switch (type) {
      case WidgetParamType.bool_:
        return _parseBool(raw);
      case WidgetParamType.int_:
        return int.parse(raw);
      case WidgetParamType.float:
        return double.parse(raw);
      case WidgetParamType.list:
        final stripped = raw.trim();
        if (stripped.startsWith('[') && stripped.endsWith(']')) {
          return jsonDecode(stripped);
        }
        return [
          for (final v in raw.split(',')) v.trim(),
        ]..removeWhere((v) => v.isEmpty);
      case WidgetParamType.dict:
        return jsonDecode(raw);
      case WidgetParamType.str:
      default:
        return raw;
    }
  }

  /// Schema dict suitable for documentation tools.
  Map<String, dynamic> toSchema() {
    final schema = <String, dynamic>{
      'type': type,
      'required': required,
    };
    if (defaultValue != null) schema['default'] = defaultValue;
    if (description.isNotEmpty) schema['description'] = description;
    if (choices != null && choices!.isNotEmpty) schema['choices'] = choices;
    return schema;
  }
}

bool _parseBool(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'true':
    case '1':
    case 'yes':
    case 'on':
      return true;
    case 'false':
    case '0':
    case 'no':
    case 'off':
      return false;
    default:
      throw FormatException("cannot parse '$raw' as bool");
  }
}

/// Result of validating a widget's raw props against its schema.
class WidgetPropsValidation {
  WidgetPropsValidation(this.validated, this.diagnostics);
  final Map<String, dynamic> validated;
  final List<Diagnostic> diagnostics;
}

/// Subclass to define a widget. The parser builder looks up registered
/// widgets by [name] when it encounters a `:::name` container.
abstract class BaseWidget {
  /// Widget identifier — used in `:::name`.
  String get name;

  /// Parameter schema. Key = prop name, value = [WidgetParam].
  Map<String, WidgetParam> get params => const {};

  /// Extra slot names beyond `default`. Slot dividers in markdown are bare
  /// `# slot-name` h1 headings at the root level of the widget body.
  List<String> get slots => const [];

  /// When false (default), unknown prop names emit W004; when true they pass
  /// through.
  bool get allowUnknownProps => false;

  /// Cast raw string props into typed values and report problems.
  WidgetPropsValidation validateProps(Map<String, String> rawProps) {
    final validated = <String, dynamic>{};
    final diagnostics = <Diagnostic>[];

    // 1. Apply defaults.
    for (final entry in params.entries) {
      if (entry.value.defaultValue != null) {
        validated[entry.key] = entry.value.defaultValue;
      }
    }

    // 2. Validate provided values.
    for (final entry in rawProps.entries) {
      final key = entry.key;
      final rawVal = entry.value;
      final param = params[key];

      if (param == null) {
        if (!allowUnknownProps) {
          diagnostics.add(Diagnostic(
            code: wInvalidProp,
            message: "Unknown prop '$key' on widget '$name'.",
            context: 'widget=$name',
          ));
        }
        validated[key] = rawVal;
        continue;
      }

      Object? value;
      try {
        value = param.cast(rawVal);
      } on Exception catch (exc) {
        diagnostics.add(Diagnostic(
          code: wInvalidProp,
          message: "Prop '$key' on widget '$name' could not be parsed "
              "as ${param.type} ($exc); raw value kept.",
          context: 'widget=$name, raw=${_repr(rawVal)}',
        ));
        validated[key] = rawVal;
        continue;
      }

      if (param.choices != null && !param.choices!.contains(value)) {
        diagnostics.add(Diagnostic(
          code: wInvalidProp,
          message: "Prop '$key'=${_repr(value)} is not in allowed choices "
              "${param.choices} for widget '$name'.",
          context: 'widget=$name',
        ));
      }

      if (param.validator != null) {
        final err = param.validator!(value);
        if (err != null) {
          diagnostics.add(Diagnostic(
            code: wInvalidProp,
            message: "Prop '$key' failed validation: $err",
            context: 'widget=$name',
          ));
        }
      }

      validated[key] = value;
    }

    // 3. Required-prop check.
    for (final entry in params.entries) {
      if (entry.value.required && !rawProps.containsKey(entry.key)) {
        diagnostics.add(Diagnostic(
          code: wMissingProp,
          message:
              "Required prop '${entry.key}' missing on widget '$name'.",
          context: 'widget=$name',
        ));
      }
    }

    return WidgetPropsValidation(validated, diagnostics);
  }

  /// Cross-prop semantic checks. Default is no-op; override for richer
  /// validation that needs to see multiple props together.
  List<Diagnostic> validate(
    Map<String, dynamic> props,
    Map<String, List<Map<String, dynamic>>> slots,
  ) =>
      const [];

  /// Roundtrip back to Markdown. The default produces the canonical form:
  ///
  ///     :::name k1="v1" k2=v2
  ///
  ///     <default slot rendered>
  ///
  ///     # slot-name
  ///     <slot rendered>
  ///
  ///     :::
  ///
  /// Override only when the canonical syntax differs (see e.g. `BadgeWidget`,
  /// `VideoWidget`, `CodeGroupWidget`).
  String toMarkdown(
    Map<String, dynamic> node,
    String Function(List<Map<String, dynamic>>) renderChildren,
  ) {
    final props = (node['props'] as Map<String, dynamic>?) ?? const {};
    final slotsData = (node['slots'] as Map<String, dynamic>?) ?? const {};

    final propStr = _formatPropsForMarkdown(props);
    final header = ':::$name${propStr.isEmpty ? '' : ' $propStr'}';
    final parts = <String>[header, ''];

    final defaultSlot = (slotsData['default'] as List?)
            ?.cast<Map<String, dynamic>>() ??
        const <Map<String, dynamic>>[];
    if (defaultSlot.isNotEmpty) {
      parts.addAll([renderChildren(defaultSlot), '']);
    }

    for (final slotName in slots) {
      final slotChildren =
          (slotsData[slotName] as List?)?.cast<Map<String, dynamic>>();
      if (slotChildren != null && slotChildren.isNotEmpty) {
        parts.addAll(['# $slotName', '', renderChildren(slotChildren), '']);
      }
    }

    parts.add(':::');
    return parts.join('\n');
  }

  /// Describe this widget for documentation tools.
  Map<String, dynamic> schema() => {
        'name': name,
        'params': {for (final e in params.entries) e.key: e.value.toSchema()},
        'slots': ['default', ...slots],
      };
}

/// Format a typed props map back into `key="val"` markdown syntax. Local copy
/// to keep `BaseWidget` independent of the `MarkdownRenderer` import path
/// (subclasses live in the same package but the renderer doesn't).
String _formatPropsForMarkdown(Map<String, dynamic> props) {
  final tokens = <String>[];
  for (final entry in props.entries) {
    final v = entry.value;
    if (v == null) continue;
    if (v == true) {
      tokens.add(entry.key);
      continue;
    }
    if (v == false) {
      tokens.add('${entry.key}=false');
      continue;
    }
    final s = v.toString();
    final needsQuote = s.contains(RegExp(r'\s')) ||
        s.contains('"') ||
        s.contains("'") ||
        s.contains('=');
    tokens.add(needsQuote ? '${entry.key}="$s"' : '${entry.key}=$s');
  }
  return tokens.join(' ');
}

String _repr(Object? v) {
  if (v == null) return 'None';
  if (v is bool) return v ? 'True' : 'False';
  if (v is num) return v.toString();
  return "'${v.toString().replaceAll(r"\", r"\\").replaceAll("'", r"\'")}'";
}
