#!/usr/bin/env bash
# Now-playing line for hyprlock. Lives in a script because hyprlang parses
# "{{ ... }}" (playerctl's format syntax) as an arithmetic expression.
# Always prints something: an empty result shows hyprlock's default "Sample Text".

out=$(timeout 1 playerctl metadata --format '󰎆  {{ artist }} - {{ title }}' 2>/dev/null)
((${#out} > 80)) && out="${out:0:79}…"
printf '%s\n' "${out:- }"
