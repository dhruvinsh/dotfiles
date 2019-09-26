<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Softwares](#softwares)
    - [Display](#display)
    - [Console](#console)
        - [Termianl](#termianl)
        - [Shell](#shell)
        - [Apps](#apps)
    - [Network](#network)
        - [Manager](#manager)
        - [Bluetooth](#bluetooth)
        - [Tools](#tools)
        - [Storage Management](#storage-management)
    - [Power Management](#power-management)
    - [Tools](#tools-1)
    - [Volume](#volume)
    - [Printer](#printer)
    - [Fonts](#fonts)
    - [Development](#development)
    - [Notification](#notification)
    - [Web Browser](#web-browser)
    - [Media](#media)
    - [Aur packages](#aur-packages)
    - [PIP packages](#pip-packages)
    - [Gaming](#gaming)

<!-- markdown-toc end -->
# Things to Install

## Display
``` text
xorg mesa xf86-video-intel vulkan-intel i3-gaps lightdm lightdm-gtk-greeter i3lock arandr lxappearance
sudo systemctl enable lightdm
```

## Console
### Termianl
``` text
kitty termite rxvt-unicode
```

### Shell
``` text
zsh
chsh -s $(which zsh)
```

### Apps
``` text
newsboat calcurse
```

## Network
### Manager
``` text
dialog wpa_supplicant networkmanager network-manager-applet dhclinet
systemctl enable NetworkManager
```
### Bluetooth
``` text
bluez bluez-utils blueman
systemclt enable bluetooth
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

## Tools
``` text
xdg-user-dirs bash-completion polkit-gnome xarchiver zip unrar curl jq neofetch conky scrot xclip compton rofi ranger w3m  nginx  libreoffice-still pcmanfm python-pywal variety nitrogen zathura zathura-pdf-mupdf qt5ct redshift pacman-contrib sqlitebrowser calibre pandoc
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
ttf-dejavu ttf-droid ttf-roboto noto-fonts ttf-fira-mono ttf-hack adobe-source-code-pro-fonts ttf-font-awesome ttf-liberation wqy-zenhei noto-fonts-emoji ttf-bitstream-vera
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
