#!/bin/sh
# check-style.sh <NAME> [TEX]
#
# Mechanical house-style check for presentations/<NAME>/<NAME>.tex.
# Catches the deviations the user had to fix manually after the
# first LLM generation (see the "Add new presentation" and
# "Writing presentations" sections of the luatex-presentation skill):
#
#   1. standard preamble: \documentclass[compress, 8pt, aspectratio=169]{beamer}
#      appears exactly once and the FV@SetupFont left-margin
#      preservation block is present;
#   2. mylisting/terminal are loaded with fontsize=\small
#      (fontsize=\footnotesize is allowed only as a LOCAL minted
#      option of a single overflowing listing, not as package option);
#   3. no symbols that cannot be typed on a common keyboard
#      (dash, guillemets, curly quotes, ellipsis, ...);
#   4. no literal "..." (write \dots);
#   5. no bare "$" prompt inside terminalwindow: every command line
#      must be !\shellcommand{...}! inside a !...! escape region;
#   6. split listings: every lastline=N is paired with firstline=N+1,
#      and the parts are labeled with "To be continued \dots" /
#      "\dots continued" (one label per part).
#
# Usage (from the project root, inside nix develop):
#   sh .opencode/skills/luatex-presentation/scripts/check-style.sh <NAME> [TEX]
#
# Output: one section per violation.
# Exit codes: 0 = no violations, 1 = violations found, 2 = usage error.
set -u
NAME=${1:-}
[ -n "$NAME" ] || { echo "usage: check-style.sh <NAME> [TEX]" >&2; exit 2; }
TEX=${2:-}
if [ -z "$TEX" ]; then
  TEX="presentations/$NAME/$NAME.tex"
  if [ ! -r "$TEX" ]; then
    # legacy layout: the .tex file name differs from the folder name,
    # e.g. presentations/01-intro/intro.tex — accept a unique match
    set -- $(ls presentations/"$NAME"/*.tex 2>/dev/null)
    if [ "$#" -eq 1 ]; then
      TEX=$1
    else
      echo "error: no unique presentations/$NAME/*.tex found" >&2
      exit 2
    fi
  fi
fi
[ -r "$TEX" ] || { echo "error: $TEX not found" >&2; exit 2; }
fails=0
sec() { printf -- '--- %s\n' "$1"; }
show() { [ -n "$1" ] && printf '%s\n' "$1"; return 0; }

# 1a. standard documentclass line, exactly once
n=$(grep -c 'documentclass\[compress, 8pt, aspectratio=169\]{beamer}' "$TEX")
if [ "$n" -ne 1 ]; then
  sec "preamble: \\documentclass[compress, 8pt, aspectratio=169]{beamer} expected exactly once, found $n"
  fails=1
fi

# 1b. FV@SetupFont left-margin block
if ! grep -q 'FV@SetupFont' "$TEX"; then
  sec "preamble: FV@SetupFont left-margin block is missing (standard preamble)"
  fails=1
fi

# 2. no fontsize=\footnotesize as a package option
out=$(grep -n 'usepackage\[fontsize=\\footnotesize' "$TEX")
if [ -n "$out" ]; then
  sec "package options: fontsize=\\footnotesize in \\usepackage (house style is fontsize=\\small; a local minted fontsize is allowed only on a single overflowing listing)"
  show "$out"
  fails=1
fi

# 3. non-keyboard symbols: em dash, en dash, guillemets, curly quotes,
#    ellipsis (byte-wise match, locale independent)
out=$(grep -n '—\|–\|«\|»\|“\|”\|‘\|’\|…' "$TEX")
if [ -n "$out" ]; then
  sec "typography: symbol not typeable on a common keyboard (use --- for dash, \\enquote{} for quotes, \\dots for ellipsis)"
  show "$out"
  fails=1
fi

# 4. literal three dots
out=$(grep -n '\.\.\.' "$TEX")
if [ -n "$out" ]; then
  sec "typography: literal '...' (write \\dots)"
  show "$out"
  fails=1
fi

# 5. bare "$" prompt inside terminalwindow
out=$(awk '
  /\\begin\{terminalwindow\}/ { t = 1; next }
  /\\end\{terminalwindow\}/   { t = 0 }
  t && /^[ \t]*\$/            { printf "%d: %s\n", FNR, $0 }
' "$TEX")
if [ -n "$out" ]; then
  sec "terminal: bare \$ prompt (every command line must be !\\shellcommand{...}! inside a !...! escape region)"
  show "$out"
  fails=1
fi

# 6. split listings: lastline=N <-> firstline=N+1 pairing
lasts=$(grep -o 'lastline=[0-9]\+' "$TEX" | sed 's/lastline=//')
firsts=$(grep -o 'firstline=[0-9]\+' "$TEX" | sed 's/firstline=//')
if [ -n "$lasts" ] || [ -n "$firsts" ]; then
  for n in $lasts; do
    if ! printf '%s\n' "$firsts" | grep -qx "$((n + 1))"; then
      sec "split listing: lastline=$n has no firstline=$((n + 1)) continuation frame"
      fails=1
    fi
  done
  for m in $firsts; do
    if ! printf '%s\n' "$lasts" | grep -qx "$((m - 1))"; then
      sec "split listing: firstline=$m has no lastline=$((m - 1)) start frame"
      fails=1
    fi
  done
  ns=$(grep -c 'lastline=' "$TEX")
  nt=$(grep -c 'To be continued' "$TEX")
  if [ "$ns" -ne "$nt" ]; then
    sec "split listing: lastline= frames ($ns) and 'To be continued' labels ($nt) counts differ"
    fails=1
  fi
  nf=$(grep -c 'firstline=' "$TEX")
  nl=$(grep -c 'dots continued}' "$TEX")
  if [ "$nf" -ne "$nl" ]; then
    sec "split listing: firstline= frames ($nf) and '\\dots continued' labels ($nl) counts differ"
    fails=1
  fi
fi

if [ "$fails" -eq 0 ]; then
  echo "OK: $TEX passed style checks"
  exit 0
fi
echo "FAIL: style violations in $TEX (see above)"
exit 1
