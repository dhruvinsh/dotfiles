#!/usr/bin/env bash

# Get list of connected monitors
CONNECTED_MONITORS=$(xrandr --query | grep " connected" | cut -d' ' -f1)
MONITOR_COUNT=$(echo "$CONNECTED_MONITORS" | wc -l)

# work system config
if [ "$MONITOR_COUNT" -eq 2 ]; then
    # Dual monitor setup
    # Get the two monitors (order matters for positioning)
    MONITOR_1=$(echo "$CONNECTED_MONITORS" | sed -n '1p') # right
    MONITOR_2=$(echo "$CONNECTED_MONITORS" | sed -n '2p') # left

    # Set up dual monitors side-by-side
    # First monitor on right (primary), second monitor on left
    # ❯ xrandr --query | grep " connected" | cut -d' ' -f1
    # DP-4
    # DP-6
    # original command:
    # xrandr --output DP-6 --mode 2560x1440 --pos 0x0 --output DP-4 --mode 2560x1440 --pos 2560x0 --primary
    xrandr --output "$MONITOR_2" --mode 2560x1440 --pos 0x0 \
           --output "$MONITOR_1" --mode 2560x1440 --pos 2560x0 --primary

    # # Assign workspaces: most on primary (right), one on secondary (left)
    # i3-msg "workspace 1  output $MONITOR_1"
    # i3-msg "workspace 2  output $MONITOR_1"
    # i3-msg "workspace 3  output $MONITOR_1"
    # i3-msg "workspace 4  output $MONITOR_1"
    # i3-msg "workspace 5  output $MONITOR_1"
    # i3-msg "workspace 6  output $MONITOR_1"
    # i3-msg "workspace 7  output $MONITOR_1"
    # i3-msg "workspace 8  output $MONITOR_2"
    # i3-msg "workspace 9  output $MONITOR_1"

elif [ "$MONITOR_COUNT" -eq 1 ]; then
    # Single monitor setup
    PRIMARY_OUTPUT=$(echo "$CONNECTED_MONITORS" | head -n1)

    # Set primary monitor to best available resolution
    xrandr --output "$PRIMARY_OUTPUT" --auto --primary

    # All workspaces on primary output
    # for i in {1..9}; do
    #     i3-msg "workspace $i output $PRIMARY_OUTPUT"
    # done
else
    # More than 2 monitors - use first two
    MONITOR_1=$(echo "$CONNECTED_MONITORS" | sed -n '1p')
    MONITOR_2=$(echo "$CONNECTED_MONITORS" | sed -n '2p')

    # Disable other monitors
    for monitor in $CONNECTED_MONITORS; do
        if [ "$monitor" != "$MONITOR_1" ] && [ "$monitor" != "$MONITOR_2" ]; then
            xrandr --output "$monitor" --off
        fi
    done

    # Set up first two monitors
    xrandr --output "$MONITOR_1" --mode 2560x1440 --pos 0x0 \
           --output "$MONITOR_2" --mode 2560x1440 --pos 2560x0 --primary

    # Assign workspaces
    # i3-msg "workspace 1 output $MONITOR_2"
    # i3-msg "workspace 2 output $MONITOR_2"
    # i3-msg "workspace 3 output $MONITOR_2"
    # i3-msg "workspace 4 output $MONITOR_2"
    # i3-msg "workspace 5 output $MONITOR_2"
    # i3-msg "workspace 6 output $MONITOR_2"
    # i3-msg "workspace 7 output $MONITOR_2"
    # i3-msg "workspace 8 output $MONITOR_1"
    # i3-msg "workspace 9 output $MONITOR_2"
fi

