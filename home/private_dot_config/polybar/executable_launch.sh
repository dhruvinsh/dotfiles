#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

# Wait until the processes have been shut down
while pgrep -u "$UID" -x polybar >/dev/null; do sleep 0.5; done

# On a fresh login this script races monitor_setup.sh: i3 starts both with
# exec_always and does not wait in between, so xrandr may not have marked an
# output primary yet. Without this wait the fallback below picks the first
# connected output (DP-1) and the full bar lands on the wrong monitor.
# Wait up to ~5s for the primary flag to appear.
for _ in $(seq 1 10); do
  xrandr --query | grep -q " connected primary" && break
  sleep 0.5
done

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
