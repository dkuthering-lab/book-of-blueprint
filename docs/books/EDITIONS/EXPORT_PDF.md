# Export PDF

## Быстрый запуск

Из корня проекта:

```bash
chmod +x scripts/export_pdf.sh
./scripts/export_pdf.sh
```

Скрипт в режиме `auto` сначала пытается использовать Docker-образ `card-book-pandoc:latest` (как в соседнем проекте), и только если его нет — локальный `pandoc`.

## Что собирается

- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/Кодекс_созидательного_общества_краткая_версия.pdf`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/CODEX_CONSTRUCTIVE_SOCIETY_SHORT_EN.pdf`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/Кодекс_созидательного_общества_полная_версия.pdf`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/Книжный_корпус_полная_сборка.pdf`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/Общее_благо_и_справедливая_экономика_полная_версия.pdf`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/Технокосмос_и_фронтир_полная_версия.pdf`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/PDF/Каркас_смыслов_и_практик_полная_версия.pdf`

Перед экспортом PDF скрипт автоматически склеивает главы в единые markdown-файлы:

- `docs/docs/docs/docs/docs/docs/books/EDITIONS/COMBINED/KODEKS_FULL.combined.md`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/COMBINED/ALL_BOOKS_READER.combined.md`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/COMBINED/OBSHCHEE_BLAGO_FULL.combined.md`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/COMBINED/TEKHNOKOSMOS_FULL.combined.md`
- `docs/docs/docs/docs/docs/docs/books/EDITIONS/COMBINED/KARKAS_SMYSLOV_FULL.combined.md`

Также перед рендерингом автоматически выполняется "очеловечивание" ссылок на `.md`:
пути в тексте заменяются на формат "Книга — Раздел" по заголовкам файлов.

## Варианты рантайма

### 1) Рекомендуемый: Docker-образ

По умолчанию используется:

- `card-book-pandoc:latest`

Можно указать другой образ:

```bash
PANDOC_IMAGE=my-pandoc-image:tag ./scripts/export_pdf.sh
```

Настройка шрифтов (актуально для кириллицы):

```bash
MAIN_FONT="Noto Serif" SANS_FONT="Noto Sans" MONO_FONT="Fira Mono" ./scripts/export_pdf.sh
```

Настройка формата страницы и полей:

```bash
GEOMETRY="a5paper,top=16mm,bottom=18mm,inner=16mm,outer=14mm" ./scripts/export_pdf.sh
```

По умолчанию скрипт уже собирает в формате A5 с умеренно узкими полями.
Главы начинаются с новой страницы (режим `book` + chapter division).
Дополнительно подключается стиль `docs/docs/docs/docs/docs/docs/books/EDITIONS/pdf-style.tex` для переносов и аккуратного набора.

Изображения на титульных страницах (верхний левый угол) подставляются автоматически.
Можно переопределить через переменные окружения:

```bash
COVER_KODEKS="source/a_kodex.png" \
COVER_KODEKS_EN="source/a_kodex.png" \
COVER_ALL="source/0_common.png" \
COVER_OBSHCHEE_BLAGO="source/f_patent.png" \
COVER_TEKHNOKOSMOS="source/0_common.png" \
COVER_KARKAS_SMYSLOV="source/b_zapovedi.png" \
./scripts/export_pdf.sh
```

Подгонка размера/отступа изображения:

```bash
COVER_WIDTH="55mm" COVER_X="2mm" COVER_Y="2mm" COVER_PAGES="1" ./scripts/export_pdf.sh
```

### 2) Локальный pandoc

Если хотите принудительно локальный запуск:

```bash
USE_DOCKER=false ./scripts/export_pdf.sh
```

Если хотите принудительно Docker:

```bash
USE_DOCKER=true ./scripts/export_pdf.sh
```

## Авто-пересборка при правках

```bash
chmod +x scripts/export_pdf_watch.sh
./scripts/export_pdf_watch.sh
```

Опции:

- тихий режим: `./scripts/export_pdf_watch.sh --quiet`
- интервал проверки (сек): `./scripts/export_pdf_watch.sh --interval=1`
