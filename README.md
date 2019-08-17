## Disaply softwares
```
sudo pacman -S xorg xorg-server xorg-apps xorg-xinit i3-gaps 
```

## Graphic softwares
```
sudo pacman -S lxappearance arandr intel-ucode xf86-video-intel
```

## Fonts installation
```
sudo pacman -S ttf-anonymous-pro ttf-fira-code ttf-fira-mono ttf-hack ttf-inconsolata adobe-source-code-pro-fonts ttf-ubuntu-font-family noto-fonts ttf-dejavu xorg-fonts-misc ttf-roboto ttf-font-awesome ripgrep
```

## some helpful softwares
```
sudo pacman -S xdg-user-dirs termite git curl wget neofetch compton rofi ranger feh htop redshift maim jq w3m openssh xclip slock
```

## Text Editor
```
sudo pacman -s vim emacs 
```

## Browser
```
sudo pacman -S firefox chromium
```

## Bluetooth
```
sudo pacman -S bluez bluez-utils blueman
```

## audio driver
```
sudo pacman -S alsa-utils pulseaudio pulseaudio-alsa pulseaudio-bluetooth
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

## siji Font
```
git clone https://aur.archlinux.org/siji-git.git
cd siji-git
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

## zsh autosuggestions plugin
```
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
