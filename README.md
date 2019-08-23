## Disaply softwares
```
sudo pacman -S xorg xorg-server xorg-apps xorg-xinit i3-gaps 
```

## Desktop Manager
```
sudo pacman -S lightdm lightdm-gtk-greeter
sudo systemctl enable lightdm
```

## Graphic card softwares
```
sudo pacman -S lxappearance arandr intel-ucode xf86-video-intel
```

## Bluetooth
```
sudo pacman -S bluez bluez-utils blueman
```

## audio driver
```
sudo pacman -S alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth
```

## zsh with plugin
```
sudo pacman -S zsh
chsh -s $(which zsh)
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

## Fonts installation
```
sudo pacman -S ttf-anonymous-pro ttf-fira-code ttf-fira-mono ttf-hack ttf-inconsolata adobe-source-code-pro-fonts ttf-ubuntu-font-family noto-fonts ttf-dejavu xorg-fonts-misc ttf-roboto ttf-font-awesome noto-fonts-emoji font-mathematica
```

## some helpful softwares
```
sudo pacman -S xdg-user-dirs termite git curl wget neofetch compton rofi ranger feh htop redshift maim jq w3m openssh xclip slock ripgrep hunspell hunspell-en_CA hunspell-en_US libreoffice-still code
```

## Text Editor
```
sudo pacman -s vim emacs 
```

## Browser
```
sudo pacman -S firefox chromium
```

## video/audio software
```
sudo pacman -S mpv ffmpeg youtube-dl 
```

## Notification tools
```
sudo pacman -S dunst libnotify
```

## Input software
```
sudo pacman -S xf86-input-libinput
```

## Sensors and events
```
sudo pacman -S lm_sensors acpid upower
```

## Another useful font
```
git clone https://aur.archlinux.org/ttf-iosevka.git
cd ttf-iosevka
makepkg -si
git clone https://aur.archlinux.org/siji-git.git
cd siji-git
makepkg -si
```

## polybar
```
git clone https://aur.archlinux.org/polybar.git
cd polybar
makepkg -si
```

## rxvt-unicode-pixbuf
```
git clone
cd rxvt-unicode-pixbuf
makepkg -si
```

## Pulseaudio control
```
git clone https://aur.archlinux.org/pulseaudio-ctl.git
cd pulseaudio-ctl
makepkg -si
```

## Flash-focus
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
