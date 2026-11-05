---
name: luatex-presentation
description: Skill for writing and editing LuaTex presentations in this project
---

This skill extends common rules for documents for all types from skill
`luatex-document` and specifies these rules for presentation documents
category.
It extends, not replaces: if `luatex-document` is not loaded in this
session yet, load it via the `skill` tool before applying this skill.

# When to use

When in need to create new LuaTeX presentation or change existing one.

# Add new presentation

- Every presentation must have a number.
  Numbers represent the order in which documents are read.
  First number is `01`, then `02`, `03`, etc.
  The project does not support more than 100 documents.

- Each presentation gets its own subfolder in `presentations`.
  The `.tex` file lives inside that subfolder with the same
  name.
  Example: `presentations/01-cmake/01-cmake.tex`.

- Every presentation gets its own rule in `Makefile`.
  The generic `%.pdf: presentations/%.tex` pattern rule does
  not match files inside subfolders, so a dedicated target
  with prerequisites and a `$(call generate_pdf,$<,$@)`
  recipe is required.
  Also add entries to the `build`, `help` and `install`
  targets.
  See the "Add new document" section of the
  `luatex-document` skill for the full recipe.

- Presentations must be installed to `$(PREFIX)/presentations/` folder.

- Every presentation starts with the STANDARD PREAMBLE below, copied
  as is (only the `\makeatletter` block prefix and `\title` are
  document-specific):
  ```tex
  \documentclass[compress, 8pt, aspectratio=169]{beamer}

  \usepackage{presentationtemplate}
  \usepackage[fontsize=\small,linenosfontsize=\tiny,askip=3mm]
    {mylisting}
  \usepackage[fontsize=\small,askip=3mm]{terminal}
  \usepackage{textcomp}
  \usepackage[autostyle=true]{csquotes}

  \title{Название презентации}

  \makeatletter
  \newdimen\cm@FVleftmargin
  \let\cm@FVSetupFont\FV@SetupFont
  \def\FV@SetupFont{%
    \cm@FVleftmargin=\leftmargin
    \cm@FVSetupFont
    \let\leftmargin\cm@FVleftmargin}
  \makeatother
  ```
  - Beamer, 16:9 aspect ratio and 8pt base font size are mandatory.
    If content frequently does not fit the slides, change the base
    font size via the `documentclass` option rather than shrinking
    individual frames.
  - `\small` is the standard size of code listings and terminal
    windows.
    Shrink a single overflowing listing with a local minted option
    (`fontsize=\footnotesize` inside `minted options`) instead of
    changing the package option.
  - The `\makeatletter ... \makeatother` block is part of the
    standard preamble, NOT a local hack: it preserves the frame
    `\leftmargin` around minted content.
    Use a document-specific 2-3 letter prefix (`\cm@`, `\cc@`, ...)
    rather than the `\gm@` from the reference repo.
  - If several footnotes share one base URL, define it once after
    `\title` (`\newcommand{\urlbase}{https://...}`) and reuse it
    in all `\footnotetext` calls.

- The presentation sets only its name via `\title`.
  Do not override `\subtitle` from the template.
  Do not use `\setbeamertemplate`, `\setbeamerfont` or local
  `\setlength` hacks in the presentation — all beamer customization
  (title page, frame title font, footnote style, spacing) lives in
  `presentationtemplate.sty`.
  The only allowed preamble additions beyond the standard block are
  document-specific `\newcommand` definitions.
  The frame title font size must be identical in all presentations:
  if a title does not fit, shorten the title, do not shrink the font.

# Writing presentations

- Keep text as short as possible.
  Most of the presentation content should be code listings
  with examples and terminal windows.

- Keep frame titles short: a few words, not a full sentence.

- Use russian language.
  Presentations are for Russian natives.

- Use other presentations as references (if there are any) when in doubt.
  They may have manual fixes which user added manually.
  The reference repository
  <https://github.com/cppdevcourse/documents> (its presentations,
  packages and `new-presentation` skill) is the primary reference
  for conventions.

- When in need to list several homogeneous ideas use `itemize` environment.
  Do not use `itemize` if ideas/sentences are not strictly homogeneous:
  present such material as plain text (a sequence of sentences) instead.
  Good:
  ```tex
  Object property:
  \begin{itemize}
    \item identifier
    \item type
  \end{itemize}
  ```
  Bad:
  ```tex
  \begin{itemize}
    \item C language was created in 1972 ...
    \item C language does not have classes ...
  \end{itemize}
  ```

- Use `fragile` for frames when using code listings and terminal windows.

- Separate blocks on a frame (text and listing, listing and terminal
  window, ...) with `\bigbreak` (a LaTeX kernel command, no package
  needed).
  Never use ad hoc `\vspace{...}` values.

- Overfulls are not allowed (check `Validating presentations` below)

- Adjust text size in text, code listings and terminal windows so it fits
  the frame.
  Body text must not be smaller than `\small`.
  Code listings and terminal windows use `\small` via package options
  (see "Add new presentation" above); shrink a single listing with a
  local minted `fontsize` option only when it does not fit.
  If it does not fit, split frame in two.

- Frame content must not touch the bottom edge of the slide:
  there must be a visible margin between the last content line and
  the frame number.
  If content reaches the edge, reduce the font size or split the frame.

- When adding footnotes, use separate `\footnotemark{}` and
  `\footnotetext{...}`.
  Never write footnote numbers by hand: no optional argument,
  numbering must be automatic.
- A footnote mark must be attached to a word: the word in the text
  (or in the frame title) the footnote refers to.
  A mark inside the frame title is allowed:
  ```tex
  \begin{frame}[fragile]{Объявления в C\footnotemark{}
    \footnotetext{\url{https://en.cppreference.com/w/c/language/declarations}}}
  ```
  Attaching the mark to a code listing is forbidden (the number
  ends up under the listing), and the mark must not float in empty
  space (e.g. on its own line at the end of the frame).
- Footnote text must contain no title or commentary —
  the URL itself is enough: `\footnotetext{\url{https://...}}`.
  Write each URL on one source line (keep it under 100 characters;
  a line break inside `\url{...}` inserts a space into the URL).
  If several footnotes share one base URL, define it once in the
  preamble and reuse it (see "Add new presentation").

- Columns must be top-aligned: `\begin{columns}[T]`.
  The standard column width is `0.48\textwidth`.

- Tables must have visible borders: column separators (`|`) and
  horizontal rules (`\hline`) at the top and bottom of the table
  and under the header row.
  Set row spacing with `\renewcommand{\arraystretch}{1.5}` and use
  `p{<width>cm}` columns for text cells:
  ```tex
  \begin{table}[h]

    \begin{center}

      \renewcommand{\arraystretch}{1.5}

      \begin{tabular}{|p{2.0cm}|p{3.4cm}|p{6.8cm}|}

        \hline

        \textbf{Тип} & \textbf{Размер} & \textbf{Пример} \\

        \hline

        ...

        \hline

      \end{tabular}

    \end{center}

  \end{table}
  ```

- A listing that does not fit a frame is split across two frames
  with the SAME title.
  The first part uses `lastline=<N>` in the minted options and ends
  with `\textit{To be continued \dots}`; the second part starts with
  `\textit{\dots continued}` followed by `\bigbreak` and uses
  `firstline=<N+1>`:
  ```tex
  \myinputlisting[minted language=c,
    minted options={fontsize=\small,breaklines,breakanywhere,
    linenos,numbersep=2pt,lastline=14}]
    {presentations/05-memory/src/}
    {example-03.c}

  \textit{To be continued \dots}
  ```

- In terminal windows every shell command line is
  `!\shellcommand{...}!`; output lines are plain text.
  Arguments that contain spaces or special characters are wrapped
  in single quotes: `!\shellcommand{gcc -o calc calc.c -DMSG='hello world'}!`.
  Long paths in the output are abbreviated with `!\dots!`:
  `cd !\dots!/src`.

- Typography (see also `luatex-document`): use `\enquote{}` for
  quotes, `---` for dash, `\dots` for ellipsis.
  Never use symbols that cannot be typed on a common keyboard
  (`—`, `«»`, `…`, curly quotes): the `check-style.sh` check in
  "Validating presentations" rejects them.

- Slides without title are forbidden.

## Tasks

- Project has designated package for rendering tasks for students
  (`packages/mytask.sty`).
  Use the `mytask` environment to give a task on the frame.
  Edit this file only in great need as it potentially affects all other documents.
  You must ask for user's approval if change is to be applied to a package.
  Example:
  ```tex
  \begin{mytask}
  Сделайте рефакторинг этого метода.
  \end{mytask}
  ```

# Validating presentations

All validation instruments must be executed within the `nix develop` environment.
After running `nix develop --command make <NAME>.pdf`,
perform these automated checks to ensure the presentation is flawless.

## Request payload budget (mandatory, read first)

The LLM gateway rejects any request body larger than ~1 MiB with
HTTP 413, and the session dies with a retry loop. The ENTIRE
conversation history — including every image ever read — is re-sent
to the provider on every single step, so large tool outputs are
expensive forever, not just once:

- Never read a whole build log, `/tmp/opencode/fit.txt`, or any other
  large file into the context. Use `tail`/`grep`/`sed -n` windows only.
- Never render or read all pages of the deck as PNGs.
  Read at most 1-2 page images per check round,
  and only pages that were changed or flagged.
- Every command that can print more than a few KB of output
  (builds, `nix` commands, whole-deck `pdftotext`) must be redirected
  to a file in `/tmp/opencode/` first (see `build` skill).
- If a step fails with HTTP 413 (Payload Too Large), the session
  history is already over the limit: do not retry in the same
  session — report to the PM; a fresh subagent session with a
  compact prompt continues the work.

## Checks

1. Check for Horizontal Text Overflow (Overfull lines):
    Run the following command to detect if text or code goes past the right margin.
    If it returns lines, you must wrap the text or reduce the font size
    (but no smaller than `\small`).
    ```shell
    grep -n "Overfull \\hbox" build/<NAME>.log
    ```

2. Check for Code Line Wrapping (mandatory, mechanical):
    Minted with `breaklines` wraps long lines SILENTLY: no Overfull
    appears in the log, so check 1 cannot catch this.
    Run the bundled script — it prints ONLY the violating lines:
    ```shell
    nix develop --command pdftotext -layout build/<NAME>.pdf /tmp/opencode/fit.txt
    nix develop --command sh .opencode/skills/luatex-presentation/scripts/check-listings.sh <NAME>
    ```
    Each printed line `file:line: content` is a source line that is
    wrapped or clipped in the PDF: reduce the listing font size or
    split the listing/frame, rebuild, and re-run the script.
    Do NOT read `/tmp/opencode/fit.txt` into the context.
    If a reported line is a false positive, inspect a 10-line window
    around the listing with `sed -n 'N,Mp' /tmp/opencode/fit.txt`
    to see what happened.

3. Check PDF Metadata & Page Count:
    Verify that the document compiled with the correct geometry and that the
    page count matches expectations:
    ```shell
    pdfinfo build/<NAME>.pdf
    ```

4. Check that code listings come from source files:
    All code listings must use `myinputlisting` with source files in the
    document's `src/` folder.
    In-place listings (`myinplacelisting`, `mytitledinplacelisting`) are
    only allowed for fragments which cannot exist as real files
    (broken or commented-out code).
    ```shell
    grep -n "myinplacelisting\|mytitledinplacelisting" presentations/<NAME>/<NAME>.tex
    ```
    If it returns lines, move the code to `src/` files and switch frames
    to `myinputlisting`, or explain in a comment why in-place is required.

5. Check source line width:
    LaTeX source lines must stay under 100 characters.
    ```shell
    awk 'length($0) > 100 { print FILENAME ": " FNR }' presentations/<NAME>/<NAME>.tex
    ```
    If it returns lines, wrap them.

6. Check bottom margin (mechanical):
    Frame content must not touch the bottom edge of the slide
    (there must be a visible margin before the frame number).
    The bundled script measures word coordinates via `pdftotext -bbox`
    and prints ONLY the pages where content is under 6pt above the
    frame-number line (or intrudes into its strip):
    ```shell
    nix develop --command sh .opencode/skills/luatex-presentation/scripts/check-bottom-margin.sh <NAME>
    ```
    If it prints pages, render ONLY the flagged pages and inspect them:
    ```shell
    nix develop --command pdftoppm -png -r 80 -f <N> -l <N> build/<NAME>.pdf /tmp/opencode/bottom-N
    ```
    Read at most 1-2 of these images.
    If content touches the edge, reduce the font size or split the
    frame, rebuild, and re-run the script.
    Never render all pages of the deck.

7. Check house style (mandatory, mechanical):
    Run the bundled script — it prints ONLY the violations:
    ```shell
    nix develop --command sh .opencode/skills/luatex-presentation/scripts/check-style.sh <NAME>
    ```
    It checks the standard preamble (`8pt`, `aspectratio=169`,
    `fontsize=\small`, `FV@SetupFont` block), non-keyboard symbols,
    literal `...`, bare `$` prompts in terminal windows, and the
    `lastline`/`firstline` pairing of split listings.
    Fix every reported line (rebuild if needed) and re-run until
    it prints `OK`.
