#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

# Wait until the processes have been shut down
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.5; done

# Detect the primary output (HDMI-2 on this machine); fall back to the first
# connected output if none is marked primary.
mapfile -t CONNECTED_MONITORS < <(xrandr --query | grep " connected" | cut -d' ' -f1)
PRIMARY=$(xrandr --query | grep " connected primary" | cut -d' ' -f1)
[ -z "$PRIMARY" ] && PRIMARY=${CONNECTED_MONITORS[0]}

# Full-featured bar (bar1) on the primary output, minimal bar (bar2) elsewhere.
for m in "${CONNECTED_MONITORS[@]}"; do
  if [ "$m" = "$PRIMARY" ]; then
    bar="bar1"
  else
    bar="bar2"
  fi
  MONITOR="$m" polybar --reload "$bar" 2>&1 | tee -a "/tmp/polybar-$m.log" &
  disown
done

echo "Polybar launched..."
