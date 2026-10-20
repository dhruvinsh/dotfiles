#!/usr/bin/env bash

## Rofi WiFi Menu - Connect to hidden/new network

# Get WiFi interface
wifi_interface=$(nmcli device | grep wifi | awk '{print $1}' | head -n1)

if [[ -z "$wifi_interface" ]]; then
  notify-send "WiFi" "No WiFi interface found" -u critical
  exit 1
fi

# Check if WiFi is enabled
wifi_status=$(nmcli radio wifi)
if [[ "$wifi_status" == "disabled" ]]; then
  notify-send "WiFi" "Please enable WiFi first" -u critical
  exit 1
fi

# Ask for SSID
ssid=$(rofi -dmenu -p "Enter SSID (Network Name)" -theme-str 'window {width: 400px;} listview {lines: 0;}')

if [[ -z "$ssid" ]]; then
  exit 0
fi

# Ask for security type
security_type=$(echo -e "WPA/WPA2\nWPA3\nWEP\nNone (Open)" | rofi -dmenu -p "Security Type" -theme-str 'window {width: 300px;} listview {lines: 4;}')

if [[ -z "$security_type" ]]; then
  exit 0
fi

# Connect based on security type
case "$security_type" in
  "None (Open)")
    if nmcli device wifi connect "$ssid"; then
      notify-send "WiFi" "Connected to $ssid"
    else
      notify-send "WiFi" "Failed to connect to $ssid" -u critical
    fi
    ;;
  *)
    # Ask for password
    password=$(rofi -dmenu -p "Password for $ssid" -password -theme-str 'window {width: 400px;} listview {lines: 0;}')

    if [[ -z "$password" ]]; then
      exit 0
    fi

    if nmcli device wifi connect "$ssid" password "$password"; then
      notify-send "WiFi" "Connected to $ssid"
    else
      notify-send "WiFi" "Failed to connect to $ssid" -u critical
    fi
    ;;
esac
