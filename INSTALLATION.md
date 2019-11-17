<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Things to Install](#things-to-install)
    - [Display](#display)
    - [Network](#network)
        - [Manager](#manager)
        - [Bluetooth](#bluetooth)
        - [Tools](#tools)
    - [Power Management](#power-management)
    - [Console](#console)
        - [Termianl](#termianl)
        - [Shell](#shell)
        - [Apps](#apps)
    - [Tools](#tools-1)
    - [Volume](#volume)
    - [Printer](#printer)
    - [Storage Management](#storage-management)
    - [Fonts](#fonts)
    - [Development](#development)
    - [Notification](#notification)
    - [Web Browser](#web-browser)
    - [Media](#media)
    - [AUR](#aur)
        - [Helper](#helper)
        - [AUR Packages](#aur-packages)
    - [PIP packages](#pip-packages)
    - [Gaming](#gaming)

<!-- markdown-toc end -->
# Things to Install

## Display
``` text
xorg mesa xf86-video-intel vulkan-intel i3-gaps lightdm lightdm-gtk-greeter i3lock arandr lxappearance
sudo systemctl enable lightdm
```

## Network
### Manager
``` text
dialog wpa_supplicant networkmanager network-manager-applet dhclinet pptpclient ppp
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

## Power Management
``` text
powertop acpid tlp xfce4-power-manager acpi
systemctl enable tlp
```

## Console
### Termianl
``` text
termite rxvt-unicode
```

### Shell
``` text
zsh
chsh -s $(which zsh)
```

### Apps
``` text
newsboat calcurse htop aspell aspell-en
```

## Tools
``` text
xdg-user-dirs bash-completion polkit-gnome xarchiver zip unrar curl jq neofetch conky scrot xclip compton rofi ranger w3m nginx libreoffice-still pcmanfm python-pywal variety nitrogen feh zathura zathura-pdf-mupdf qt5ct redshift pacman-contrib sqlitebrowser calibre pandoc autojump fd
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

## Storage Management
``` text
ntfs-3g udisks2 udiskie
```

## Fonts
``` text
ttf-dejavu ttf-droid ttf-roboto noto-fonts ttf-fira-mono ttf-hack adobe-source-code-pro-fonts ttf-font-awesome ttf-liberation wqy-zenhei noto-fonts-emoji ttf-bitstream-vera
```

## Development
``` text
git git-lfs emacs vim code pyenv zeal docker
sudo systemctl enable docker
```

## Notification
``` text
dunst libnotify
```

## Web Browser
``` text
chromium
```

## Media
``` text
youtube-dl mpv ffmpeg
```

## AUR
### Helper
``` text
yay: https://aur.archlinux.org/yay.git
```

### AUR Packages
``` text
pamac-gtk ttf-iosevka flat-remix flat-remix-gtk realvnc-viewer teamviwer polybar flashfocus-git
systemctl enable teamviewerd
```

## PIP packages
``` text
streamlink
```

## Gaming
``` text
steam # Make sure multilib is enabled: https://wiki.archlinux.org/index.php/Official_repositories#multilib
```
