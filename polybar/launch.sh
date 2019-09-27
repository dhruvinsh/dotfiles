#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut donw
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch bar
if type "xrandr"; then
    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        MONITOR=$m polybar --reload mybar &
    done
else
    polybar mybar &
fi

ehco "Bars launched..."
