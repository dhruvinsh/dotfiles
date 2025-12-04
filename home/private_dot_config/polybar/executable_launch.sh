#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.5; done

CONNECTED_MONITORS=$(xrandr --query | grep " connected" | cut -d' ' -f1)

# Launch bars for each monitor
index=1
for m in $CONNECTED_MONITORS; do
  MONITOR=$m polybar --reload bar$index 2>&1 | tee -a /tmp/polybar-$m.log & disown
  index=$((index + 1))
done

echo "Polybar launched..."
