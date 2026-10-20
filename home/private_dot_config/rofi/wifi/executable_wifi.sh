#!/usr/bin/env bash

## Rofi WiFi Menu - Connect to WiFi networks

# Get WiFi interface
wifi_interface=$(nmcli device | grep wifi | awk '{print $1}' | head -n1)

if [[ -z "$wifi_interface" ]]; then
  notify-send "WiFi" "No WiFi interface found" -u critical
  exit 1
fi

# Check if WiFi is enabled
wifi_status=$(nmcli radio wifi)
if [[ "$wifi_status" == "disabled" ]]; then
  rofi_output=$(echo -e "Enable WiFi" | rofi -dmenu -p "WiFi is disabled" -theme-str 'window {width: 300px;} listview {lines: 1;}')
  if [[ "$rofi_output" == "Enable WiFi" ]]; then
    nmcli radio wifi on
    notify-send "WiFi" "WiFi enabled"
    sleep 2
  else
    exit 0
  fi
fi

# Get current connection
current_ssid=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)

# Scan and list networks
notify-send "WiFi" "Scanning networks..."
networks=$(nmcli -f SSID,SIGNAL,SECURITY device wifi list | tail -n +2)

# Format network list
network_list=""
while IFS= read -r line; do
  ssid=$(echo "$line" | awk '{print $1}')
  signal=$(echo "$line" | awk '{print $2}')
  security=$(echo "$line" | awk '{for(i=3;i<=NF;i++) printf $i" "; print ""}')

  # Skip empty SSIDs
  [[ -z "$ssid" || "$ssid" == "--" ]] && continue

  # Add indicator for current network
  if [[ "$ssid" == "$current_ssid" ]]; then
    indicator="✓ "
  else
    indicator="  "
  fi

  # Add lock icon for secured networks
  if [[ "$security" == *"WPA"* ]] || [[ "$security" == *"WEP"* ]]; then
    lock="🔒"
  else
    lock="  "
  fi

  # Signal strength indicator
  if [[ "$signal" -ge 75 ]]; then
    bars="▂▄▆█"
  elif [[ "$signal" -ge 50 ]]; then
    bars="▂▄▆ "
  elif [[ "$signal" -ge 25 ]]; then
    bars="▂▄  "
  else
    bars="▂   "
  fi

  network_list+="${indicator}${lock} ${ssid} ${bars}\n"
done <<<"$networks"

# Add options
options="$(echo -e "${network_list}---\n󰖪 Disconnect\n󰤨 Disable WiFi")"

# Show menu
chosen=$(echo -e "$options" | rofi -dmenu -p "WiFi Networks" -theme-str 'window {width: 500px;} listview {lines: 10;}')

if [[ -z "$chosen" ]]; then
  exit 0
elif [[ "$chosen" == *"Disconnect"* ]]; then
  nmcli connection down "$current_ssid" 2>/dev/null
  notify-send "WiFi" "Disconnected from $current_ssid"
elif [[ "$chosen" == *"Disable WiFi"* ]]; then
  nmcli radio wifi off
  notify-send "WiFi" "WiFi disabled"
else
  # Extract SSID from chosen line
  chosen_ssid=$(echo "$chosen" | sed 's/^[ ✓]*[🔒 ]*//; s/ [▂▄▆█ ]*$//')

  # Check if network is secured
  security=$(nmcli -f SSID,SECURITY device wifi list | grep "^$chosen_ssid" | awk '{for(i=2;i<=NF;i++) printf $i" "; print ""}')

  if [[ "$security" == *"WPA"* ]] || [[ "$security" == *"WEP"* ]]; then
    # Ask for password
    password=$(rofi -dmenu -p "Password for $chosen_ssid" -password -theme-str 'window {width: 400px;} listview {lines: 0;}')

    if [[ -n "$password" ]]; then
      if nmcli device wifi connect "$chosen_ssid" password "$password"; then
        notify-send "WiFi" "Connected to $chosen_ssid"
      else
        notify-send "WiFi" "Failed to connect to $chosen_ssid" -u critical
      fi
    fi
  else
    # Connect to open network
    if nmcli device wifi connect "$chosen_ssid"; then
      notify-send "WiFi" "Connected to $chosen_ssid"
    else
      notify-send "WiFi" "Failed to connect to $chosen_ssid" -u critical
    fi
  fi
fi
