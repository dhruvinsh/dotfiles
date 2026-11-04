# CLAUDE.md

chezmoi dotfiles (multi-OS). **This is a working guide for agents, not the
architecture reference.** Full repo map (install pipeline, templates, externals,
data, app configs) lives in `docs/architecture.md` — consult it before deep work.

## Layout

- Source root is `home/` (set by `.chezmoiroot`), not the repo root.
- Repo root holds meta/CI only.
- Chezmoi version pinned in `.chezmoiversion`.

## Rules

- Never commit plaintext secrets (age-encrypted; identity `~/.key.txt`).
- Edit under `home/`, then `chezmoi apply` / `chezmoi diff`.
- Shell scripts must pass `scripts/shellcheck.bash` and `scripts/shfmt.bash`.
- Lua via stylua (`.stylua.toml`); markdown code blocks via cbfmt (`.cbfmt.toml`).
- After editing a `.tmpl`, sanity-check with `chezmoi execute-template < file`
  or `chezmoi cat <target>`.

## Automation

- Subagents: `doc-sync` (fix CLAUDE.md/architecture drift after structural
  changes), `chezmoi-reviewer` (pre-commit review of script/template/secret changes).
- Git hooks via `prek` (enable once: `prek install`): gitleaks, shellcheck/shfmt,
  and chezmoi template rendering for changed `*.tmpl`.
