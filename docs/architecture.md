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
| `.github/workflows/lint.yml` | shellcheck + shfmt (triggers on `master`) |
| `scripts/shellcheck.bash`, `scripts/shfmt.bash` | Lint entrypoints used by CI |
| `scripts/chezmoi-template-check.bash` | Renders `*.tmpl` to catch template errors (hook) |
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
  `after_82_install-arch-eol-packages`, `after_88_install-fonts`
- `run_once_after_arch-privileged-setup` — sudo/privileged one-time setup

### `ubuntu/`
- `before_10_cleanup`, `before_11_install-ubuntu-packages`, `before_13_install-docker`
- `after_82_install-misc`, `after_88_install-go`, `after_89_install-tmux`,
  `after_90_wsl-ssh`, `after_91_install-rclone`
- `desktop/after_61_install-ubuntu-desktop-packages`,
  `desktop/after_62_install-ubuntu-desktop-emacs` (builds Emacs from source)

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
  into `.colorScheme.*` and re-injected into app configs (fzf, nvim, kitty, wezterm,
  lazygit, rofi, waybar, yazi, …).
- `encryption/{jira,geoclue}` — age-encrypted secret blobs; used via `| decrypt`.
- `llm/{keys.json.tmpl, extra-openai-models.yaml.tmpl, default_model.txt, litellm-key}` —
  Simon Willison `llm` CLI config.
- `scripts/{download_helpers.sh, service_helpers.sh}` — shared script functions.
- `python`, `mixture`, `hex2rgb` — helper snippets (e.g. python version resolution).
- `lazygit.yml.tmpl`, `yazi-theme.toml.tmpl` — themed config fragments.

## Externals (`home/.chezmoiexternals/`)

- `neovim.toml.tmpl` — nvim config as `git-repo` from `dhruvinsh/nvim` (+ `vnvim`
  archive variant, + neovide AppImage on non-Arch Linux desktop).
- `cli.toml.tmpl` — release binaries (atuin, delta, eza, semver, …) into `.local/bin`
  on non-Arch, non-Windows. Uses `gitHubLatestReleaseAssetURL`.
- `terminal.toml.tmpl`, `zsh.toml.tmpl` — terminal + zsh plugin externals.

## Conditional ignores (`home/.chezmoiignore.tmpl`)

Excludes by platform: Windows drops non-windows scripts/`.local`/zsh files; non-Windows
drops `AppData`/`Documents`; non-Linux drops fontconfig/wallpaper/bash; non-macOS drops
`Library`/darwin; non-Arch drops arch scripts + `hypr`; non-Ubuntu/non-Fedora drop their
script dirs; `.local/share/**` only kept on Ubuntu desktop.

## Managed app configs (`home/private_dot_config/`)

- **Shell/mux:** zsh (primary; `dot_zshrc.tmpl`), bash, fish, tmux, zellij
- **Terminals:** kitty, wezterm, ghostty (alacritty removed)
- **Wayland/WM:** hypr (Hyprland, Lua), sway, i3; bars: waybar, polybar; rofi, dunst,
  picom, wlogout
- **Prompt/history/nav:** starship, atuin, zoxide
- **Git:** git (`config.tmpl`, `delta.tmpl`, `ignore`), lazygit
- **Files/CLI:** yazi, bat, fd, btop, tealdeer
- **Dev:** mise, direnv, io.datasette.llm, vectorcode
- **System:** pacman, gtk-2.0/3.0, `dot_Xresources`

## Key file index

- `home/.chezmoi.toml.tmpl` — data/prompts/age/github/diff config
- `home/private_dot_config/mise/config.toml.tmpl` — the ~70-tool manifest
- `home/dot_zshrc.tmpl` — shell init (mise, fzf, zoxide, starship, atuin) + secret decrypt
- `home/private_dot_config/git/config.tmpl` — git identity (email templated by machine)
