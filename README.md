# Кодекс Разумного Созидания / Codex of Rational Creation

[![Deploy Codex to GitHub Pages](https://github.com/dkuthering-lab/book-of-blueprint/actions/workflows/deploy.yml/badge.svg)](https://github.com/dkuthering-lab/book-of-blueprint/actions/workflows/deploy.yml)

**Official Website / Официальный сайт:** [dkuthering-lab.github.io/book-of-blueprint](https://dkuthering-lab.github.io/book-of-blueprint/)

---

## 🇷🇺 Русский

Проект по созданию серии книг и практических руководств о деятельной человеческой этике, правде и созидательном развитии.

### О проекте
Кодекс — это рабочий этический стандарт для тех, кто принимает решения и несет ответственность за последствия. В центре внимания:
- Уважение к истине и человеческому труду.
- Сочетание технологического прогресса и человеческой ответственности.
- Биоэтика, журналистика смыслов и культура государственности.

### Структура репозитория
- `docs/` — исходные тексты документации и книг (Markdown).
  - `docs/books/ru/` — русская версия.
  - `docs/books/en/` — английская версия.
  - `docs/books/EDITIONS/` — манифесты сборок и PDF-артефакты.
- `scripts/` — инструменты для сборки и экспорта.
- `mkdocs.yml` — конфигурация сайта.

### Ссылки на PDF
- [Кодекс (полная версия)](https://dkuthering-lab.github.io/book-of-blueprint/books/EDITIONS/PDF/Кодекс_созидательного_общества.pdf)
- [Краткая версия](https://dkuthering-lab.github.io/book-of-blueprint/books/EDITIONS/PDF/Кодекс_созидательного_общества_краткая_версия.pdf)

---

## 🇺🇸 English

A project to create a series of books and practical guides on active human ethics, truth, and constructive development.

### About the Project
The Codex is a working ethical standard for those who make decisions and bear responsibility for the consequences. Key focus areas:
- Respect for truth and human labor.
- Combining technological progress with human responsibility.
- Bioethics, meaningful journalism, and the culture of governance.

### Repository Structure
- `docs/` — source texts for documentation and books (Markdown).
  - `docs/books/en/` — English version.
  - `docs/books/ru/` — Russian version.
  - `docs/books/EDITIONS/` — build manifests and PDF artifacts.
- `scripts/` — build and export tools.
- `mkdocs.yml` — site configuration.

### PDF Links
- [Codex (Full Edition)](https://dkuthering-lab.github.io/book-of-blueprint/books/EDITIONS/PDF/Codex_of_Constructive_Society.pdf)
- [Short Edition](https://dkuthering-lab.github.io/book-of-blueprint/books/EDITIONS/PDF/Codex_of_Constructive_Society_short_edition.pdf)

---

## How to Build / Как собрать

### 1. Static Site (MkDocs)
```bash
pip install mkdocs-material
mkdocs serve
```

### 2. PDF Export
Requires `pandoc` and `XeLaTeX` (or Docker):
```bash
bash scripts/export_pdf.sh
```
Artifacts will be in `docs/books/EDITIONS/PDF/`.

---
**GitHub Repository:** [dkuthering-lab/book-of-blueprint](https://github.com/dkuthering-lab/book-of-blueprint)
