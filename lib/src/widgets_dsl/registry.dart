/// [WidgetRegistry] — a per-parser registry of widget classes.
///
/// Registries are NOT singletons. Each [Parser] owns one. A separate
/// [defaultRegistry] is provided so the top-level `parse()` helper has
/// somewhere to look up built-in widgets without forcing every caller to
/// construct a parser.
library;

import 'base.dart';
import 'builtin/admonition.dart';
import 'builtin/badge.dart';
import 'builtin/card.dart';
import 'builtin/code_collapse.dart';
import 'builtin/code_group.dart';
import 'builtin/steps.dart';
import 'builtin/tabs.dart';
import 'builtin/video.dart';

/// Thrown when registering a widget that is malformed (missing name,
/// duplicate registration, etc.). Mirrors Python `WidgetRegistrationError`.
class WidgetRegistrationError implements Exception {
  WidgetRegistrationError(this.message);
  final String message;
  @override
  String toString() => 'WidgetRegistrationError: $message';
}

/// Maps widget names → widget factories.
class WidgetRegistry {
  WidgetRegistry([List<BaseWidget Function()>? widgets]) {
    if (widgets != null) {
      for (final w in widgets) {
        register(w);
      }
    }
  }

  final Map<String, BaseWidget Function()> _factories = {};

  /// Register a widget factory. The factory should return a fresh
  /// [BaseWidget] every call — this matches the Python idiom of
  /// `widget_cls()` and keeps per-parse state isolated.
  BaseWidget Function() register(BaseWidget Function() factory) {
    final probe = factory();
    if (probe.name.isEmpty) {
      throw WidgetRegistrationError(
        'Widget ${probe.runtimeType} must define a non-empty `name`.',
      );
    }
    _factories[probe.name] = factory;
    return factory;
  }

  void registerMany(List<BaseWidget Function()> factories) {
    for (final f in factories) {
      register(f);
    }
  }

  void unregister(String name) => _factories.remove(name);

  /// Look up a widget factory by name; returns `null` when missing. Call the
  /// returned factory to obtain a fresh instance.
  BaseWidget Function()? get(String name) => _factories[name];

  bool has(String name) => _factories.containsKey(name);

  List<String> names() => _factories.keys.toList();

  /// Return a new registry holding the same widget factories.
  WidgetRegistry clone() {
    final r = WidgetRegistry();
    r._factories.addAll(_factories);
    return r;
  }
}

/// A registry pre-populated with built-in widgets. Used by the top-level
/// `parse()` helper.
final WidgetRegistry defaultRegistry = _buildDefaultRegistry();

WidgetRegistry _buildDefaultRegistry() {
  final r = WidgetRegistry();
  r.registerMany([
    () => TipWidget(),
    () => NoteWidget(),
    () => WarningWidget(),
    () => InfoWidget(),
    () => CautionWidget(),
    () => DangerWidget(),
    () => CardWidget(),
    () => VideoWidget(),
    () => CodeGroupWidget(),
    () => CodeCollapseWidget(),
    () => TabsWidget(),
    () => StepsWidget(),
    () => BadgeWidget(),
  ]);
  return r;
}
