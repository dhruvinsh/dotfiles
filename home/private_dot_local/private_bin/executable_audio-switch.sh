#!/usr/bin/env bash
# Pick the default audio sink with rofi; move existing streams to it.
set -euo pipefail

sinks=$(pactl -f json list sinks)
default=$(pactl get-default-sink)

if [[ "$(jq 'length' <<<"$sinks")" -eq 0 ]]; then
  notify-send -a audio-switch "Audio output" "No sinks available"
  exit 1
fi

menu=$(jq -r --arg def "$default" \
  '.[] | (if .name == $def then "● " else "  " end) + .description' <<<"$sinks")

choice=$(printf '%s\n' "$menu" | rofi -dmenu -i -p "Output" || true)
[[ -z "$choice" ]] && exit 0

desc=${choice#"● "}
desc=${desc#"  "}
name=$(jq -r --arg d "$desc" 'first(.[] | select(.description == $d) | .name) // empty' <<<"$sinks")
if [[ -z "$name" ]]; then
  notify-send -a audio-switch "Audio output" "Sink not found: $desc"
  exit 1
fi

pactl set-default-sink "$name"

while read -r input; do
  [[ -n "$input" ]] && pactl move-sink-input "$input" "$name" || true
done < <(pactl -f json list sink-inputs | jq -r '.[].index')

notify-send -a audio-switch "Audio output" "$desc"
