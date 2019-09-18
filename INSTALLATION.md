# Softwares


## Display
``` text
xorg mesa xf86-video-intel vulkan-intel i3-gaps lightdm lightdm-gtk-greeter i3lock
arandr lxappearance
sudo systemctl enable lightdm
```

## Network
### Manager
``` text
dialog wpa_supplicant networkmanager network-manager-applet
```
### Bluetooth
``` text
blueman blueman bluez
```
### Tools
``` text
ufw openssh gufw
sudo systemctl enable ufw
sudo systemctl enable sshd
```
### Storage Management
``` text
ntfs-3g udisks2 udiskie
```

## Power Management
``` text
powertop acpid tlp xfce4-power-manager acpi htop
```

## Misc tools
``` text
xdg-user-dirs bash-completion polkit-gnome xarchiver zip unrar curl jq neofetch conky scrot xclip compton rofi zsh termite ranger w3m  nginx  newsboat libreoffice-still pcmanfm python-pywal variety nitrogen zathura zathura-pdf-mupdf qt5ct calcurse redshift pacman-contrib sqlitebrowser calibre pandoc
xdg-user-dirs-update
```

## Volume
``` text
alsa alsa-utils volumeicon
```

## Printer
``` text
cups cups-pdf
sudo systemctl enable org.cups.cupsd
```

## Fonts
``` text
ttf-dejavu ttf-droid ttf-roboto noto-fonts ttf-fira-mono ttf-hack adobe-source-code-pro-fonts ttf-font-awesome ttf-liberation wqy-zenhei noto-fonts-emoji
```

## Development
``` text
git emacs vim code python python-pip
```

## Notification
``` text
dunst libnotify
```

## Web Browser
``` text
chromium qutebrowser
```

## Media
``` text
youtube-dl mpv ffmpeg
```

## Aur packages
``` text
pamac-gtk: https://aur.archlinux.org/pamac-aur.git
ttf-iosevka: https://aur.archlinux.org/ttf-iosevka.git
flat-remix: https://aur.archlinux.org/flat-remix.git
realvnc-viewer: https://aur.archlinux.org/realvnc-vnc-viewer.git
```

## PIP packages
``` text
streamlink
```

## Gaming
``` text
steam # Make sure multilib is enabled: https://wiki.archlinux.org/index.php/Official_repositories#multilib
```
