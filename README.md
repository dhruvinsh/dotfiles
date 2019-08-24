## Display/Window Managers
```
sudo pacman -S xorg xorg-server xorg-apps xorg-xinit i3-gaps 
```

## Desktop Manager
```
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
```

## Graphic
```
sudo pacman -S lxappearance arandr intel-ucode xf86-video-intel
```

## Bluetooth
```
sudo pacman -S bluez bluez-utils blueman
```

## Audio Driver
```
sudo pacman -S alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth
```

## ZSH With Plugin
```
sudo pacman -S zsh
chsh -s $(which zsh)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

## Fonts Installation
```
sudo pacman -S ttf-anonymous-pro ttf-fira-code ttf-fira-mono ttf-hack ttf-inconsolata adobe-source-code-pro-fonts ttf-ubuntu-font-family noto-fonts ttf-dejavu xorg-fonts-misc ttf-roboto ttf-font-awesome noto-fonts-emoji font-mathematica
```

## Some Helpful Softwares
```
sudo pacman -S xdg-user-dirs termite git curl wget neofetch compton rofi ranger feh htop redshift maim jq w3m openssh xclip slock ripgrep hunspell hunspell-en_CA hunspell-en_US libreoffice-still code xorg-xcalc
```

## PDF reader
```
sudo pacman -S libpng zlib imagemagick poppler
# poppler-glib might required replace poppler with it
cd Download
git clone https://aur.archlinux.org/cask.git
cd cask
makepkg -si
cd ..
git clone https://aur.archlinux.org/emacs-tablist-git.git
cd emacs-tablist-git
makepkg -si
cd ..
```

## Text Editor
```
sudo pacman -s vim emacs 
```


## Browser
```
sudo pacman -S firefox chromium
```

## Video/Audio Software
```
sudo pacman -S mpv ffmpeg youtube-dl 
```

## Notification Tools
```
sudo pacman -S dunst libnotify
```

## Input Software
```
sudo pacman -S xf86-input-libinput
```

## Sensors and Events
```
sudo pacman -S lm_sensors acpid upower
```

## Another Useful Font
```
git clone https://aur.archlinux.org/ttf-iosevka.git
cd ttf-iosevka
makepkg -si
git clone https://aur.archlinux.org/siji-git.git
cd siji-git
makepkg -si
```

## Polybar
```
git clone https://aur.archlinux.org/polybar.git
cd polybar
makepkg -si
```

## RXVT-Unicode-Pixbuf
```
git clone
cd rxvt-unicode-pixbuf
makepkg -si
```

## Pulseaudio Control
```
git clone https://aur.archlinux.org/pulseaudio-ctl.git
cd pulseaudio-ctl
makepkg -si
```

## Flash-Focus
```
git clone https://aur.archlinux.org/flashfocus-git.git
cd flashfocus-git
makepkg -si
```

## Teamviewer
```
sudo pacman -S lib32-freetype2 
git clone https://aur.archlinux.org/teamviewer.git
cd teamviewer
makepkg -si
sudo systemctl enable teamviewer
```
