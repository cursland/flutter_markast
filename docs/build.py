#!/usr/bin/env python3
"""
build.py — Convert Markdown sources to HTML + JSON for the markast docs site.

Usage:
    python build.py                # build all sources/
    python build.py path/to/file.md [...]  # build specific files

Output structure mirrors sources/:
    sources/elements/heading.md
        → content/elements/heading.html
        → content/elements/heading.json
"""

import sys
from pathlib import Path

try:
    from markast import parse
except ImportError:
    print("ERROR: markast is not installed. Run: pip install markast")
    sys.exit(1)

ROOT    = Path(__file__).parent
SOURCES = ROOT / "sources"
CONTENT = ROOT / "content"


def convert(src: Path) -> None:
    rel      = src.relative_to(SOURCES)
    dst_html = (CONTENT / rel).with_suffix(".html")
    dst_json = (CONTENT / rel).with_suffix(".json")

    dst_html.parent.mkdir(parents=True, exist_ok=True)

    text = src.read_text(encoding="utf-8")
    doc  = parse(text)

    html = f'<article class="markast">{doc.to_html()}</article>\n'
    dst_html.write_text(html, encoding="utf-8")
    dst_json.write_text(doc.to_json(), encoding="utf-8")

    print(f"  ok  {rel}  ->  {dst_html.name}  +  {dst_json.name}")


def main() -> None:
    if len(sys.argv) > 1:
        sources = [Path(p).resolve() for p in sys.argv[1:]]
    else:
        sources = sorted(SOURCES.rglob("*.md"))

    if not sources:
        print(f"No .md files found in {SOURCES}")
        return

    print(f"Building {len(sources)} file(s)...\n")
    errors = 0
    for src in sources:
        try:
            convert(src)
        except Exception as exc:
            print(f"  ERR  {src.name}  ->  {exc}")
            errors += 1

    print(f"\nDone." if not errors else f"\nDone with {errors} error(s).")


if __name__ == "__main__":
    main()
