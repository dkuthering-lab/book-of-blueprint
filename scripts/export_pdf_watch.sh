#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

QUIET=0
INTERVAL="${WATCH_INTERVAL:-2}"

for arg in "$@"; do
  case "$arg" in
    --quiet|-q) QUIET=1 ;;
    --interval=*) INTERVAL="${arg#*=}" ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: ./scripts/export_pdf_watch.sh [--quiet|-q] [--interval=N]"
      exit 1
      ;;
  esac
done

log() {
  if [[ "$QUIET" -eq 0 ]]; then
    echo "$@"
  fi
}

list_sources() {
  # Source set: all markdown books, excluding generated PDFs folder.
  # Keep stable ordering for deterministic checksum.
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if [[ "$file" != books/EDITIONS/PDF/* ]]; then
      printf "%s\n" "$file"
    fi
  done < <(cd "$ROOT_DIR" && rg --files books -g '*.md' | sort -u)
}

snapshot_hash() {
  local files
  mapfile -t files < <(list_sources)
  if [[ "${#files[@]}" -eq 0 ]]; then
    echo "no-files"
    return
  fi
  # cksum is POSIX and available on macOS/Linux.
  cksum "${files[@]}" | cksum | awk '{print $1}'
}

run_export() {
  local started_at
  started_at="$(date '+%Y-%m-%d %H:%M:%S')"
  log "[$started_at] Change detected -> rebuild PDFs"
  if ./scripts/export_pdf.sh; then
    local finished_at
    finished_at="$(date '+%Y-%m-%d %H:%M:%S')"
    log "[$finished_at] Rebuild OK"
  else
    local failed_at
    failed_at="$(date '+%Y-%m-%d %H:%M:%S')"
    echo "[$failed_at] Rebuild FAILED (fix errors and keep editing)"
  fi
}

log "Watching markdown changes (interval: ${INTERVAL}s)"
log "Press Ctrl+C to stop."

last_hash="$(snapshot_hash)"
run_export

while true; do
  sleep "$INTERVAL"
  current_hash="$(snapshot_hash)"
  if [[ "$current_hash" != "$last_hash" ]]; then
    last_hash="$current_hash"
    run_export
  fi
done
