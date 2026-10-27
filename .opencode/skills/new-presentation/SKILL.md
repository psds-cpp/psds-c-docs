---
name: new-presentation
description: Рецепт добавления новой презентации в psds-c-docs — конвейер (план с согласованием с пользователем → текст → LaTeX + Makefile → сборка), структура beamer-источника, подключение к Makefile (build/help/install), сборка через make в nix develop и финальная проверка nix build. Use when creating, adding or updating a presentation, editing its Makefile targets, or debugging the pdf build.
---

# Новая презентация psds-c-docs

## 0. Конвейер

Новая презентация создаётся только по конвейеру (управляет `pm`):

1. **План** — `c-expert` готовит план тем и примеров
   → `build/drafts/<NN-name>.plan.md`.
2. **Согласование** — `pm` показывает план пользователю и получает
   утверждение (замечания → `c-expert` дорабатывает план, согласование
   повторяется). Без утверждённого плана конвейер не продолжается.
3. **Текст** — `c-expert` пишет текст по слайдам по согласованному
   плану → `build/drafts/<NN-name>.md`.
4. **Сборка** — `latex-dev`: каркас (раздел 1) + Makefile (раздел 2)
   + `make` до успеха (раздел 3).
5. **Проверка** — `pm`: `nix build` + содержимое `result/presentations/`.

## 1. Каркас

Директория `presentations/<NN-name>/` (NN — следующий номер серии,
имя — kebab-case), основной файл `<name>.tex`. Образец:
`presentations/01-intro/intro.tex`.

Структура `.tex`:

- `\documentclass[compress,aspectratio=169]{beamer}` — слайды 16:9;
  опция `aspectratio=169` обязательна (из `presentationtemplate` задать
  нельзя: beamer не даёт менять `papersize` через `\newgeometry`)
- `\usepackage{presentationtemplate}` — шрифты, логотипы, автор, дата
  уже заданы в шаблоне; повторно объявлять нельзя
- `\usepackage[fontsize=\footnotesize, askip=3mm]{terminal}` и
  `\usepackage[fontsize=\footnotesize, linenosfontsize=\tiny, askip=3mm]{mylisting}`
  — только если в презентации есть примеры/терминал
- `\usepackage{myitemize}` — окружение `myitemize` для буллетов
  (использовать для маркированных списков)
- `\subtitle{...}` — переопределяет подзаголовок по умолчанию из шаблона
- Фреймы `\begin{frame}[...]{...}\frametitle{...}\end{frame}`;
  фреймы с кодом — обязательная опция `[fragile]`

Примеры кода:

- Файловый пример: файл `presentations/<NN-name>/<file>.c` (или `.h`) и
  `\myinputlisting[minted language=c]{presentations/<NN-name>/}{<file>.c}`
  — путь от корня проекта: первый аргумент — каталог (с завершающим
  `/`), второй — имя файла.
- Короткий фрагмент: окружение
  `\begin{myinplacelisting}[minted language=c]` …код…
  `\end{myinplacelisting}`
- Запуск программы: окружение `terminalwindow`, команды
  `\shellcommand{gcc file.c}` и т.п. (escape-последовательность `||`).

C-код во всех примерах должен быть корректным и компилируемым gcc.

Ограничения листингов:

- строки не длиннее 30 символов, если листинг занимает шириной
  полслайда, и не длиннее 60 символов, если он занимает весь слайд;
- не более 15 строк: более длинный листинг отмасштабировать
  (уменьшить размер шрифта), чтобы вписался по высоте.

## 2. Makefile — четыре места

По образцу цели `01-intro.pdf`:

1. Цель `build`: добавить `<NN-name>.pdf` в список зависимостей.
2. Правило (в конце файла, рядом с остальными):

   ```make
   <NN-name>.pdf: \
   	presentations/<NN-name>/<name>.tex \
   	$(wildcard presentations/<NN-name>/*.c) \
   	$(wildcard presentations/<NN-name>/*.h)
   	$(call generate_pdf,$<,$@)
   ```

3. Цель `help`: строка
   `@printf "<NN-name>.pdf\tbuild presentation <NN-name>.pdf\n"`.
4. Цель `install`: строка
   `cp "$(BUILD_DIR)/<NN-name>.pdf" "$(PREFIX)/presentations/<NN-name>.pdf"`.

Если в презентации есть C++-примеры, в правило добавьте строку
`$(wildcard presentations/<NN-name>/*.cpp)` (образец — `02-c-vs-cpp.pdf`).

Общие зависимости (шаблоны, изображения) уже в правиле `*.pdf` — их
дублировать не нужно.

## 3. Сборка

- Одна цель (отладка): `nix develop --command make <NN-name>.pdf`
- Все цели: `nix develop --command make`
- Лог сборки: `build/<NN-name>.log` (out_dir задан в `.latexmkrc`)
- Финальная проверка: `nix build` → убедиться, что
  `result/presentations/<NN-name>.pdf` существует и не пуст.
  Перед ней — `git add presentations/<NN-name>/`: flake копирует в
  песочницу только отслеживаемые git-файлы, untracked-файлы в `nix
  build` невидимы (коммит при этом не нужен). Стейджинг делает pm;
  прочие git-команды субагенты не запускают — сессия на них зависает.

## 4. Частые ошибки

- `Undefined control sequence` / `Environment terminalwindow undefined` —
  не подключён пакет `terminal`/`mylisting` в `.tex`.
- `Environment myitemize undefined` — не подключён пакет `myitemize`.
- `Package minted Error: ... file not found` — неверный путь в
  `\myinputlisting` (указывается от корня проекта, не от директории `.tex`).
- Minted/verbatim-проблемы внутри фрейма — не стоит опция `[fragile]`.
- `make: *** No rule to make target '<NN-name>.pdf'` — цель не добавлена
  в Makefile.
- `nix build` не видит новый pdf — цель не добавлена в `install`.
- `make: *** No rule to make target 'presentations/<NN-name>/<name>.tex'`
  только в `nix build` (в `nix develop` всё собирается) — новые файлы
  untracked: сделать `git add presentations/<NN-name>/` (стейджинг) и
  повторить `nix build`.
