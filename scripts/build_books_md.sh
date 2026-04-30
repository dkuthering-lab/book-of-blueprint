#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="docs/books/EDITIONS/COMBINED"
mkdir -p "$OUT_DIR"

emit_file() {
  local file_path="$1"
  local out_file="$2"

  # Keep Codex section scaffolding headings as-is.
  if [[ "$file_path" == docs/books/ru/KODEKS/EDITIONS/KODEKS_FULL_*.md || "$file_path" == docs/books/en/KODEKS/EDITIONS/KODEKS_FULL_*.en.md ]]; then
    cat "$file_path" >> "$out_file"
    return 0
  fi

  # Demote headings by one level (H1->H2, H2->H3, ...) to reduce TOC noise.
  # Preserve fenced code blocks.
  python3 - "$file_path" >> "$out_file" <<'PY'
import re, sys
path = sys.argv[1]
text = open(path, "r", encoding="utf-8", errors="ignore").read().splitlines(True)
out = []
in_fence = False
fence_re = re.compile(r"^\s*```")
head_re = re.compile(r"^(#{1,6})(\s+.*)$")
for line in text:
    if fence_re.match(line):
        in_fence = not in_fence
        out.append(line)
        continue
    if not in_fence:
        m = head_re.match(line)
        if m:
            hashes, rest = m.group(1), m.group(2)
            if len(hashes) < 6:
                line = "#" + hashes + rest + ("\n" if not line.endswith("\n") else "")
    out.append(line)
sys.stdout.write("".join(out))
PY
}

build_from_manifest() {
  local manifest="$1"
  local out_file="$2"
  local _title="${3:-}"

  if [[ ! -f "$manifest" ]]; then
    echo "Missing manifest: $manifest"
    exit 1
  fi

  {
    echo "# $_title"
    echo
  } > "$out_file"

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%"${line##*[![:space:]]}"}"
    line="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$line" ]] && continue
    [[ "$line" == \#* ]] && continue

    if [[ ! -f "$line" ]]; then
      echo "Missing source file from manifest: $line"
      exit 1
    fi

    emit_file "$line" "$out_file"
    echo >> "$out_file"
    echo >> "$out_file"
  done < "$manifest"

  echo "Built combined markdown: $out_file"
}

# --- Russian Editions ---
build_from_manifest \
  "docs/books/ru/KODEKS/EDITIONS/MANIFEST_KODEKS_FULL.txt" \
  "$OUT_DIR/KODEKS_FULL.combined.md" \
  "Кодекс"

build_from_manifest \
  "docs/books/EDITIONS/MANIFEST_ALL_BOOKS_READER.txt" \
  "$OUT_DIR/ALL_BOOKS_READER.combined.md" \
  "Сборка всех книг"

build_from_manifest \
  "docs/books/EDITIONS/MANIFEST_OBSHCHEE_BLAGO.txt" \
  "$OUT_DIR/OBSHCHEE_BLAGO_FULL.combined.md" \
  "Общее благо и справедливая экономика"

build_from_manifest \
  "docs/books/EDITIONS/MANIFEST_TEKHNOKOSMOS.txt" \
  "$OUT_DIR/TEKHNOKOSMOS_FULL.combined.md" \
  "Технокосмос и фронтир"

build_from_manifest \
  "docs/books/EDITIONS/MANIFEST_KARKAS_SMYSLOV.txt" \
  "$OUT_DIR/KARKAS_SMYSLOV_FULL.combined.md" \
  "Каркас смыслов и практик"

# --- English Editions ---
build_from_manifest \
  "docs/books/en/KODEKS/EDITIONS/MANIFEST_KODEKS_FULL.en.txt" \
  "$OUT_DIR/KODEKS_FULL.en.combined.md" \
  "Codex"

build_from_manifest \
  "docs/books/en/MANIFEST_ALL_BOOKS_READER.en.txt" \
  "$OUT_DIR/ALL_BOOKS_READER.en.combined.md" \
  "Complete Book Corpus"

build_from_manifest \
  "docs/books/en/MANIFEST_OBSHCHEE_BLAGO.en.txt" \
  "$OUT_DIR/OBSHCHEE_BLAGO_FULL.en.combined.md" \
  "Common Good and Fair Economy"

build_from_manifest \
  "docs/books/en/MANIFEST_TEKHNOKOSMOS.en.txt" \
  "$OUT_DIR/TEKHNOKOSMOS_FULL.en.combined.md" \
  "Technocosmos and Frontier"

build_from_manifest \
  "docs/books/en/MANIFEST_KARKAS_SMYSLOV.en.txt" \
  "$OUT_DIR/KARKAS_SMYSLOV_FULL.en.combined.md" \
  "Framework of Meanings and Practices"

echo "Done. Combined markdown files are in: $OUT_DIR"
