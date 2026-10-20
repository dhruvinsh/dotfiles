#!/usr/bin/env bash
# Volume / mic control with on-screen display.
# Usage: osd-volume.sh up|down|mute|mic-mute
set -u

fifo="${XDG_RUNTIME_DIR:-/tmp}/xob.fifo"
sink='@DEFAULT_AUDIO_SINK@'
source_='@DEFAULT_AUDIO_SOURCE@'

notify() { # notify <summary> [value]
  if command -v dunstify >/dev/null; then
    if [[ -n ${2:-} ]]; then
      dunstify -h string:x-dunst-stack-tag:osd -h "int:value:$2" "$1"
    else
      dunstify -h string:x-dunst-stack-tag:osd "$1"
    fi
  else
    notify-send -h string:x-canonical-private-synchronous:osd "$1"
  fi
}

show_volume() {
  local out vol
  out=$(wpctl get-volume "$sink") || return
  vol=$(awk '{printf "%d", $2 * 100 + 0.5}' <<<"$out")
  if pgrep -x xob >/dev/null && [[ -p $fifo ]]; then
    if [[ $out == *MUTED* ]]; then
      echo "${vol}!" >"$fifo"
    else
      echo "$vol" >"$fifo"
    fi
  elif [[ $out == *MUTED* ]]; then
    notify "Volume muted" "$vol"
  else
    notify "Volume ${vol}%" "$vol"
  fi
}

case ${1:-} in
  up)
    wpctl set-volume -l 1.0 "$sink" 5%+
    wpctl set-mute "$sink" 0
    show_volume
    ;;
  down)
    wpctl set-volume "$sink" 5%-
    show_volume
    ;;
  mute)
    wpctl set-mute "$sink" toggle
    show_volume
    ;;
  mic-mute)
    wpctl set-mute "$source_" toggle
    if wpctl get-volume "$source_" | grep -q MUTED; then
      notify "Mic muted"
    else
      notify "Mic unmuted"
    fi
    ;;
  *)
    echo "usage: ${0##*/} up|down|mute|mic-mute" >&2
    exit 1
    ;;
esac
