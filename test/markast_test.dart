import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:markast/markast.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';

/// Smoke tests for Markast's enhanced highlight grammars.
///
/// Validates that every enhanced grammar:
///   1. Parses a representative code sample without throwing.
///   2. Returns a non-null [TextSpan] (the result actually rendered).
///   3. Produces at least one styled child span (the grammar found tokens).
void main() {
  const baseStyle = TextStyle(fontFamily: 'monospace', fontSize: 14);
  final ht = MarkastHighlightTheme(theme: atomOneDarkTheme);

  bool hasStyledChildren(InlineSpan? span) {
    if (span == null) return false;
    if (span is TextSpan) {
      if (span.style != null &&
          span.style != baseStyle &&
          span.style!.color != null &&
          span.style!.color != baseStyle.color) {
        return true;
      }
      if (span.children != null) {
        return span.children!.any(hasStyledChildren);
      }
    }
    return false;
  }

  group('MarkastHighlightTheme — enhanced grammar registry', () {
    test('reports the expected list of enhanced languages', () {
      expect(MarkastHighlightTheme.enhancedLanguages, contains('dart'));
      expect(MarkastHighlightTheme.enhancedLanguages, contains('python'));
      expect(MarkastHighlightTheme.enhancedLanguages, contains('plantuml'));
      expect(MarkastHighlightTheme.enhancedLanguages.length, greaterThanOrEqualTo(20));
    });
  });

  group('Per-language smoke', () {
    final samples = <String, String>{
      'dart': '''
@override
Future<List<String>?> fetch(int id, {required String token}) async {
  final url = 'https://api.example.com/users/\$id';
  return ["a", "b"];
}
''',
      'python': '''
@dataclass
class User:
    name: str = "guest"

def greet(user: User) -> str:
    return f"Hi {user.name}"
''',
      'javascript': '''
class Foo extends Bar {
  greet(name) { return `Hi \${name}`; }
}
''',
      'typescript': '''
interface User { name: string; age: number; }
type Result<T> = { ok: true; value: T } | { ok: false; error: string };
''',
      'go': '''
package main
import "fmt"
func main() { fmt.Println("hello") }
''',
      'rust': '''
#[derive(Debug)]
struct Point<'a> { x: &'a str }
fn main() { println!("hi"); }
''',
      'java': '''
@Override
public class Foo extends Bar {
  private final String name = "x";
}
''',
      'kotlin': '''
data class User(val name: String)
fun greet(u: User) = "Hi \${u.name}"
''',
      'swift': '''
struct User { let name: String }
func greet(_ u: User) -> String { "Hi \\(u.name)" }
''',
      'csharp': '''
[Serializable]
public class Foo {
  public string Name { get; set; } = \$"hello";
}
''',
      'cpp': '''
#include <iostream>
template<typename T> class Box { T value; };
int main() { std::cout << "hi" << std::endl; }
''',
      'c': '''
#include <stdio.h>
int main(void) { printf("hi\\n"); return 0; }
''',
      'ruby': '''
class User < Base
  attr_accessor :name
  def greet; "Hi #{@name}"; end
end
''',
      'php': '''
<?php
#[Route('/users')]
class UserController { public function index() { return \$this->users; } }
''',
      'sql': '''
SELECT id, COUNT(*) AS total FROM users WHERE active = TRUE GROUP BY id;
''',
      'bash': '''
#!/usr/bin/env bash
greet() { echo "Hi \$1"; }
greet "world"
''',
      'yaml': '''
name: example
version: 1.0
deps:
  - foo
  - bar
''',
      'json': '{"name":"x","items":[1,2,3],"on":true}',
      'markdown': '''
# Title
**bold** and *italic*
- item 1
> quote
''',
      'plantuml': '''
@startuml
actor User
class Foo
User --> Foo
@enduml
''',
      'html': '''
<!DOCTYPE html>
<html><body><h1 class="t">Hi</h1></body></html>
''',
      'css': '''
.foo { color: #ff0000; padding: 8px; }
@media (max-width: 600px) { #bar:hover { display: none; } }
''',
    };

    for (final entry in samples.entries) {
      test('${entry.key}: parses and produces styled tokens', () {
        final span = ht.highlight(entry.value, entry.key, baseStyle);
        expect(span, isNotNull, reason: '${entry.key} returned null span');
        expect(hasStyledChildren(span), isTrue,
            reason: '${entry.key} produced no styled tokens');
      });
    }
  });

  group('Aliases resolve correctly', () {
    test('"js" → JavaScript', () {
      final span = ht.highlight('const x = 1;', 'js', baseStyle);
      expect(span, isNotNull);
    });
    test('"py" → Python', () {
      final span = ht.highlight('x = 1', 'py', baseStyle);
      expect(span, isNotNull);
    });
    test('"md" → Markdown', () {
      final span = ht.highlight('# Hi', 'md', baseStyle);
      expect(span, isNotNull);
    });
    test('Unknown language returns null', () {
      final span = ht.highlight('foo', 'totally-fake-lang-xyz', baseStyle);
      expect(span, isNull);
    });
  });
}
