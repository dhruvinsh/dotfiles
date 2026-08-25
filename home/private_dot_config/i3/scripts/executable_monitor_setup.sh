#!/usr/bin/env bash
#
# i3 (X11) monitor layout. The display is driven by the iGPU; connected outputs:
#   DP-1   -> left,  non-primary (2560x1440)
#   HDMI-2 -> right, primary     (2560x1440)
# (On the old dGPU these ports enumerated as DP-6 / DP-4.)
#
# Layout is verified with:
#   xrandr --query | grep " connected"

MODE="2560x1440"

# Known desktop dual-monitor outputs (iGPU).
LEFT_OUT="DP-1"    # non-primary, left
RIGHT_OUT="HDMI-2" # primary, right

is_connected() {
  xrandr --query | grep -q "^$1 connected"
}

# Connected outputs, one per line. The leading space in the pattern skips
# "disconnected" entries (they read as "HDMI-1 disconnected").
mapfile -t MONITORS < <(xrandr --query | grep " connected" | cut -d' ' -f1)
MONITOR_COUNT=${#MONITORS[@]}

if is_connected "$LEFT_OUT" && is_connected "$RIGHT_OUT"; then
  # Known layout: DP-1 on the left, HDMI-2 primary on the right.
  xrandr --output "$LEFT_OUT" --mode "$MODE" --pos 0x0 \
    --output "$RIGHT_OUT" --mode "$MODE" --pos 2560x0 --primary
elif [ "$MONITOR_COUNT" -eq 2 ]; then
  # Generic dual-monitor fallback (unknown output names):
  # first listed on the right (primary), second on the left.
  xrandr --output "${MONITORS[1]}" --mode "$MODE" --pos 0x0 \
    --output "${MONITORS[0]}" --mode "$MODE" --pos 2560x0 --primary
elif [ "$MONITOR_COUNT" -eq 1 ]; then
  # Single monitor: best available mode, set as primary.
  xrandr --output "${MONITORS[0]}" --auto --primary
elif [ "$MONITOR_COUNT" -gt 2 ]; then
  # More than two monitors: use the first two, disable the rest.
  for monitor in "${MONITORS[@]:2}"; do
    xrandr --output "$monitor" --off
  done
  xrandr --output "${MONITORS[1]}" --mode "$MODE" --pos 0x0 \
    --output "${MONITORS[0]}" --mode "$MODE" --pos 2560x0 --primary
fi
