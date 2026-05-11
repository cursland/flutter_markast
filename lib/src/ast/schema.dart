/// JSON-Schema export for the markast AST shape. Mirrors
/// `markast.ast.schema.json_schema` on the Python side so consumers in other
/// languages can validate the same JSON.
library;

import 'node_types.dart';

Map<String, dynamic> jsonSchema() {
  final allTypes = <String>{
    ...NodeType.blockTypes,
    ...NodeType.inlineTypes,
  }.toList()
    ..sort();

  return {
    r'$schema': 'https://json-schema.org/draft/2020-12/schema',
    r'$id': 'urn:cursland:markast:schema:document',
    'title': 'markast Document',
    'type': 'object',
    'required': ['type', 'version', 'warnings', 'children'],
    'properties': {
      'type': {'const': NodeType.document},
      'version': {'type': 'string'},
      'warnings': {
        'type': 'array',
        'items': {r'$ref': '#/\$defs/Warning'},
      },
      'children': {
        'type': 'array',
        'items': {r'$ref': '#/\$defs/Node'},
      },
      'meta': {'type': 'object'},
    },
    r'$defs': {
      'Warning': {
        'type': 'object',
        'required': ['code', 'message', 'context'],
        'properties': {
          'code': {'type': 'string'},
          'message': {'type': 'string'},
          'context': {'type': 'string'},
          'severity': {
            'enum': ['error', 'warning', 'info']
          },
        },
      },
      'Node': {
        'type': 'object',
        'required': ['type'],
        'properties': {
          'type': {'type': 'string', 'enum': allTypes},
        },
        'additionalProperties': true,
      },
    },
  };
}
