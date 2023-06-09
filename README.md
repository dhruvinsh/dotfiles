# Dotfiles

Collection of personal dotfile, managed via chezmoi.

# Installation

Below code will install chezmoi in local bin directory and start
applying the existing setup.

``` bash
export BINDIR="$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"  # I need to do it else age binary will give me error
sh -c "$(curl -fsLS chezmoi.io/get)" -- init dhruvinsh --apply
```

# Arch Installation

See these file, [Installation](Installation.md)

# Credits

-   Thanks [Tom Payne](https://github.com/twpayne) for awesome tool:
    [chezmoi](https://github.com/twpayne/chezmoi)
-   Arch Linux installation guide: [Arch Wiki](https://wiki.archlinux.org/title/Installation_guide)
-   Wallpapers credits:
    [VictorTennekes](https://www.reddit.com/user/VictorTennekes/) All
    the wallpaper can be found [HERE](home/private_dot_wallpaper/)
