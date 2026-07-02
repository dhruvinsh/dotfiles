#!/usr/bin/env bash
#
# Lint the plain shell scripts. Templated scripts (*.sh.tmpl) contain Go template
# syntax that shellcheck cannot parse; their template correctness is covered by
# scripts/chezmoi-template-check.bash instead.
set -euo pipefail

mapfile -t files < <(find home/.chezmoiscripts -type f -name '*.sh')

exec shellcheck -s bash -x "${files[@]}" scripts/*.bash
