---
name: luatex-document
description: Skill for writing and editing LuaTex document in this project
---

# When to use

When in need to create new LuaTeX document or change existing one.

# Add new document

When adding new document (say, `<NAME>.pdf`) follow these rules:

- All documents must have a number.
  Numbers represent sequence in which documents will be read.
  First number is `01`, then follows `02`, `03`, etc.
  This project does not support more than 100 documents in same sequence.

- New documents must be created in designated folder which consists of:
  * folder for document category, e.g. `presentations/`;
  * folder for document itself within category, e.g. `01-cmake/`.
  Example of new document: `presentations/01-cmake/01-cmake.tex`.

  *Note: the only supported category is 'presentations'. This may or may not
  change in the future.*

- All build instructions must be added to `Makefile`, this is the one
  and only source for build system in this project.

- Recipes must begin with a literal TAB character.
  In examples below spaces are used.

- Target of the new rule must match name of the presentation except for
  extension. Example: `01-cmake.tex` -> `01-cmake.pdf`.

- Add new target to rule `build` as prerequisite in Makefile.
  Example:
  ```make
  build: \
    # ...
  	01-cmake.pdf # <-- new document
  ```

- Add building new target to `help` target recipe in Makefile.
  Example:
  ```make
  help:
  	@printf "all\tbuild all documents\n"
    # ...
  	@printf "01-cmake.pdf\tbuild presentation 01-cmake.pdf\n" # <-- new document
  ```

- Add installing new target to `install` target recipe.
  You must install document in the appropriate subfolder for document category.
  Example:
  ```make
  install: build
  	mkdir -p "$(PREFIX)/presentations"
    # ...
  	cp "$(BUILD_DIR)/01-cmake.pdf" "$(PREFIX)/presentations/01-cmake.pdf"
  ```

- Rule for new document must have source *.tex file itself and any other files
  it includes/imports as prerequisites.
  Note, that some common used files are already listed in rule for target `*.pdf`.
  Example:
  ```make
  01-cmake.pdf: \
  	presentations/01-cmake/01-cmake.tex \
  	$(wildcard presentations/01-cmake/src/*.c) \
  	$(wildcard presentations/01-cmake/src/*.h)
    # ... recipe
  ```

- Recipe for new rule must be call to `generate_pdf` function defined in
  Makefile.
  Example:
  ```make
  01-cmake.pdf: \
    # ... prerequisites
  	$(call generate_pdf,$<,$@)
  ```

# Writing rules

When writing or changing LuaTeX code follow this rules:

- Category specific rules are described in skill for appropriate
  document category (i.e. `luatex-presentation`).

- Keep LaTeX lines under width of 80-100 characters.

- Each category folder has its template file.
  You must use it.
  Example:
  ```tex
  \usepackage{presentationtemplate}
  ```
  Edit this file only in great need as it potentially affects all other documents.
  You must ask for user's approval if change is to be applied to a template.

- Use 4 spaces for identation.

- Each sentence in LuaTeX source file must start with newline (not in render,
  only in *.tex file).

- Add newlines between LaTeX control statements.
  Example:
  ```tex
  \begin{itemize}

    \item My item 1...

    \item My item 2...

  \end{itemize}
  ```

## Fonts

- Use only fonts from `fonts/` directory.
  When in need to use new font you must download it to this folder
  and add them to Makefile as prerequisites.

- This also applies to emoji.
  You will find them in `fonts/AppleColorEmoji.ttf`.

## Code listings

- For all code listings you must use package `packages/mylisting.sty`.
  Commands and environments are defined there.
  Edit this file only in great need as it potentially affects all other documents.
  You must ask for user's approval if change is to be applied to a package.

- Use `myinplacelisting` when you need to add short code example which
  potentially will not compile or has commented-out parts.
  You must provide option `minted language` to use this environment.
  Example:
  ```tex
  \begin{myinplacelisting}[minted language=c]
  % code ...
  \end{myinplacelisting}
  ```

- Use `mytitledinplacelisting` when you need `myinplacelisting` but with the
  title in footer.
  Example:
  ```tex
  \begin{mytitledinplacelisting}[minted language=c]{Пример с кодом возврата}
  % code
  \end{mytitledinplacelisting}
  ```

- Use `myinputlisting` when you will rather put code in separate file.
  Prefer this option over `myinplacelisting` and `mytitledinplacelisting`
  as it has several benefits:
  - keeps *.tex file short;
  - allows to validate code more easily.
  It takes 2 mandatory parameters in curly braces.
  Concatenated, they represent the relative path to the source file in this repo.
  The second parameter (`#3`) is automatically processed via `\detokenize`
  and used as the listing title in the footer.
  It has option `minted language`, always use it.
  Example:
  ```tex
  \myinputlisting[minted language=cmake]
      {presentations/01-cmake/src/}
      {compile-options/CMakeLists.txt}
  ```

- Place sources for `myinputlisting` in `src/` folder in document directory.
  Example: `presentations/01-cmake/src/compile-options/CMakeLists.txt`

## Terminal windows

- Project has designated package for rendering terminal emulator
  windows (`packages/terminal.sty`).
  Use the `terminalwindow` environment for terminal sessions.
  Edit this file only in great need as it potentially affects all other documents.
  You must ask for user's approval if change is to be applied to a package.

- Every shell command in a terminal session MUST be rendered with
  `\shellcommand{...}` from the same package:
  it adds the prompt automatically and makes the command bold.
  `terminalwindow` is a minted listing, so the macro must be placed
  inside the escape region `!...!` (both delimiters are `!`).
  A plain `$` character as a text prompt is forbidden:
  it is not bold and it is not the prompt macro.
  Example:
  ```tex
  \begin{terminalwindow}
  !\shellcommand{./build.sh}!
  !\shellcommand{./calc}!
  2 + 3 = 5
  \end{terminalwindow}
  ```

- When a bare prompt (without a command) is needed, use
  `\shellprompt` from the same package, also inside `!...!`.
