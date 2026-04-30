#!/usr/bin/env python3

import os
import re
import sys
from functools import lru_cache


REF_RE = re.compile(r"`([^`\n]+)`")
H1_RE = re.compile(r"^\s*#\s+(.+?)\s*$")


def read_text(path: str) -> str:
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        return f.read()


@lru_cache(maxsize=None)
def first_h1(path: str):
    if not os.path.isfile(path):
        return None
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                m = H1_RE.match(line)
                if m:
                    return m.group(1).strip()
    except OSError:
        return None
    return None


def resolve_target(token: str, current_file: str, root_dir: str):
    cands = []
    raw = token.strip()

    # Directory-style refs -> try INDEX.md or INDEX.en.md inside.
    if raw.endswith("/"):
        cands.append(os.path.normpath(os.path.join(root_dir, raw, "INDEX.md")))
        cands.append(os.path.normpath(os.path.join(root_dir, raw, "INDEX.en.md")))
        # Also try with docs/ prefix if not present
        if not raw.startswith("docs/"):
            cands.append(os.path.normpath(os.path.join(root_dir, "docs", raw, "INDEX.md")))
            cands.append(os.path.normpath(os.path.join(root_dir, "docs", raw, "INDEX.en.md")))
        cands.append(os.path.normpath(os.path.join(os.path.dirname(current_file), raw, "INDEX.md")))
        cands.append(os.path.normpath(os.path.join(os.path.dirname(current_file), raw, "INDEX.en.md")))

    if os.path.isabs(token):
        cands.append(raw)
    else:
        cands.append(os.path.normpath(os.path.join(root_dir, raw)))
        # Also try with docs/ prefix if not present
        if not raw.startswith("docs/"):
            cands.append(os.path.normpath(os.path.join(root_dir, "docs", raw)))
        cands.append(os.path.normpath(os.path.join(os.path.dirname(current_file), raw)))

    # If token points to existing directory (without trailing slash),
    # try its INDEX.md.
    dir_cands = []
    for c in list(cands):
        if os.path.isdir(c):
            dir_cands.append(os.path.join(c, "INDEX.md"))
    cands.extend(dir_cands)

    for c in cands:
        if os.path.isfile(c):
            return c
    return None


def label_for_md(path: str):
    section = first_h1(path)
    idx = os.path.join(os.path.dirname(path), "INDEX.md")
    book = first_h1(idx)

    if section and book and section != book:
        return f"«{book} — {section}»"
    if section:
        return f"«{section}»"
    return None


def render_refs(text: str, current_file: str, root_dir: str):
    def repl(match):
        token = match.group(1)
        path = resolve_target(token, current_file, root_dir)
        if not path:
            return match.group(0)
        label = label_for_md(path)
        return label if label else match.group(0)

    return REF_RE.sub(repl, text)


def promote_leading_h1_to_title(text: str):
    # If document already has YAML metadata, keep as is.
    stripped = text.lstrip()
    if stripped.startswith("---\n"):
        return text

    lines = text.splitlines()
    idx = 0
    while idx < len(lines) and lines[idx].strip() == "":
        idx += 1
    if idx >= len(lines):
        return text

    m = H1_RE.match(lines[idx])
    if not m:
        return text

    title = m.group(1).strip()
    # Drop title line and one immediate blank line if present.
    body_lines = lines[:idx] + lines[idx + 1 :]
    if body_lines and body_lines[0].strip() == "":
        body_lines = body_lines[1:]

    yaml = ["---", f'title: "{title}"', "lang: ru", "---", ""]
    return "\n".join(yaml + body_lines) + "\n"


def main():
    if len(sys.argv) < 2 or len(sys.argv) > 4:
        print("Usage: render_human_refs.py <input.md> [output.md] [root_dir]", file=sys.stderr)
        return 2

    input_path = os.path.abspath(sys.argv[1])
    output_path = None
    root_dir = os.getcwd()

    if len(sys.argv) >= 3:
        output_path = os.path.abspath(sys.argv[2])
    if len(sys.argv) == 4:
        root_dir = os.path.abspath(sys.argv[3])

    text = read_text(input_path)
    rendered = render_refs(text, input_path, root_dir)
    rendered = promote_leading_h1_to_title(rendered)

    if output_path:
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        with open(output_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(rendered)
    else:
        sys.stdout.write(rendered)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
