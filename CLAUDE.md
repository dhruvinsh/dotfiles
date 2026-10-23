# CLAUDE.md

Personal dotfiles managed by [chezmoi](https://chezmoi.io). Multi-OS: Arch (primary,
Hyprland/Wayland), Ubuntu (incl. WSL + desktop), Fedora, macOS, Windows.
Owner: Dhruvin Shah (`dhruvinsh`). Deeper reference in [`docs/`](docs/).

## Critical layout facts

- **Source root is `home/`**, not the repo root — set by `.chezmoiroot`. All target
  files, scripts, templates, and data live under `home/`.
- The **repo root** (this dir) holds meta/CI only: `README.md`, `Installation.md`,
  `.pre-commit-config.yaml`, `.github/`, `scripts/`, helper `.py` files.
- Chezmoi version pin: `.chezmoiversion` (2.62.4).

## Chezmoi naming conventions (in `home/`)

- `dot_foo` → `~/.foo`; `private_` → not world-readable; `empty_` → allow empty file.
- `*.tmpl` → Go-templated. `*.age` → age-encrypted.
- `.chezmoiscripts/` → `run_once_` / `run_onchange_`, staged `before_`/`after_`,
  numbered (`10_`…`91_`) for ordering. Organized by OS subdir.
- `.chezmoitemplates/` → reusable snippets (`includeTemplate`).
- `.chezmoiexternals/` → external assets (git repos, release binaries, archives).
- `.chezmoidata.yaml` → static data: `openscadVersion`, `workMonitors.{left,right}` (work-PC
  monitor descriptions used by hypr + waybar).
- `.chezmoiignore.tmpl` → conditional per-OS/per-machine exclusions.

## Template data (from `home/.chezmoi.toml.tmpl`)

Prompted: `personalmachine` (bool), `colorVariant` (light/dark), `colorScheme`
(catppuccin | rose-pine | tokyonight | nvonedark | onedark | moonfly) — last two use
`promptChoiceOnce` (persisted).

Auto-detected: `wsl`/`wsl1`/`wsl2`, `archlinux`/`ubuntu`/`fedora`, `isDesktop`
(XDG_CURRENT_DESKTOP), `sshSession` (SSH_CONNECTION), `chassisType`
(laptop/desktop/vm), `pythonVersion` (latest `3.14.x`, looked up from the actions/python-versions manifest).

Derived: `email` = `dhruvin3@gmail.com` if personal else `dshah@evertz.com`.
`.font.regular` = JetBrainsMono NF, `.font.italic` = Maple Mono NF.
`.colorScheme.*` palette auto-loaded from `.chezmoitemplates/colors/<scheme>.jsonc.tmpl`.

## Secrets

- Encryption: **age**, identity `~/.key.txt`, recipient in `.chezmoi.toml.tmpl`.
- Encrypted key bootstrapped by `run_once_before_decrypt-private-key.*` per OS.
- Encrypted template snippets: `.chezmoitemplates/encryption/{jira,geoclue}`,
  `.chezmoitemplates/llm/{keys.json.tmpl,litellm-key}` → consumed via `... | decrypt`.
- Never commit plaintext secrets. `gitleaks` runs as a pre-commit hook.

## Tooling center of gravity

- **mise** (`home/private_dot_config/mise/config.toml.tmpl`) manages ~70 dev tools
  (languages, LSPs, linters, formatters, AI CLIs). Installed by
  `.chezmoiscripts/non-windows/run_onchange_after_90_install-mise.sh.tmpl`.
- OS package installs are the numbered `run_onchange_before_1x_install-*` scripts.
- Neovim config is external: pulled from `github.com/dhruvinsh/nvim` via
  `.chezmoiexternals/neovim.toml.tmpl` (branch `main` = full, `vnvim` = minimal).

## Working here

- Edit files under `home/` (the source), then `chezmoi apply` / `chezmoi diff`.
- Shell scripts must pass `scripts/shellcheck.bash` and `scripts/shfmt.bash` (CI).
- Lua formatted by stylua (`.stylua.toml`); markdown code blocks by cbfmt (`.cbfmt.toml`).
- After editing a `.tmpl`, sanity-check with `chezmoi execute-template < file` or
  `chezmoi cat <target>`.

## Local automation

- **Subagents** (`.claude/agents/`):
  - `doc-sync` — after changing repo structure, run it to correct drift in `CLAUDE.md` +
    `docs/architecture.md` (it edits only those two files).
  - `chezmoi-reviewer` — read-only review of script/template/secret changes before commit.
- **Git hooks** via `prek` (pinned in mise), config `.pre-commit-config.yaml`: gitleaks,
  shellcheck + shfmt (plain `*.sh`/`*.bash` only), and chezmoi template validation
  (`scripts/chezmoi-template-check.bash`, renders changed `*.tmpl`; skips the config
  template, externals, and `.chezmoitemplates` partials). Enable once with `prek install`.
  Note: `.sh.tmpl` scripts aren't shell-linted (template syntax); template *rendering* is
  validated instead.

## Gotchas

- README `chezmoi init` uses `--exclude externals` on first apply (externals pulled after).
- Two `82_` scripts coexist in `arch/` (docker + eol-packages) — same stage, both run.
- Hyprland runs a Lua config and reaps its children, so `os.execute()` always fails there (`nil, "No child processes"`) — don't use it for probes; `io.open` is safe.
- uwsm does not export `UWSM_ACTIVE`; detect it via `UWSM_FINALIZE_VARNAMES` (as `hypr/execs.lua` does), and use `uwsm check is-active` in scripts.
- Legacy `hyprctl dispatch <name> args` is rejected in Lua mode — use `hyprctl dispatch 'hl.dsp.x({...})'`; `hl.dsp.dpms()` with a missing/unknown action toggles the display.
- hyprlang (hyprlock/hypridle/hyprpaper): `#` starts a comment (write `##` for a literal `#`),
  and `{{ ... }}` is parsed as an arithmetic expression — put such commands in a script.
  A hyprlock label whose `text` fails to parse renders "Sample Text".
