#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

OUT_DIR="books/EDITIONS/PDF"
TMP_DIR="books/EDITIONS/.tmp"

SHORT_MD="books/ru/KODEKS/EDITIONS/KODEKS_SHORT.md"
SHORT_EN_MD="books/en/KODEKS/EDITIONS/KODEKS_SHORT.en.md"
FULL_MD="books/EDITIONS/COMBINED/KODEKS_FULL.combined.md"
ALL_MD="books/EDITIONS/COMBINED/ALL_BOOKS_READER.combined.md"
OBSHCHEE_BLAGO_MD="books/EDITIONS/COMBINED/OBSHCHEE_BLAGO_FULL.combined.md"
TEKHNOKOSMOS_MD="books/EDITIONS/COMBINED/TEKHNOKOSMOS_FULL.combined.md"
KARKAS_SMYSLOV_MD="books/EDITIONS/COMBINED/KARKAS_SMYSLOV_FULL.combined.md"

FULL_EN_MD="books/EDITIONS/COMBINED/KODEKS_FULL.en.combined.md"
ALL_EN_MD="books/EDITIONS/COMBINED/ALL_BOOKS_READER.en.combined.md"
OBSHCHEE_BLAGO_EN_MD="books/EDITIONS/COMBINED/OBSHCHEE_BLAGO_FULL.en.combined.md"
TEKHNOKOSMOS_EN_MD="books/EDITIONS/COMBINED/TEKHNOKOSMOS_FULL.en.combined.md"
KARKAS_SMYSLOV_EN_MD="books/EDITIONS/COMBINED/KARKAS_SMYSLOV_FULL.en.combined.md"

SHORT_PDF="books/EDITIONS/PDF/Кодекс_созидательного_общества_краткая_версия.pdf"
SHORT_EN_PDF="books/EDITIONS/PDF/Codex_of_Constructive_Society_short_edition.pdf"
FULL_PDF="books/EDITIONS/PDF/Кодекс_созидательного_общества.pdf"
ALL_PDF="books/EDITIONS/PDF/Книжный_корпус.pdf"
OBSHCHEE_BLAGO_PDF="books/EDITIONS/PDF/Общее_благо_и_справедливая_экономика.pdf"
TEKHNOKOSMOS_PDF="books/EDITIONS/PDF/Технокосмос_и_фронтир.pdf"
KARKAS_SMYSLOV_PDF="books/EDITIONS/PDF/Каркас_смыслов_и_практик.pdf"

FULL_EN_PDF="books/EDITIONS/PDF/Codex_of_Constructive_Society.pdf"
ALL_EN_PDF="books/EDITIONS/PDF/Complete_Book_Corpus.pdf"
OBSHCHEE_BLAGO_EN_PDF="books/EDITIONS/PDF/Common_Good_and_Fair_Economy.pdf"
TEKHNOKOSMOS_EN_PDF="books/EDITIONS/PDF/Technocosmos_and_Frontier.pdf"
KARKAS_SMYSLOV_EN_PDF="books/EDITIONS/PDF/Framework_of_Meanings_and_Practices.pdf"

PANDOC_IMAGE="${PANDOC_IMAGE:-card-book-pandoc:latest}"
USE_DOCKER="${USE_DOCKER:-auto}"
MAIN_FONT="${MAIN_FONT:-Noto Serif}"
SANS_FONT="${SANS_FONT:-Noto Sans}"
MONO_FONT="${MONO_FONT:-Fira Mono}"
FONT_SIZE="${FONT_SIZE:-11pt}"
GEOMETRY="${GEOMETRY:-a5paper,top=16mm,bottom=18mm,inner=16mm,outer=14mm}"
DOCUMENTCLASS="${DOCUMENTCLASS:-book}"
CLASSOPTION="${CLASSOPTION:-oneside,openany}"
TOC_DEPTH="${TOC_DEPTH:-2}"

# Title-page marker images (top-left). Override via env if needed.
COVER_KODEKS="${COVER_KODEKS:-source/a_kodex.png}"
COVER_KODEKS_EN="${COVER_KODEKS_EN:-source/a_kodex.png}"
COVER_ALL="${COVER_ALL:-source/0_common.png}"
COVER_OBSHCHEE_BLAGO="${COVER_OBSHCHEE_BLAGO:-source/f_patent.png}"
COVER_TEKHNOKOSMOS="${COVER_TEKHNOKOSMOS:-source/0_common.png}"
COVER_KARKAS_SMYSLOV="${COVER_KARKAS_SMYSLOV:-source/b_zapovedi.png}"
# Watermark settings (top-left; can go into margins). Override via env if needed.
# COVER_X / COVER_Y are offsets from the page's top-left corner.
# Negative COVER_X moves further into the left margin.
COVER_WIDTH="${COVER_WIDTH:-55mm}"
# Use non-negative offsets by default to avoid clipping outside the page.
COVER_X="${COVER_X:-2mm}"
COVER_Y="${COVER_Y:-2mm}"
# How many first pages should show the watermark
COVER_PAGES="${COVER_PAGES:-1}"
# Debug: set COVER_DEBUG=1 to print a marker on page 1
COVER_DEBUG="${COVER_DEBUG:-0}"

docker_available() {
  command -v docker >/dev/null 2>&1
}

docker_image_exists() {
  [[ -n "$(docker image ls "$PANDOC_IMAGE" --format '{{.ID}}')" ]]
}

local_pandoc_available() {
  command -v pandoc >/dev/null 2>&1
}

run_pandoc() {
  if [[ "$USE_DOCKER" == "1" || "$USE_DOCKER" == "true" ]]; then
    docker run --rm -v "$ROOT_DIR:/data" -w /data "$PANDOC_IMAGE" "$@"
    return
  fi

  if [[ "$USE_DOCKER" == "0" || "$USE_DOCKER" == "false" ]]; then
    pandoc "$@"
    return
  fi

  if docker_available && docker_image_exists; then
    docker run --rm -v "$ROOT_DIR:/data" -w /data "$PANDOC_IMAGE" "$@"
    return
  fi

  if local_pandoc_available; then
    pandoc "$@"
    return
  fi

  echo "Error: no pandoc runtime found."
  echo "Expected Docker image: $PANDOC_IMAGE"
  echo "Or local pandoc in PATH."
  exit 1
}

mkdir -p "$OUT_DIR"
mkdir -p "$TMP_DIR"

if [[ -x "./scripts/build_books_md.sh" ]]; then
  ./scripts/build_books_md.sh
else
  bash ./scripts/build_books_md.sh
fi

build_pdf() {
  local input_file="$1"
  local output_file="$2"
  local title="$3"
  local cover_image="${4:-}"
  local with_toc="${5:-1}"
  local lang="${6:-ru}"

  if [[ ! -f "$input_file" ]]; then
    echo "Skip: missing source file $input_file"
    return 0
  fi

  local rendered_file="$TMP_DIR/$(basename "$input_file" .md).rendered.md"

  if [[ -x "./scripts/render_human_refs.py" ]]; then
    ./scripts/render_human_refs.py "$input_file" "$rendered_file" "$ROOT_DIR"
  else
    python3 ./scripts/render_human_refs.py "$input_file" "$rendered_file" "$ROOT_DIR"
  fi

  local cover_header="$TMP_DIR/$(basename "$input_file" .md).cover.tex"
  : > "$cover_header"
  if [[ -n "$cover_image" && -f "$cover_image" ]]; then
    cat > "$cover_header" <<EOF
\\makeatletter
\\AtBeginDocument{%
EOF
    if [[ "$COVER_DEBUG" == "1" ]]; then
      cat >> "$cover_header" <<'EOF'
  \noindent\textbf{COVER-DEBUG}\par\vspace{1em}%
EOF
    fi
    cat >> "$cover_header" <<EOF
  \\AddToShipoutPicture*{%
    \\setlength{\\unitlength}{1pt}%
    \\put(\\LenToUnit{$COVER_X},\\LenToUnit{\\dimexpr\\paperheight-$COVER_Y\\relax}){%
      \\makebox(0,0)[lt]{\\includegraphics[width=$COVER_WIDTH,keepaspectratio]{$cover_image}}%
    }%
  }%
}
\\makeatother
EOF
  fi

  echo "Building: $output_file"
  if [[ "${with_toc}" == "1" || "${with_toc}" == "true" ]]; then
    run_pandoc \
      "$rendered_file" \
      -o "$output_file" \
      --standalone \
      --toc \
      --toc-depth="$TOC_DEPTH" \
      --top-level-division=chapter \
      --include-in-header="books/EDITIONS/pdf-style.tex" \
      --include-in-header="$cover_header" \
      -V "lang=$lang" \
      -V "documentclass=$DOCUMENTCLASS" \
      -V "classoption=$CLASSOPTION" \
      -V "geometry=$GEOMETRY" \
      -V "mainfont=$MAIN_FONT" \
      -V "sansfont=$SANS_FONT" \
      -V "monofont=$MONO_FONT" \
      -V "fontsize=$FONT_SIZE" \
      --pdf-engine=xelatex
  else
    run_pandoc \
      "$rendered_file" \
      -o "$output_file" \
      --standalone \
      --top-level-division=chapter \
      --include-in-header="books/EDITIONS/pdf-style.tex" \
      --include-in-header="$cover_header" \
      -V "lang=$lang" \
      -V "documentclass=$DOCUMENTCLASS" \
      -V "classoption=$CLASSOPTION" \
      -V "geometry=$GEOMETRY" \
      -V "mainfont=$MAIN_FONT" \
      -V "sansfont=$SANS_FONT" \
      -V "monofont=$MONO_FONT" \
      -V "fontsize=$FONT_SIZE" \
      --pdf-engine=xelatex
  fi
}

echo "Export mode: ${USE_DOCKER} (auto=prefer Docker image $PANDOC_IMAGE)"
# --- Russian PDFs ---
build_pdf "$SHORT_MD" "$SHORT_PDF" "Кодекс созидательного общества: краткая версия" "$COVER_KODEKS" 0 "ru"
build_pdf "$FULL_MD" "$FULL_PDF" "Кодекс созидательного общества" "$COVER_KODEKS" 1 "ru"
build_pdf "$ALL_MD" "$ALL_PDF" "Книжный корпус" "$COVER_ALL" 1 "ru"
build_pdf "$OBSHCHEE_BLAGO_MD" "$OBSHCHEE_BLAGO_PDF" "Общее благо и справедливая экономика" "$COVER_OBSHCHEE_BLAGO" 1 "ru"
build_pdf "$TEKHNOKOSMOS_MD" "$TEKHNOKOSMOS_PDF" "Технокосмос и фронтир" "$COVER_TEKHNOKOSMOS" 1 "ru"
build_pdf "$KARKAS_SMYSLOV_MD" "$KARKAS_SMYSLOV_PDF" "Каркас смыслов и практик" "$COVER_KARKAS_SMYSLOV" 1 "ru"

# --- English PDFs ---
build_pdf "$SHORT_EN_MD" "$SHORT_EN_PDF" "Codex of Constructive Society: Short Edition" "$COVER_KODEKS_EN" 0 "en"
build_pdf "$FULL_EN_MD" "$FULL_EN_PDF" "Codex of Constructive Society" "$COVER_KODEKS_EN" 1 "en"
build_pdf "$ALL_EN_MD" "$ALL_EN_PDF" "Complete Book Corpus" "$COVER_ALL" 1 "en"
build_pdf "$OBSHCHEE_BLAGO_EN_MD" "$OBSHCHEE_BLAGO_EN_PDF" "Common Good and Fair Economy" "$COVER_OBSHCHEE_BLAGO" 1 "en"
build_pdf "$TEKHNOKOSMOS_EN_MD" "$TEKHNOKOSMOS_EN_PDF" "Technocosmos and Frontier" "$COVER_TEKHNOKOSMOS" 1 "en"
build_pdf "$KARKAS_SMYSLOV_EN_MD" "$KARKAS_SMYSLOV_EN_PDF" "Framework of Meanings and Practices" "$COVER_KARKAS_SMYSLOV" 1 "en"

echo "Done. PDFs saved to: $OUT_DIR"
