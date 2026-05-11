/// `Parser` — high-level entry point that bundles a [ParserConfig], a
/// [WidgetRegistry], the rule list and the transform pipeline.
///
/// Mirrors `markast.parser_api.Parser`.
library;

import 'config.dart';
import 'document.dart';
import 'parser/builder.dart';
import 'parser/tokenizer.dart';
import 'rules/builtin.dart';
import 'rules/rule.dart';
import 'transforms/builtin.dart';
import 'transforms/transform.dart';
import 'widgets_dsl/base.dart';
import 'widgets_dsl/registry.dart';

class ConfigurationError implements Exception {
  ConfigurationError(this.message);
  final String message;
  @override
  String toString() => 'ConfigurationError: $message';
}

/// Anything that can be passed in the `rules` argument: an instance or a
/// 0-arg factory that returns one.
typedef RuleFactory = Rule Function();

class Parser {
  Parser({
    ParserConfig? config,
    List<BaseWidget Function()>? widgets,
    WidgetRegistry? registry,
    List<Object>? rules,
    List<Object>? transforms,
  }) : config = config ?? defaultConfig {
    this.registry = registry ?? defaultRegistry.clone();
    if (widgets != null) {
      for (final w in widgets) {
        this.registry.register(w);
      }
    }

    _rules = <Rule>[];
    if (rules == null) {
      _rules.add(BuiltinRules());
    } else {
      for (final r in rules) {
        if (r is Rule) {
          _rules.add(r);
        } else if (r is RuleFactory) {
          _rules.add(r());
        } else {
          throw ConfigurationError('Invalid rule entry: $r');
        }
      }
    }

    _pipeline = TransformPipeline();
    if (transforms != null) {
      for (final t in transforms) {
        _pipeline.append(_resolveTransform(t));
      }
    }
  }

  final ParserConfig config;
  late final WidgetRegistry registry;
  late final List<Rule> _rules;
  late final TransformPipeline _pipeline;

  Tokenizer? _tokenizer;

  Tokenizer _getTokenizer() {
    return _tokenizer ??= Tokenizer(registry);
  }

  /// Parse markdown [text] and return a [Document].
  Document parse(String text) {
    final nodes = _getTokenizer().tokenize(text);
    final builder = ASTBuilder(config, registry, _rules);
    var ast = builder.build(nodes);
    ast = _pipeline.run(ast, config);
    return Document(ast);
  }

  // ── Mutation helpers (return fresh Parser instances) ────────────────────
  Parser withWidgets(List<BaseWidget Function()> widgets) {
    final newRegistry = registry.clone();
    for (final w in widgets) {
      newRegistry.register(w);
    }
    return Parser(
      config: config,
      registry: newRegistry,
      rules: List<Object>.from(_rules),
      transforms: List<Object>.from(_pipeline.transforms),
    );
  }

  Parser withTransforms(List<Object> transforms) {
    final newList = <Object>[
      ..._pipeline.transforms,
      ...transforms,
    ];
    return Parser(
      config: config,
      registry: registry,
      rules: List<Object>.from(_rules),
      transforms: newList,
    );
  }

  Transform _resolveTransform(Object t) {
    if (t is String) {
      final factory = builtinTransforms[t];
      if (factory == null) {
        throw ConfigurationError(
          "Unknown transform '$t'. Known: ${builtinTransforms.keys.toList()..sort()}",
        );
      }
      return factory();
    }
    if (t is Transform) return t;
    if (t is Transform Function()) return t();
    throw ConfigurationError('Invalid transform entry: $t');
  }

  @override
  String toString() =>
      'Parser(config=$config, widgets=${registry.names()}, '
      'rules=[${_rules.map((r) => r.name.isEmpty ? r.runtimeType.toString() : r.name).join(", ")}], '
      'transforms=${_pipeline.names()})';
}

/// Top-level convenience helper — equivalent to `Parser().parse(text)` but
/// reuses a process-wide parser instance so the underlying tokeniser is
/// initialised once. Use [Parser] directly when you need custom config,
/// widgets, or transforms.
Document parse(String text) {
  _defaultParser ??= Parser(registry: defaultRegistry);
  return _defaultParser!.parse(text);
}

Parser? _defaultParser;
