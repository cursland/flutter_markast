import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's PlantUML grammar.
///
/// PlantUML is not in re_highlight's built-in catalog, so this is also a new
/// language registration. Highlights:
///   * `@startuml` / `@enduml` directives painted as `meta`.
///   * Element keywords (`actor`, `class`, `participant`, `note`, …) as
///     `keyword`.
///   * Stereotypes `<<...>>` painted as `type`.
///   * Arrows (`->`, `-->`, `..>`, `<|--`) painted as `keyword`.
///   * Skinparams highlighted.
final markastPlantUmlGrammar = (() {
  const pumlKeywords = <String>[
    // Document / region
    'startuml', 'enduml', 'startmindmap', 'endmindmap', 'startwbs', 'endwbs',
    'startgantt', 'endgantt', 'startsalt', 'endsalt', 'startjson', 'endjson',
    'startyaml', 'endyaml', 'startditaa', 'endditaa', 'startdot', 'enddot',
    'newpage',
    // Diagram elements
    'actor', 'agent', 'artifact', 'boundary', 'card', 'class', 'cloud',
    'component', 'control', 'database', 'entity', 'enum', 'file', 'folder',
    'frame', 'interface', 'node', 'object', 'package', 'participant',
    'queue', 'rectangle', 'stack', 'storage', 'usecase', 'state', 'note',
    // Relationships and modifiers
    'as', 'over', 'of', 'on', 'left', 'right', 'top', 'bottom', 'across',
    'up', 'down', 'extends', 'implements',
    // Control flow
    'if', 'else', 'elseif', 'endif', 'while', 'endwhile', 'repeat',
    'fork', 'again', 'end', 'partition', 'group', 'box',
    'activate', 'deactivate', 'destroy', 'create', 'return', 'autonumber',
    'title', 'header', 'footer', 'caption', 'legend', 'endlegend',
    'skinparam', 'skinparamlocked', 'hide', 'show',
    'alt', 'opt', 'loop', 'par', 'break', 'critical', 'else',
    'ref', 'include', 'theme',
  ];

  const pumlLiterals = <String>['true', 'false'];

  // Stereotype: <<name>>
  final stereotype = Mode(
    scope: MarkastScopes.type,
    begin: r'<<', end: r'>>',
    relevance: 0,
  );

  // Directive starting with @
  final directive = Mode(
    scope: MarkastScopes.meta,
    begin: r'@\w+',
    relevance: 5,
  );

  // Color name / hex
  final color = Mode(
    scope: MarkastScopes.number,
    begin: r'#[A-Fa-f0-9]{3,8}\b',
    relevance: 0,
  );

  // Arrows used in PlantUML
  final arrow = Mode(
    scope: MarkastScopes.keyword,
    begin: r'(<\|?\|?[ox*+]?[-.~]+|[-.~]+[ox*+]?\|?\|?>?|<-+>|\.+|-+)',
    relevance: 0,
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'",
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  return Mode(
    name: 'PlantUML',
    aliases: <String>['plantuml', 'puml', 'uml'],
    caseInsensitive: true,
    keywords: {
      'keyword':  pumlKeywords,
      'literal':  pumlLiterals,
    },
    contains: <Mode>[
      lineComment(r"'"),
      Mode(scope: MarkastScopes.comment, begin: r"/'", end: r"'/"),
      directive,
      stereotype,
      color,
      strings,
      arrow,
      markastNumber,
    ],
  );
})();
