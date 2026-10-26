---
name: new-presentation
description: Рецепт добавления новой презентации в psds-c-docs — структура beamer-источника, подключение к Makefile (build/help/install), сборка через make в nix develop и финальная проверка nix build. Use when creating, adding or updating a presentation, editing its Makefile targets, or debugging the pdf build.
---

# Новая презентация psds-c-docs

## 1. Каркас

Директория `presentations/<NN-name>/` (NN — следующий номер серии,
имя — kebab-case), основной файл `<name>.tex`. Образец:
`presentations/01-intro/intro.tex`.

Структура `.tex`:

- `\documentclass[compress]{beamer}`
- `\usepackage{presentationtemplate}` — шрифты, логотипы, автор, дата
  уже заданы в шаблоне; повторно объявлять нельзя
- `\usepackage[fontsize=\footnotesize, askip=3mm]{terminal}` и
  `\usepackage[fontsize=\footnotesize, linenosfontsize=\tiny, askip=3mm]{mylisting}`
  — только если в презентации есть примеры/терминал
- `\subtitle{...}` — переопределяет подзаголовок по умолчанию из шаблона
- Фреймы `\begin{frame}[...]{...}\frametitle{...}\end{frame}`;
  фреймы с кодом — обязательная опция `[fragile]`

Примеры кода:

- Файловый пример: файл `presentations/<NN-name>/<file>.c` (или `.h`) и
  `\myinputlisting[minted language=c]{presentations/<NN-name>}/<file>.c`
  — путь от корня проекта (первый аргумент — каталог, второй — имя файла).
- Короткий фрагмент: `\myinplacelisting[minted language=c]{...код...}`
- Запуск программы: окружение `terminalwindow`, команды
  `\shellcommand{gcc file.c}` и т.п. (escape-последовательность `||`).

C-код во всех примерах должен быть корректным и компилируемым gcc.

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

Общие зависимости (шаблоны, изображения) уже в правиле `*.pdf` — их
дублировать не нужно.

## 3. Сборка

- Одна цель (отладка): `nix develop --command make <NN-name>.pdf`
- Все цели: `nix develop --command make`
- Лог сборки: `build/<NN-name>.log` (out_dir задан в `.latexmkrc`)
- Финальная проверка: `nix build` → убедиться, что
  `result/presentations/<NN-name>.pdf` существует и не пуст.

## 4. Частые ошибки

- `Undefined control sequence` / `Environment terminalwindow undefined` —
  не подключён пакет `terminal`/`mylisting` в `.tex`.
- `Package minted Error: ... file not found` — неверный путь в
  `\myinputlisting` (указывается от корня проекта, не от директории `.tex`).
- Minted/verbatim-проблемы внутри фрейма — не стоит опция `[fragile]`.
- `make: *** No rule to make target '<NN-name>.pdf'` — цель не добавлена
  в Makefile.
- `nix build` не видит новый pdf — цель не добавлена в `install`.
