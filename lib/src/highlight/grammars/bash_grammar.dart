import 'package:re_highlight/re_highlight.dart';

import '_shared.dart';

/// Markast's enhanced Bash grammar.
///
/// Improvements:
///   * Variable expansion `$var`, `${var}`, `${var:-default}` painted as
///     `variable`.
///   * Command substitution `$(...)` and backticks painted as `subst`.
///   * Heredocs `<<EOT … EOT` and here-strings `<<<`.
///   * Common commands and shell built-ins identified.
///   * Shebang line `#!/bin/bash` painted as `meta`.
final markastBashGrammar = (() {
  const bashKeywords = <String>[
    'if', 'then', 'else', 'elif', 'fi', 'case', 'esac', 'for', 'select',
    'while', 'until', 'do', 'done', 'in', 'function', 'time', 'coproc',
    'return', 'break', 'continue', 'exit', 'declare', 'local', 'readonly',
    'export', 'unset', 'shift', 'eval', 'exec', 'set', 'trap', 'source',
  ];

  const bashLiterals = <String>['true', 'false'];

  const bashBuiltins = <String>[
    'echo', 'printf', 'read', 'cd', 'pwd', 'pushd', 'popd', 'dirs',
    'alias', 'unalias', 'history', 'jobs', 'fg', 'bg', 'kill', 'wait',
    'test', 'getopts',
    // Common commands often used in scripts
    'cat', 'grep', 'sed', 'awk', 'cut', 'sort', 'uniq', 'head', 'tail',
    'wc', 'tr', 'find', 'xargs', 'tee', 'curl', 'wget', 'ssh', 'scp',
    'rsync', 'tar', 'gzip', 'gunzip', 'zip', 'unzip', 'chmod', 'chown',
    'mkdir', 'rmdir', 'mv', 'cp', 'rm', 'ln', 'ls', 'touch', 'stat',
    'env', 'which', 'whereis', 'sudo', 'systemctl', 'service', 'ps',
    'top', 'df', 'du', 'docker', 'git', 'make', 'npm', 'yarn', 'pnpm',
    'pip', 'python', 'node', 'go', 'cargo',
  ];

  // Shebang
  final shebang = Mode(
    scope: MarkastScopes.meta,
    begin: r'^#!.*$',
    relevance: 10,
  );

  // ${var} or ${var:-default}
  final braceVar = Mode(
    scope: MarkastScopes.variable,
    begin: r'\$\{',
    end: r'\}',
  );

  final dollarVar = Mode(
    scope: MarkastScopes.variable,
    begin: r'\$[*@#?!\$\d-]|\$[A-Za-z_]\w*',
    relevance: 0,
  );

  final cmdSubst = Mode(
    scope: MarkastScopes.subst,
    begin: r'\$\(',
    end: r'\)',
  );

  final backtickSubst = Mode(
    scope: MarkastScopes.subst,
    begin: r'`',
    end: r'`',
  );

  final strings = Mode(
    variants: <Mode>[
      Mode(scope: MarkastScopes.string, begin: r'"', end: r'"',
           contains: <Mode>[markastBackslashEscape, dollarVar, braceVar,
                            cmdSubst, backtickSubst]),
      Mode(scope: MarkastScopes.string, begin: r"'", end: r"'"),
      // Heredoc
      Mode(scope: MarkastScopes.string,
           begin: '<<-?\\s*["\']?(\\w+)["\']?',
           end: r'$', relevance: 0,
           contains: <Mode>[dollarVar, braceVar, cmdSubst]),
    ],
  );

  return Mode(
    name: 'Bash',
    aliases: <String>['bash', 'sh', 'zsh', 'shell'],
    keywords: {
      'keyword':  bashKeywords,
      'literal':  bashLiterals,
      'built_in': bashBuiltins,
    },
    contains: <Mode>[
      shebang,
      lineComment(r'#'),
      strings,
      braceVar,
      dollarVar,
      cmdSubst,
      backtickSubst,
      markastNumber,
      // Function definition: name() { ... }
      Mode(
        scope: MarkastScopes.functionName,
        begin: r'\b[A-Za-z_]\w*\s*\(\)',
        returnBegin: true,
        contains: <Mode>[
          Mode(scope: MarkastScopes.titleFn, begin: r'[A-Za-z_]\w*'),
        ],
        relevance: 0,
      ),
    ],
  );
})();
