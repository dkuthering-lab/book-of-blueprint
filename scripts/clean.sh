#!/usr/bin/env bash
# Очистка артефактов сборки

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Cleaning build artifacts..."
rm -rf books/EDITIONS/COMBINED/*.md
rm -rf books/EDITIONS/.tmp/*
# Раскомментируйте строку ниже, если хотите удалять и готовые PDF
# rm -rf books/EDITIONS/PDF/*.pdf

echo "Done."
