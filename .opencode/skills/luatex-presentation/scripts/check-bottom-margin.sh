#!/bin/sh
# check-bottom-margin.sh <NAME> [PDF]
#
# Mechanical bottom-margin check: frame content must not touch the
# bottom edge of the slide (a visible margin before the frame number
# is required). The script uses pdftotext -bbox word coordinates, so
# no page rendering / visual inspection is needed for the first pass.
#
# For each page:
#   - the frame-number line ("N / TOTAL") lives in the bottom strip
#     (word top below page_height - 10pt) and consists only of digits
#     and slashes;
#   - any other text inside that strip means content intruded into
#     the frame-number area (flagged);
#   - the gap between the lowest content word and the frame-number
#     line is flagged when it is under 6pt.
#     (Footnotes sit ~8pt above the frame number by design and
#     do not trigger the check.)
#
# Usage (from the project root, inside nix develop):
#   nix develop --command sh .opencode/skills/luatex-presentation/scripts/check-bottom-margin.sh <NAME>
#
# Output: one line per flagged page.
# Exit codes: 0 = no flagged pages, 1 = at least one page flagged, 2 = usage error.
set -u
NAME=${1:-}
PDF=${2:-}
[ -n "$NAME" ] || { echo "usage: check-bottom-margin.sh <NAME> [PDF]" >&2; exit 2; }
[ -n "$PDF" ] || PDF="build/$NAME.pdf"
[ -r "$PDF" ] || { echo "error: $PDF is not readable; build it first" >&2; exit 2; }
TMP=$(mktemp) || exit 2
trap 'rm -f "$TMP"' EXIT
pdftotext -bbox -enc UTF-8 "$PDF" "$TMP"
awk '
  /<page / {
    if (pn > 0) report()
    pn++
    match($0, /height="[0-9.]+"/); h = substr($0, RSTART + 8, RLENGTH - 9) + 0
    maxy = 0; footy = 0; intrad = 0
    next
  }
  /<word / {
    match($0, /yMin="[0-9.]+"/); ymin = substr($0, RSTART + 6, RLENGTH - 7) + 0
    match($0, /yMax="[0-9.]+"/); ymax = substr($0, RSTART + 6, RLENGTH - 7) + 0
    match($0, />[^<]*<\/word>/); txt = substr($0, RSTART + 1, RLENGTH - 8)
    if (ymin > h - 10) {
      if (txt ~ /^[0-9\/]+$/) { if (ymax > footy) footy = ymax }
      else if (ymax > intrad) intrad = ymax
    } else if (ymax > maxy) {
      maxy = ymax
    }
    next
  }
  function report() {
    if (maxy == 0 && intrad == 0) return
    ref = (footy > 0) ? footy : h
    gap = ref - maxy
    if (intrad > 0) {
      printf "page %d: text inside frame-number strip (bottom %.2fpt, strip from %.2fpt)\n", pn, intrad, h - 10
      flagged++
    } else if (gap < 6) {
      printf "page %d: content bottom %.2fpt, frame number %.2fpt, gap %.2fpt (< 6pt)\n", pn, maxy, ref, gap
      flagged++
    }
  }
  END { if (pn > 0) report(); exit (flagged > 0) ? 1 : 0 }
' "$TMP"
