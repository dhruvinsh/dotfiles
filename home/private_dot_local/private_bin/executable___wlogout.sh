#!/usr/bin/env bash
A_1080=400
B_1080=400

# Check if wlogout is already running
if pgrep -x "wlogout" > /dev/null; then
    pkill -x "wlogout"
    exit 0
fi

# Detect monitor resolution and scaling factor
if command -v swaymsg &> /dev/null; then
    resolution=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused==true) | .rect.height / .scale' | awk -F'.' '{print $1}')
    scale=$(swaymsg -t get_outputs -r | jq -r '.[] | select(.focused==true) | .scale')
elif command -v hyprctl &> /dev/null; then
    resolution=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .height / .scale' | awk -F'.' '{print $1}')
    scale=$(hyprctl -j monitors | jq -r '.[] | select(.focused==true) | .scale')
else
    # fallback to a default resolution and scale
    resolution=1080
    scale=1.0
fi
wlogout -C "$HOME"/.config/wlogout/style.css -l "$HOME"/.config/wlogout/layout --protocol layer-shell -b 5 -T $(awk "BEGIN {printf \"%.0f\", $A_1080 * 1080 * $scale / $resolution}") -B $(awk "BEGIN {printf \"%.0f\", $B_1080 * 1080 * $scale / $resolution}")
