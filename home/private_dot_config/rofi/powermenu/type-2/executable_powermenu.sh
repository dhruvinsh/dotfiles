#!/usr/bin/env bash

## Rofi Power Menu
## Inspired by Hyprland Hall of Fame aesthetic

# Theme
theme="$HOME/.config/rofi/powermenu/type-2/powermenu.rasi"

# Check if theme file exists
if [[ ! -f "$theme" ]]; then
  notify-send "Power Menu" "Theme file not found: $theme" -u critical
  exit 1
fi

# Options with icons and labels
lock="󰌾  Lock"
suspend="󰤄  Suspend"
logout="󰍃  Logout"
reboot="󰑓  Reboot"
shutdown="󰐥  Shutdown"

# System uptime for header
uptime_str=$(uptime -p 2>/dev/null | sed -e 's/up //g')
[ -z "$uptime_str" ] && uptime_str="System Active"
prompt_text="Uptime: $uptime_str"

# Confirmation dialog helper (matches the main theme)
confirm_exit() {
  local action="$1"
  local yes="󰄬  Yes"
  local no="󰅖  No"

  local confirm_override='window { width: 400px; border-radius: 20px; } listview { columns: 2; lines: 1; spacing: 14px; } element { padding: 18px 10px; } textbox-prompt-colon { str: "󰋗"; text-color: @accent; }'

  local ans
  ans=$(printf '%s\n%s' "$yes" "$no" |
    rofi -dmenu \
      -theme "$theme" \
      -theme-str "$confirm_override" \
      -p "Confirm ${action}?" \
      -selected-row 1 \
      -u 0 \
      -format i)

  # 0 is Yes, 1 is No
  [[ "$ans" == "0" ]]
}

# Run rofi menu
chosen_idx=$(printf '%s\n%s\n%s\n%s\n%s' "$lock" "$suspend" "$logout" "$reboot" "$shutdown" |
  rofi -dmenu \
    -theme "$theme" \
    -p "$prompt_text" \
    -selected-row 2 \
    -u 4 \
    -a 0 \
    -format i)

# Execute based on selected index
case "$chosen_idx" in
  0)
    # Lock immediately (no confirmation needed)
    if [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]] && command -v hyprlock &>/dev/null; then
      hyprlock
    elif [[ -x "$HOME/.config/i3/scripts/i3lock.sh" ]] && [[ "$XDG_SESSION_TYPE" != "wayland" ]]; then
      "$HOME/.config/i3/scripts/i3lock.sh"
    elif command -v i3lock &>/dev/null && [[ "$XDG_SESSION_TYPE" != "wayland" ]]; then
      i3lock
    elif command -v hyprlock &>/dev/null; then
      hyprlock
    elif command -v swaylock &>/dev/null; then
      swaylock
    elif command -v gtklock &>/dev/null; then
      gtklock
    else
      notify-send "Lock" "No lock command found" -u critical
    fi
    ;;
  1)
    # Suspend
    if confirm_exit "suspend"; then
      systemctl suspend
    fi
    ;;
  2)
    # Logout
    if confirm_exit "logout"; then
      if [[ "$XDG_CURRENT_DESKTOP" == *"Hyprland"* ]]; then
        if command -v uwsm &>/dev/null && [[ -n "$UWSM_ACTIVE" ]]; then
          uwsm stop
        elif command -v hyprctl &>/dev/null; then
          hyprctl dispatch exit
        fi
      elif [[ "$XDG_CURRENT_DESKTOP" == *"i3"* ]] || command -v i3-msg &>/dev/null; then
        i3-msg exit
      elif command -v swaymsg &>/dev/null; then
        swaymsg exit
      elif command -v loginctl &>/dev/null; then
        loginctl terminate-user "$USER"
      fi
    fi
    ;;
  3)
    # Reboot
    if confirm_exit "reboot"; then
      systemctl reboot
    fi
    ;;
  4)
    # Shutdown
    if confirm_exit "shutdown"; then
      systemctl poweroff
    fi
    ;;
esac
