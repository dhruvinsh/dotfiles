#!/usr/bin/env bash

## Rofi Application Launcher

# Theme
theme="$HOME/.config/rofi/launchers/misc/launcher.rasi"

# Check if theme file exists, otherwise use default style
if [[ ! -f "$theme" ]]; then
  rofi -show drun \
    -display-drun "Applications:" \
    -drun-display-format "{name}" \
    -theme-str 'window {width: 600px;} listview {columns: 1; lines: 8;}'
else
  rofi -show drun \
    -display-drun "Applications:" \
    -drun-display-format "{name}" \
    -theme "$theme"
fi
