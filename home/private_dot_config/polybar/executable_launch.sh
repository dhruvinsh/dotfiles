#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit >/dev/null 2>&1 || pkill -x polybar

# Wait until the processes have been shut down (force after ~5s)
for _ in $(seq 1 10); do
  pgrep -u "$UID" -x polybar >/dev/null || break
  sleep 0.5
done
pgrep -u "$UID" -x polybar >/dev/null && pkill -x polybar

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
mapfile -t CONNECTED_MONITORS < <(xrandr --query | awk '/ connected/ {print $1}')
PRIMARY=$(xrandr --query | awk '/ connected primary/ {print $1; exit}')
[ -z "$PRIMARY" ] && PRIMARY=${CONNECTED_MONITORS[0]}

# CPU temperature sensor for the temperature module (coretemp on Intel,
# k10temp/zenpower on AMD). Empty -> module falls back to thermal-zone.
POLYBAR_HWMON_PATH=""
for hw in /sys/class/hwmon/hwmon*; do
  case "$(cat "$hw/name" 2>/dev/null)" in
    coretemp | k10temp | zenpower)
      if [ -r "$hw/temp1_input" ]; then
        POLYBAR_HWMON_PATH=$(readlink -f "$hw/temp1_input")
        break
      fi
      ;;
  esac
done
export POLYBAR_HWMON_PATH

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
