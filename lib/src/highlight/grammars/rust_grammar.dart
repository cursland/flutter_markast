import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Rust grammar.
///
/// Improvements:
///   * Lifetimes `'a` painted as `symbol`.
///   * Attributes `#[derive(Debug)]` and `#![...]` painted as `meta`.
///   * Macro invocations `println!`, `vec!` painted as `built_in`.
///   * `fn name(...)` extracts name as `title.function_`.
///   * `struct Foo {}` / `enum Foo {}` / `trait Foo` extract title.
///   * Char literals (single quotes) distinguished from lifetimes.
final markastRustGrammar = (() {
  const rsKeywords = <String>[
    'as', 'async', 'await', 'break', 'const', 'continue', 'crate', 'dyn',
    'else', 'enum', 'extern', 'false', 'fn', 'for', 'if', 'impl', 'in',
    'let', 'loop', 'match', 'mod', 'move', 'mut', 'pub', 'ref', 'return',
    'self', 'Self', 'static', 'struct', 'super', 'trait', 'true', 'type',
    'unsafe', 'use', 'where', 'while', 'union',
  ];

  const rsLiterals = <String>['true', 'false', 'None', 'Some', 'Ok', 'Err'];

  const rsBuiltins = <String>[
    // Primitives
    'bool', 'char', 'f32', 'f64', 'i8', 'i16', 'i32', 'i64', 'i128', 'isize',
    'u8', 'u16', 'u32', 'u64', 'u128', 'usize', 'str',
    // Stdlib (commonly used)
    'String', 'Vec', 'Option', 'Result', 'Box', 'Rc', 'Arc', 'RefCell',
    'Cell', 'Mutex', 'RwLock', 'HashMap', 'HashSet', 'BTreeMap', 'BTreeSet',
    'Iterator', 'Future', 'Pin', 'PhantomData', 'Cow',
    // Macros (handled also via macro pattern)
    'println', 'print', 'eprintln', 'eprint', 'format', 'write', 'writeln',
    'panic', 'assert', 'assert_eq', 'assert_ne', 'debug_assert', 'todo',
    'unimplemented', 'unreachable', 'vec', 'dbg',
  ];

  // Attribute: #[...] or #![...]
  final attribute = Mode(
    scope: MarkastScopes.meta,
    begin: r'#!?\[',
    end: r'\]',
    contains: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"',
           contains: <Mode>[markastBackslashEscape]),
    ],
  );

  // Lifetime: 'a, 'static — must NOT match a char literal 'x'
  final lifetime = Mode(
    scope: MarkastScopes.symbol,
    begin: r"'[a-z_][a-zA-Z0-9_]*(?!')",
    relevance: 0,
  );

  // Char literal: single char, possibly escaped
  final charLit = Mode(
    scope: MarkastScopes.string,
    begin: r"'(\\.|.)'",
    relevance: 0,
  );

  // Macro invocation: name!
  final macroCall = Mode(
    scope: MarkastScopes.builtIn,
    begin: r'\b[a-z_][a-zA-Z0-9_]*!',
    relevance: 0,
  );

  // Strings (regular + raw + byte)
  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'b?"', end: r'"',
           contains: <Mode>[markastBackslashEscape]),
      Mode(scope: MarkastScopes.string, begin: r'b?r"', end: r'"'),
      Mode(scope: MarkastScopes.string, begin: r'b?r#+"', end: r'"#+'),
    ],
  );

  final fnDecl = Mode(
    scope: MarkastScopes.functionName,
    beginKeywords: 'fn',
    end: r'(?=[\(<])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
    ],
  );

  final classDecl = Mode(
    scope: MarkastScopes.className,
    beginKeywords: 'struct enum trait union',
    end: r'(?=[\{\(<;])',
    excludeEnd: true,
    contains: <Mode>[
      Mode(scope: MarkastScopes.titleClass, begin: r'[A-Z][\w]*'),
    ],
  );

  return Mode(
    name: 'Rust',
    aliases: <String>['rust', 'rs'],
    keywords: {
      'keyword':  rsKeywords,
      'literal':  rsLiterals,
      'built_in': rsBuiltins,
    },
    contains: <Mode>[
      lineComment(r'//'),
      markastBlockComment,
      attribute,
      strings,
      charLit,
      lifetime,
      macroCall,
      classDecl,
      fnDecl,
      markastNumber,
      Mode(scope: MarkastScopes.keyword, begin: r'=>', relevance: 0),
    ],
  );
})();
