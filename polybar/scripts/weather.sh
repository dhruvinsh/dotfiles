#!/bin/env bash

# Original source - https://github.com/polybar/polybar-scripts/tree/master/polybar-scripts/openweathermap-detailed

get_icon() {
    case $1 in
        01d) ICON="";; # clear sky - day
        01n) ICON="望";; # clear sky - night
        02d) ICON="杖";; # few clouds - day
        02n) ICON="";; # few clouds - night
        03*) ICON="摒";; # scattered clouds - day and night
        04*) ICON="";; # broken clouds - day and night
        09*) ICON="";; # shower rain - day and night
        10d) ICON="";; # rain - day
        10n) ICON="";; # rain - night
        11*) ICON="";; # thunder storm - day and night
        13*) ICON="";; # snow - day and night
        50*) ICON="";; # mist - day and night
        *) ICON=""; # no status
    esac

    echo $ICON
}

# Global settings
KEY="57f80570f2c2947c9dc274cfb0bc6562"
CITY="Burlington"
UNITS="metric"
SYMBOL="°C"
API="https://api.openweathermap.org/data/2.5"

# Get weather
WEATHER=$(curl -sf "$API/weather?APPID=$KEY&q=$CITY&units=$UNITS")

# Get condition, temp and icon
WEATHER_MAIN=$(echo $WEATHER | jq -r ".weather[0].main")
WEATHER_ICON=$(echo $WEATHER | jq -r ".weather[0].icon")
WEATHER_TEMP=$(echo $WEATHER | jq -r ".main.temp")

# Print weather
echo "$(get_icon $WEATHER_ICON) $WEATHER_MAIN $WEATHER_TEMP$SYMBOL"
