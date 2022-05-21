#!/usr/bin/env bash

# set background
# NOTE: if background is not set then we continue to see SDDM as frozen instance
[ -f "$HOME/.fehbg" ] && "$HOME/.fehbg" || feh --bg-scale .wallpaper/nord-1.png

# NOTE: Straight from google
# LXSession is the standard session manager used by LXDE.
# LXSession automatically starts a set of applications and sets up a working
# desktop environment. Moreover, It's desktop-independent and can be used with
# any window manager.
lxsession &

# Some swag (compositor)
picom --experimental-backends &

# Lets have network applet
nm-applet &

# Auto mount usb disk if needed
udiskie --tray &

# Delay emacs startup a little bit more I don't need urgently
sleep 5

# Emacs startup, with archlinux I am using pacman emacs
/usr/bin/emacs --daemon &
