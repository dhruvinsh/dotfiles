#!/usr/bin/env bash
#
# Validate that chezmoi Go templates render without error.
# Renders each given template with the current machine's chezmoi data.
#
# Skipped on purpose:
#   - home/.chezmoi.toml.tmpl      -> uses interactive prompts (promptBool/promptChoice)
#   - home/.chezmoiexternals/*     -> would hit the network (gitHubLatestReleaseAssetURL)
#   - home/.chezmoitemplates/*     -> include-partials, not valid standalone
#
# Passing files come from prek (changed *.tmpl). With no args, validates the whole tree.
set -uo pipefail

files=("$@")
if [ ${#files[@]} -eq 0 ]; then
  mapfile -t files < <(find home -type f -name '*.tmpl')
fi

status=0
for f in "${files[@]}"; do
  case "$f" in
    home/.chezmoi.toml.tmpl) continue ;;
    home/.chezmoiexternals/*) continue ;;
    home/.chezmoitemplates/*) continue ;;
  esac
  [ -f "$f" ] || continue
  if ! err=$(chezmoi execute-template <"$f" 2>&1 1>/dev/null); then
    printf 'chezmoi template error: %s\n%s\n\n' "$f" "$err" >&2
    status=1
  fi
done
exit "$status"
