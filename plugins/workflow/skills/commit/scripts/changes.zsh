#!/usr/bin/env zsh
# Tree-style view of staged changes with right-aligned colored stats.

setopt pipe_fail

dim=$'\033[2m'
grn=$'\033[32m'
red=$'\033[31m'
rst=$'\033[0m'

local numstat=$(git diff --staged --numstat)
[[ -z "$numstat" ]] && print "${dim}No staged changes.${rst}" && return 1

# Build stat lookup per filepath
typeset -A stats vlens
while IFS=$'\t' read -r a d f; do
  local s="" v=0
  [[ "$a" != "0" && "$a" != "-" ]] && s="${grn}+${a}${rst}" && v=$((v + ${#a} + 1))
  if [[ "$d" != "0" && "$d" != "-" ]]; then
    [[ -n "$s" ]] && s="${s} ${dim}/${rst} " && v=$((v + 3))
    s="${s}${red}-${d}${rst}" && v=$((v + ${#d} + 1))
  fi
  stats[$f]="$s"
  vlens[$f]="$v"
done <<<"$numstat"

# Mirror paths in temp dir, run tree
local tmpdir=$(mktemp -d)
trap "rm -rf $tmpdir" EXIT

for f in ${(k)stats}; do
  mkdir -p "${tmpdir}/${f:h}"
  touch "${tmpdir}/${f}"
done

local tree=$(tree -a -f --noreport --charset utf-8 "$tmpdir" | tail -n +2)

# First pass: parse lines, find max width
local -a rows keys
local max_w=0 raw rel key base row

while IFS= read -r line; do
  raw="${line##*── }"
  raw="${raw##*─ }"
  rel="${raw#${tmpdir}/}"
  key=""
  [[ -n "${stats[$rel]:-}" ]] && key="$rel"
  base="${rel:t}"
  [[ "$line" == *"── "* ]] && row="${line%%── *}── ${base}" || row="$line"
  rows+=("$row")
  keys+=("$key")
  ((${#row} > max_w)) && max_w=${#row}
done <<<"$tree"

# Second pass: render with right-aligned stats
print ""
for ((i = 1; i <= ${#rows}; i++)); do
  if [[ -n "${keys[$i]}" ]]; then
    local k="${keys[$i]}"
    local dw=$((max_w - ${#rows[$i]} + 12 - vlens[$k]))
    local dots=$(printf '%*s' $dw '' | tr ' ' '·')
    local pfx="${rows[$i]%%── *}── "
    local name="${rows[$i]#*── }"
    print "${dim}${pfx}${rst}${name} ${dim}${dots}${rst} ${stats[$k]}"
  else
    print "${dim}${rows[$i]}${rst}"
  fi
done
print ""
