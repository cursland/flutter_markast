import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced SQL grammar (case-insensitive).
///
/// Improvements:
///   * Comprehensive keyword list covering ANSI SQL + PostgreSQL/MySQL/SQLite
///     extensions.
///   * Built-in functions (`COUNT`, `SUM`, `JSON_EXTRACT`, `COALESCE`, …).
///   * Backtick / double-quote / square-bracket identifiers painted as
///     `attribute` so quoted column names stand out.
///   * Dollar-quoted strings (`$$ ... $$`) for PostgreSQL.
final markastSqlGrammar = (() {
  const sqlKeywords = <String>[
    'SELECT', 'FROM', 'WHERE', 'GROUP', 'ORDER', 'BY', 'HAVING', 'LIMIT',
    'OFFSET', 'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE',
    'CREATE', 'DROP', 'ALTER', 'TABLE', 'INDEX', 'VIEW', 'TRIGGER',
    'PROCEDURE', 'FUNCTION', 'DATABASE', 'SCHEMA', 'TEMP', 'TEMPORARY',
    'IF', 'EXISTS', 'NOT', 'NULL', 'AND', 'OR', 'IN', 'BETWEEN', 'LIKE',
    'ILIKE', 'IS', 'AS', 'ON', 'USING', 'JOIN', 'INNER', 'OUTER', 'LEFT',
    'RIGHT', 'FULL', 'CROSS', 'UNION', 'INTERSECT', 'EXCEPT', 'ALL',
    'DISTINCT', 'CASE', 'WHEN', 'THEN', 'ELSE', 'END', 'WITH', 'RECURSIVE',
    'PRIMARY', 'KEY', 'FOREIGN', 'REFERENCES', 'CONSTRAINT', 'UNIQUE',
    'CHECK', 'DEFAULT', 'AUTO_INCREMENT', 'IDENTITY', 'GENERATED', 'ALWAYS',
    'STORED', 'VIRTUAL', 'CASCADE', 'RESTRICT', 'COMMIT', 'ROLLBACK',
    'TRANSACTION', 'BEGIN', 'SAVEPOINT', 'GRANT', 'REVOKE', 'EXPLAIN',
    'ANALYZE', 'VACUUM', 'RETURNING', 'CONFLICT', 'NOTHING', 'DO', 'UPDATE',
    'WINDOW', 'PARTITION', 'OVER', 'ROW', 'ROWS', 'RANGE', 'PRECEDING',
    'FOLLOWING', 'UNBOUNDED', 'CURRENT', 'FIRST', 'LAST', 'NULLS', 'ASC',
    'DESC',
  ];

  const sqlLiterals = <String>['TRUE', 'FALSE', 'NULL', 'UNKNOWN'];

  const sqlBuiltins = <String>[
    // Types
    'INT', 'INTEGER', 'BIGINT', 'SMALLINT', 'TINYINT', 'DECIMAL', 'NUMERIC',
    'FLOAT', 'DOUBLE', 'REAL', 'BOOLEAN', 'BOOL', 'CHAR', 'VARCHAR', 'TEXT',
    'CHARACTER', 'BLOB', 'BYTEA', 'DATE', 'TIME', 'TIMESTAMP', 'DATETIME',
    'INTERVAL', 'JSON', 'JSONB', 'UUID', 'SERIAL', 'BIGSERIAL', 'ARRAY',
    'ENUM',
    // Aggregates
    'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'STDDEV', 'VARIANCE',
    'ARRAY_AGG', 'STRING_AGG', 'JSON_AGG', 'JSONB_AGG',
    // Common functions
    'COALESCE', 'NULLIF', 'CAST', 'CONVERT', 'EXTRACT', 'NOW', 'CURRENT_DATE',
    'CURRENT_TIME', 'CURRENT_TIMESTAMP', 'CURRENT_USER',
    'CONCAT', 'SUBSTRING', 'TRIM', 'UPPER', 'LOWER', 'LENGTH', 'REPLACE',
    'REGEXP_REPLACE', 'REGEXP_MATCHES', 'JSON_EXTRACT', 'JSONB_BUILD_OBJECT',
    'ROW_NUMBER', 'RANK', 'DENSE_RANK', 'LEAD', 'LAG',
  ];

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'",
           contains: <Mode>[Mode(begin: r"''")]),
      // Postgres E-strings with C escapes
      Mode(scope: MarkastScopes.string, begin: r"E'", end: r"'",
           contains: <Mode>[markastBackslashEscape]),
      // Postgres dollar-quoted: $$ ... $$ or $tag$ ... $tag$
      Mode(scope: MarkastScopes.string, begin: r'\$[A-Za-z_]*\$',
           end: r'\$[A-Za-z_]*\$'),
    ],
  );

  // Quoted identifiers
  final quotedIdent = Mode(
    scope: MarkastScopes.attribute,
    variants: <Mode>[
      Mode(begin: r'"', end: r'"'),
      Mode(begin: r'`', end: r'`'),
      Mode(begin: r'\[', end: r'\]'),
    ],
    relevance: 0,
  );

  return Mode(
    name: 'SQL',
    aliases: <String>['sql', 'pgsql', 'mysql', 'sqlite'],
    caseInsensitive: true,
    keywords: {
      'keyword':  sqlKeywords,
      'literal':  sqlLiterals,
      'built_in': sqlBuiltins,
    },
    contains: <Mode>[
      lineComment(r'--'),
      markastBlockComment,
      strings,
      quotedIdent,
      markastNumber,
      // Bind parameters: $1, :foo, ?
      Mode(scope: MarkastScopes.variable, begin: r'\$\d+|:\w+|\?',
           relevance: 0),
    ],
  );
})();
