#!/usr/bin/env bash
# Polybar custom/script: default input state via wpctl (PipeWire).
# Usage: microphone.sh [unmuted-colour] [muted-colour]

on_color=${1:-#89dceb}
off_color=${2:-#f38ba8}

command -v wpctl >/dev/null 2>&1 || exit 0
out=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null) || exit 0

if [[ $out == *"[MUTED]"* ]]; then
  printf '%%{F%s}%%{T2}%s %%{T-}muted%%{F-}\n' "$off_color" $'\U000f036d'
else
  vol=$(awk '{printf "%d", $2 * 100}' <<<"$out")
  printf '%%{F%s}%%{T2}%s %%{T-}%%{F-}%s%%\n' "$on_color" $'\U000f036c' "$vol"
fi
