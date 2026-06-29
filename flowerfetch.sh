#!/usr/bin/env bash
# flowerfetch — the info is hugged on all sides by one connected floral piece:
#   [logo]   [top spray]                 <- directly above the text
#            [stem | info nuzzled in]     <- side floral down the left
#            [bottom spray]               <- directly below the text
set -euo pipefail

FF=/usr/bin/fastfetch
DIR="$HOME/.config/fastfetch"
RESET=$'\033[0m'
GREEN=$'\033[38;2;140;185;120m'
PURPLE=$'\033[38;2;175;120;225m'  # info text color
SEP_TXT_COL=7                     # column where info nests against the stem
STEM_START=9                      # first clean stem row in floral_sep.txt

strip() { sed 's/\x1b\[[0-9;]*m//g' <<<"$1"; }
vlen()  { local s; s=$(strip "$1"); printf '%s' "${#s}"; }
pad_to() { local s=$1 w=$2 v; v=$(vlen "$s"); printf '%s%*s' "$s" $(( w - v )) ''; }

mapfile -t INFO < <("$FF" --logo none 2>/dev/null)
mapfile -t LOGO < <(cat "$DIR/logo.txt")
mapfile -t SIDE < <(cat "$DIR/floral_sep.txt")
mapfile -t GTOP < <(cat "$DIR/garland_top.txt")
mapfile -t GBOT < <(cat "$DIR/garland_bot.txt")
n=${#INFO[@]}

# --- stem segment (exactly info height) with the info nuzzled against it ---
STEMINFO=()
for (( k=0; k<n; k++ )); do
  srow="${SIDE[STEM_START+k]:-}"
  STEMINFO+=( "${GREEN}${srow:0:SEP_TXT_COL}${RESET}${PURPLE}$(strip "${INFO[k]}")${RESET}" )
done

# --- stack: top spray, stem+info, bottom spray (one connected column) ---
MID=()
for l in "${GTOP[@]}"; do MID+=( "${GREEN}${l}${RESET}" ); done
MID+=( "${STEMINFO[@]}" )
total=${#MID[@]}

# --- logo & floral both vertically centered against the taller of the two ---
lw=0; for l in "${LOGO[@]}"; do v=$(vlen "$l"); (( v>lw )) && lw=$v; done
lr=${#LOGO[@]}
canvas=$total; (( lr>canvas )) && canvas=$lr
ltop=$(( (canvas - lr) / 2 ))
mtop=$(( (canvas - total) / 2 ))
GAP="  "

for (( i=0; i<canvas; i++ )); do
  li=$(( i - ltop ))
  if (( li>=0 && li<lr )); then logo=$(pad_to "${LOGO[li]}" "$lw"); else logo=$(printf '%*s' "$lw" ''); fi
  mi=$(( i - mtop ))
  mid=""; (( mi>=0 && mi<total )) && mid="${MID[mi]}"
  printf '%s%s%s%s%s%s\n' "$GREEN" "$logo" "$RESET" "$GAP" "$RESET" "$mid"
done
