# Dotfiles Architecture Reference

Companion to [`../CLAUDE.md`](../CLAUDE.md). Detail-level map of the repo for when a
task needs specifics. Paths below are relative to the **source root `home/`** unless
noted.

## Repo root (meta only)

| Path | Purpose |
|------|---------|
| `.chezmoiroot` | Points chezmoi at `home/` as the source dir |
| `.chezmoiversion` | Minimum chezmoi version (2.62.4) |
| `README.md` | Per-OS bootstrap (`chezmoi init dhruvinsh --apply`) |
| `Installation.md` | Arch base-system install walkthrough |
| `.pre-commit-config.yaml` | prek hooks: gitleaks, shellcheck, shfmt, chezmoi template check |
| `.github/workflows/lint.yml` | shellcheck + shfmt (triggers on push to `main` and on PRs) |
| `scripts/shellcheck.bash`, `scripts/shfmt.bash` | Lint entrypoints used by CI |
| `scripts/chezmoi-template-check.bash` | Renders `*.tmpl` to catch template errors (hook) |
| `scripts/arch-install.bash` | Base Arch install from the live ISO (btrfs, GRUB, chainloads other OSes) — see `Installation.md` |
| `scripts/capture-machine-info.bash` | Run on the old OS first: records hostname/MAC/Wi-Fi/disks for the reinstall |
| `.claude/agents/{doc-sync,chezmoi-reviewer}.md` | Project subagents (see CLAUDE.md) |
| `color_match.py`, `templater.py` | Local color/template helper utilities |
| `.stylua.toml`, `.cbfmt.toml`, `.editorconfig` | Formatter configs |

## Install pipeline (`home/.chezmoiscripts/`)

Scripts run in stage order: `before_` (before file apply) then `after_`, each sorted by
the numeric prefix. `run_once_` runs a single time; `run_onchange_` re-runs when the
script's content changes.

### Cross-OS — `non-windows/`
- `run_once_before_decrypt-private-key.sh.tmpl` — bootstrap age key
- `run_onchange_before_10_cleanup.sh.tmpl` — remove stale tool installs
- `run_onchange_after_86_install-rust.sh.tmpl` — rustup
- `run_onchange_after_88_install-fonts.sh.tmpl` — Nerd Fonts
- `run_onchange_after_89_install-zsh.sh.tmpl` — zsh
- `run_onchange_after_90_install-mise.sh.tmpl` — mise + all managed tools
- `run_onchange_after_91_install-ai.sh.tmpl` — AI CLIs

### `arch/`
- `before_10-cleanup`, `before_11_install-arch-packages`, `before_12_install-arch-extra`,
  `before_13_install-arch-nvidia`
- `after_81_install-arch-geolocation`, `after_82_install-arch-docker`,
  `after_82_install-arch-eol-packages`, `after_83_install-arch-sddm-theme`, `after_88_install-fonts`
- `run_once_after_bluetooth-setup`, `run_once_after_networking-setup`, `run_once_after_sddm-pam` — one-time system setup

### `ubuntu/`
- `before_10_cleanup`, `before_11_install-ubuntu-packages`, `before_13_install-docker`
- `after_82_install-misc`, `after_88_install-go`, `after_89_install-tmux`,
  `after_90_wsl-ssh`, `after_91_install-rclone`
- `desktop/after_61_install-ubuntu-desktop-packages`,
  `desktop/after_62_install-ubuntu-desktop-emacs` (installs the Emacs .deb from the `dhruvinsh/emacs-builds` releases)

### `fedora/`
- `before_11_install-fedora-packages`, `before_13_install-docker`
- `desktop/before_12_install-fedora-desktop-packages`,
  `desktop/before_13_install-fedora-coding-packages`

### `darwin/`
- `before_decrypt-private-key`, `before_10_cleanup`, `before_11_install-brew-packages`

### `windows/` (PowerShell)
- `before_decrypt-private-key`, `before_10_cleanup`, `before_11_install-windows-packages`
  (scoop), `after_81_env-setup`, `after_82_install-other-packages`, `after_83_install-fonts`

## Templates (`home/.chezmoitemplates/`)

- `colors/*.jsonc.tmpl` — palette definitions per scheme; parsed in `.chezmoi.toml.tmpl`
  into `.colorScheme.*` and re-injected into app configs (kitty, wezterm, lazygit, rofi,
  waybar, hypr, …).
- `gtk-colors.css` — shared GTK `@define-color` palette from `.colorScheme`, included by
  the waybar, swaync, swayosd, and wlogout `style.css.tmpl` files.
- `encryption/{jira,geoclue}` — age-encrypted secret blobs; used via `| decrypt`.
- `llm/{keys.json.tmpl, extra-openai-models.yaml.tmpl, default_model.txt, litellm-key}` —
  Simon Willison `llm` CLI config.
- `sddm/{Main.qml, theme.conf}` — custom "lumen" SDDM theme sources (`theme.conf` themed
  from `.colorScheme`); embedded via `includeTemplate` by arch `after_83_install-arch-sddm-theme`,
  which installs to `/usr/share/sddm/themes/lumen` + writes `/etc/sddm.conf.d/10-theme.conf`
  (re-runs on palette/theme/wallpaper change).
- `scripts/{download_helpers.sh, service_helpers.sh, gpu_helpers.sh}` — shared script functions.
- `gtk-theme`, `icon-theme` — theme-name partials: `adw-gtk3` / `adw-gtk3-dark` and
  `Flat-Remix-<flatRemixColor>-<Light|Dark>`. Mode is an optional `.mode` (pass via
  `merge (dict "mode" "light") .`), else `colorScheme.variant`. Used by gtk-2.0/3.0, qt6ct,
  rofi, dunst, and `theme-mode`.
- `nvidia-mode` — template-time NVIDIA detection: `display` | `compute` | `none`.
- `python`, `mixture`, `hex2rgb` — helper snippets (e.g. python version resolution).
- `lazygit.yml.tmpl` — themed config fragment.

## Externals (`home/.chezmoiexternals/`)

- `neovim.toml.tmpl` — nvim config as `git-repo` from `dhruvinsh/nvim` (+ `vnvim`
  archive variant, + neovide AppImage on non-Arch Linux desktop).
- `cli.toml.tmpl` — release binaries (atuin, delta, eza, semver, …) into `.local/bin`
  on non-Arch, non-Windows. Uses `gitHubLatestReleaseAssetURL`.
- `terminal.toml.tmpl`, `zsh.toml.tmpl` — terminal + zsh plugin externals.

## Conditional ignores (`home/.chezmoiignore.tmpl`)

Excludes by platform: Windows drops non-windows scripts/`.local`/zsh files; non-Windows
drops `AppData`/`Documents`; non-Linux drops fontconfig/wallpaper/bash; non-macOS drops
`Library`/darwin; non-Arch drops arch scripts + `hypr`, `uwsm`, `swaync`, `swayosd`,
`waybar`, `wlogout`, `yay`, and `.local/bin/{__wlogout.sh,waybar-updates.sh,theme-mode}`;
`networkmanager-dmenu` only kept on Arch or Ubuntu desktop; non-Ubuntu/non-Fedora drop their
script dirs; `.local/share/**` only kept on Ubuntu desktop. Per-machine:
`.config/teams-for-linux` dropped unless `lookPath "teams-for-linux"` finds it.

## Managed app configs (`home/private_dot_config/`)

- **Shell/mux:** zsh (primary; lives outside `.config` — loader `dot_zshrc` +
  `private_dot_zsh/{exact_rc.d,exact_functions}`), bash, fish (`config.fish.tmpl` + `functions/`), tmux
- **Terminals:** kitty, wezterm, ghostty (alacritty removed)
- **Wayland/WM:** hypr (Hyprland, Lua; `hyprland.lua.tmpl`, plus hyprlock, hypridle, hyprpaper),
  uwsm, sway, i3; bars: waybar, polybar; notifications/OSD: swaync, swayosd; rofi, dunst,
  picom, wlogout, networkmanager-dmenu
- **Prompt/history/nav:** starship, atuin, zoxide
- **Git:** git (`config.tmpl`, `delta.tmpl`, `ignore`), lazygit
- **Files/CLI:** bat, fd, btop, tealdeer
- **Dev:** mise, direnv, io.datasette.llm, vectorcode
- **System:** pacman, yay (Lua `init.lua` + `policy.lua` + `hooks/`; state in
  `~/.local/state/yay`), gtk-2.0/3.0 (3.0 omits `gtk-application-prefer-dark-theme` on Arch so
  `theme-mode` can switch GTK3 apps), `dot_Xresources`
- **GUI apps:** teams-for-linux (`modify_private_config.json` — jq sets only
  `appearance.followSystemTheme=true`, rest of the app's config untouched)

## Key file index

- `home/.chezmoi.toml.tmpl` — data/prompts/age/github/diff config
- `home/private_dot_config/mise/config.toml.tmpl` — the ~70-tool manifest
- `home/dot_zshenv` — sets `skip_global_compinit=1` (Ubuntu's `/etc/zsh/zshrc` would
  otherwise run its own compinit and clobber `~/.zcompdump`) + sources rustup's `~/.cargo/env`
- `home/dot_zshrc` — thin non-templated loader: autoloads `~/.zsh/functions/*`, sources
  `~/.zsh/rc.d/*.zsh` in numeric order
- `home/private_dot_zsh/exact_rc.d/` — zsh config snippets `10-env` … `60-aliases`; tool init
  (mise, fzf, zoxide, starship, atuin) in `50-tools.zsh.tmpl`; jira secret decrypt in
  `private_70-secrets.zsh.tmpl` (0600)
- `home/private_dot_zsh/exact_functions/` — autoloaded zsh functions (`csv`, `llm`, `f`, `t`,
  `cuda_switch.tmpl` — renders empty, so absent, on non-NVIDIA); fish mirrors these in
  `private_dot_config/fish/functions/*.fish`
- `home/private_dot_config/git/config.tmpl` — git identity (email templated by machine)
- `home/private_dot_local/private_bin/executable_theme-mode.tmpl` — Arch-only
  `~/.local/bin/theme-mode light|dark|toggle|get|apply`: sets gsettings `color-scheme` +
  `gtk-theme` (adw-gtk3/-dark) + `icon-theme` (Flat Remix Light/Dark); mode persists in
  dconf. Run with `apply` at Hyprland start (`hypr/execs.lua.tmpl`) and from the swaync
  "Dark Mode" toggle. Shell (waybar/swaync/rofi/hyprlock) and CLI apps are not switched.
