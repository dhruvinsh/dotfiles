#!/usr/bin/env bash
# Thunar dumps its whole accel map here on exit, so pass it through untouched and
# only pin the keys for the custom actions defined in uca.xml.
set -euo pipefail

ids=(1758162749013903-1 1758162749013903-2)
keys=('F4' '<Shift>F4') # Open Terminal Here, Open in Neovim

current=$(cat)
if [[ -n $current ]]; then
    pattern=$(
        IFS='|'
        echo "${ids[*]}"
    )
    grep -vE "uca-action-(${pattern})\"" <<<"$current" || true
fi
for i in "${!ids[@]}"; do
    printf '(gtk_accel_path "<Actions>/ThunarActions/uca-action-%s" "%s")\n' "${ids[$i]}" "${keys[$i]}"
done
