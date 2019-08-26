## Fonts Installation
```
sudo pacman -S ttf-anonymous-pro ttf-fira-code ttf-fira-mono ttf-hack ttf-inconsolata adobe-source-code-pro-fonts ttf-ubuntu-font-family noto-fonts ttf-dejavu xorg-fonts-misc ttf-roboto ttf-font-awesome noto-fonts-emoji font-mathematica ttf-joypixels

  To prevent conflicts with other emoji fonts,
  75-joypixels.conf is not automatically installed to /etc/fonts/conf.d/

  If you don't use other emoji fonts, you can simply create a symlink:
  # ln -sf ../conf.avail/75-joypixels.conf /etc/fonts/conf.d/75-joypixels.conf

  If you do use other emoji fonts,
  copy 75-joypixels.conf to /etc/fonts/conf.d/ and remove corresponding aliases
```

## Desktop/Window Managers
```
sudo pacman -S xorg xorg-server xorg-apps xorg-xinit i3-gaps 
```

## Display Manager
```
sudo pacman -S lightdm lightdm-webkit2-greeter
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

## Notification Tools
```
sudo pacman -S dunst libnotify
```

## Some Helpful Softwares
```
sudo pacman -S xdg-user-dirs termite git curl wget neofetch rofi ranger feh htop redshift maim jq w3m openssh xclip slock ripgrep hunspell hunspell-en_CA hunspell-en_US libreoffice-still code zathura zathura-pdf-mupdf imagemagick python-pywal calcurse newsboat ntfs-3g unrar unzip

Not sure about these ones, didn't installed
xorg-xcalc compton
```

## ZSH With Plugin
```
sudo pacman -S zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```

## PDF reader for Emacs (Spacemacs)
```
sudo pacman -S libpng zlib imagemagick poppler
# poppler-glib might required replace poppler with it
cd Download
git clone https://aur.archlinux.org/cask.git
cd cask
makepkg -sri
cd ..
git clone https://aur.archlinux.org/emacs-tablist-git.git
cd emacs-tablist-git
makepkg -sri
cd ..
```

## Text Editor
```
sudo pacman -S vim emacs 
```

## Browser
```
sudo pacman -S firefox chromium qutebrowser
```

## Video/Audio Software
```
sudo pacman -S mpv ffmpeg youtube-dl 
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
makepkg -sri
cd ..
git clone https://aur.archlinux.org/siji-git.git
cd siji-git
makepkg -sri
cd ..
git clone https://aur.archlinux.org/ttf-symbola.git
cd ttf-symbola
makepkg -sri
cd ..
```

## Polybar
```
git clone https://aur.archlinux.org/polybar.git
cd polybar
makepkg -sri
cd ..
```

## RXVT-Unicode-Pixbuf
```
git clone
cd rxvt-unicode-pixbuf
makepkg -sri
cd ..
```

## Pulseaudio Control
```
git clone https://aur.archlinux.org/pulseaudio-ctl.git
cd pulseaudio-ctl
makepkg -sri
cd ..
```

## Flash-Focus
```
git clone https://aur.archlinux.org/flashfocus-git.git
cd flashfocus-git
makepkg -sri
cd ..
```

## Teamviewer
```
sudo pacman -S lib32-freetype2 
git clone https://aur.archlinux.org/teamviewer.git
cd teamviewer
makepkg -sri
sudo systemctl enable teamviewer
```