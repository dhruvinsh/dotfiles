#!/usr/bin/env bash
# Toggle wlogout: full-screen blurred overlay, button row centered on the focused monitor.

if pgrep -x wlogout >/dev/null; then
  pkill -x wlogout
  exit 0
fi

CARD=210 # button size, logical px (square)
GAP=28   # spacing between buttons
COUNT=5  # buttons in the single row

width=1920
height=1080
if command -v hyprctl >/dev/null && command -v jq >/dev/null; then
  read -r w h < <(hyprctl -j monitors | jq -r '(map(select(.focused)) + .)[0] | "\(.width / .scale | floor) \(.height / .scale | floor)"')
  [[ -n ${w:-} && -n ${h:-} ]] && width=$w height=$h
fi

group=$((CARD * COUNT + GAP * (COUNT - 1)))
side=$(((width - group) / 2))
vert=$(((height - CARD) / 2))
((side < 0)) && side=0
((vert < 0)) && vert=0

exec wlogout \
  -C "$HOME/.config/wlogout/style.css" \
  -l "$HOME/.config/wlogout/layout" \
  --protocol layer-shell \
  -b "$COUNT" -c "$GAP" -r "$GAP" \
  -L "$side" -R "$side" -T "$vert" -B "$vert"
