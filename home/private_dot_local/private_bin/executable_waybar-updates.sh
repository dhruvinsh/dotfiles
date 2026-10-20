#!/usr/bin/env bash
# Emits Waybar JSON {text,tooltip,class} with pending pacman + AUR updates.
# Prints nothing-visible (empty text, class "none") when up to date.
set -uo pipefail

repo=$(checkupdates 2>/dev/null || true)
aur=""
if command -v yay >/dev/null 2>&1; then
  aur=$(yay -Qua 2>/dev/null || true)
fi

count_lines() {
  if [[ -z "$1" ]]; then echo 0; else printf '%s\n' "$1" | wc -l; fi
}

n_repo=$(count_lines "$repo")
n_aur=$(count_lines "$aur")
total=$((n_repo + n_aur))

if ((total == 0)); then
  printf '{"text":"","tooltip":"System is up to date","class":"none"}\n'
  exit 0
fi

class="pending"
((total >= 50)) && class="many"

tooltip="Repo: ${n_repo}  AUR: ${n_aur}"
list=$(printf '%s\n%s\n' "$repo" "$aur" | sed '/^$/d' | head -20)
tooltip+=$'\n\n'"$list"
if ((total > 20)); then
  tooltip+=$'\n'"... and $((total - 20)) more"
fi

jq -cn --arg text "󰚰 ${total}" --arg tooltip "$tooltip" --arg class "$class" \
  '{text: $text, tooltip: $tooltip, class: $class}'
