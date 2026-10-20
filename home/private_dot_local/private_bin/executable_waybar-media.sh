#!/usr/bin/env bash
# Waybar media pill (custom/media). Polled: prints the current MPRIS player's
# track as JSON, or empty text -- which hides the pill -- when the player is
# stopped, has no title, or is gone. Brave/Chromium keep a "Stopped" player
# with empty metadata registered after the tab closes, which waybar's built-in
# mpris module kept showing as the last track.

# \x1f separator: tab is IFS whitespace, so `read` would collapse empty fields
# (e.g. no artist) and shift the title out of place.
sep=$'\x1f'
fmt="{{status}}$sep{{playerName}}$sep{{artist}}$sep{{title}}$sep{{album}}"

# Prefer a playing player, else a paused one that still has a title.
pick=''
while IFS= read -r p; do
  line=$(timeout 1 playerctl -p "$p" metadata --format "$fmt" 2>/dev/null) || continue
  IFS=$sep read -r status _ _ title _ <<<"$line"
  [[ -n $title ]] || continue
  if [[ $status == Playing ]]; then
    pick=$line
    break
  fi
  [[ $status == Paused && -z $pick ]] && pick=$line
done < <(playerctl -l 2>/dev/null | grep -v '^playerctld$')

IFS=$sep read -r status player artist title album <<<"$pick"

if [[ -z ${title:-} || ${status:-Stopped} == Stopped ]]; then
  printf '{"text":"","class":"stopped"}\n'
  exit 0
fi

case ${player,,} in
  brave* | chromium* | chrome*) icon=$'\U000f059f' ;; # web
  firefox*) icon=$'\U000f0239' ;;
  spotify*) icon=$'\U000f04c7' ;;
  mpv*) icon=$'\U000f0381' ;;
  *) icon=$'\U000f075a' ;; # music note
esac
[[ $status == Paused ]] && icon=$'\U000f03e4' # pause

text="$icon  ${artist:+$artist - }$title"
tooltip="${player}: ${artist:+$artist - }$title${album:+\n$album}\n\nclick: play/pause · right: next · middle: previous · scroll: next/prev"

jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "${status,,}" \
  '{text: $text, tooltip: ($tooltip | gsub("\\\\n"; "\n")), class: $class}'
