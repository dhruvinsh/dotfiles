#!/usr/bin/env bash

# NOTE: Straight from google
# LXSession is the standard session manager used by LXDE.
# LXSession automatically starts a set of applications and sets up a working
# desktop environment. Moreover, It's desktop-independent and can be used with
# any window manager.
lxsession &

# set background
[ -f "$HOME/.fehbg" ] && "$HOME/.fehbg" || feh --bg-scale .wallpaper/nord-1.png

# Some swag (compositor)
picom --experimental-backends &

# Volume control (its config managed by chezmoi)
volumeicon &

# Lets have network applet
nm-applet &

# Auto mount usb disk if needed
udiskie --tray &

# Emacs startup, with archlinux I am using pacman emacs
/usr/bin/emacs --daemon &
