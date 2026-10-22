#!/usr/bin/env bash
#
# Run on the EXISTING OS (e.g. Ubuntu) of a machine that is about to get Arch, to record
# everything the new install has to reproduce -- above all for networks that whitelist
# by hostname + MAC.
#
#   bash scripts/capture-machine-info.bash [OUTDIR]     (default: ./machine-info-<host>)
#
# OUTDIR/secrets/ holds Wi-Fi passwords/certificates: keep it on a USB stick you control,
# and delete it after the install.
set -uo pipefail

HOST=$(hostname)
OUT=${1:-./machine-info-$HOST}
mkdir -p "$OUT/secrets"
chmod 700 "$OUT/secrets"
REPORT="$OUT/report.txt"

section() { printf '\n===== %s =====\n' "$1" >>"$REPORT"; }
run() {
  printf '$ %s\n' "$*" >>"$REPORT"
  "$@" >>"$REPORT" 2>&1
}

: >"$REPORT"
section "Identity (use the SAME hostname on Arch: --hostname)"
run hostnamectl
run cat /etc/hostname
run grep -v '^#' /etc/hosts

section "Network interfaces -- permanent (burned-in) MAC vs current"
for nic in /sys/class/net/*; do
  name=$(basename "$nic")
  [ "$name" = lo ] && continue
  perm=$(ethtool -P "$name" 2>/dev/null | awk '{print $NF}')
  wireless=no
  [ -d "$nic/wireless" ] && wireless=yes
  printf '%-16s current=%s permanent=%s wireless=%s driver=%s\n' "$name" \
    "$(cat "$nic/address")" "${perm:-?}" "$wireless" \
    "$(basename "$(readlink "$nic/device/driver" 2>/dev/null)" 2>/dev/null)" >>"$REPORT"
done
run ip -br addr

section "NetworkManager: active connections + MAC randomization settings"
run nmcli -f NAME,UUID,TYPE,DEVICE connection show --active
while IFS=: read -r uuid type; do
  case "$type" in *wireless* | *ethernet*) ;; *) continue ;; esac
  run nmcli -f connection.id,connection.interface-name,802-11-wireless.ssid,802-11-wireless.mac-address,802-11-wireless.cloned-mac-address,802-11-wireless-security.key-mgmt,802-1x.eap,802-1x.phase2-auth,802-1x.identity,802-1x.anonymous-identity,802-1x.ca-cert,802-1x.client-cert,802-1x.domain-suffix-match,ipv4.method,ipv4.dhcp-hostname,ipv4.dhcp-send-hostname,ipv4.dns,ipv4.addresses,ipv4.gateway connection show "$uuid"
done < <(nmcli -t -f UUID,TYPE connection show --active)
run grep -rh . /etc/NetworkManager/NetworkManager.conf /etc/NetworkManager/conf.d/

section "DNS / proxy (corporate proxies break pacman/curl if missed)"
run resolvectl status
run sh -c 'env | grep -i _proxy'
run grep -rh . /etc/apt/apt.conf.d/ --include='*proxy*'
run cat /etc/environment

section "Corporate CA certificates (TLS inspection)"
run ls -l /usr/local/share/ca-certificates/
if compgen -G "/usr/local/share/ca-certificates/*" >/dev/null; then
  mkdir -p "$OUT/ca-certificates"
  cp -r /usr/local/share/ca-certificates/. "$OUT/ca-certificates/"
fi

section "Hardware"
run lscpu
run lspci -nnk
run lsusb
run cat /sys/class/dmi/id/sys_vendor /sys/class/dmi/id/product_name /sys/class/dmi/id/chassis_type
for d in /sys/bus/pci/devices/*; do
  [ -f "$d/boot_vga" ] && printf 'GPU %s vendor=%s boot_vga=%s\n' "$(basename "$d")" \
    "$(cat "$d/vendor")" "$(cat "$d/boot_vga")" >>"$REPORT"
done

section "Disks, ESPs and boot (pick the Arch --disk from this; never the Ubuntu one)"
run lsblk -o NAME,SIZE,TYPE,FSTYPE,PARTTYPENAME,LABEL,UUID,MOUNTPOINTS,MODEL,SERIAL
run findmnt -no SOURCE,FSTYPE /
run findmnt -no SOURCE /boot/efi
run cat /etc/fstab
run cat /etc/crypttab
run efibootmgr -v
run mokutil --sb-state
run grep -v '^#' /etc/default/grub
run lsb_release -a

section "Locale / time / keyboard"
run timedatectl
run localectl

# Secrets: NetworkManager profiles (root-only) + any certificates they reference.
if sudo -v; then
  sudo cp /etc/NetworkManager/system-connections/*.nmconnection "$OUT/secrets/" 2>/dev/null
  sudo grep -hoE '^(ca-cert|client-cert|private-key|phase2-ca-cert)=.*' \
    /etc/NetworkManager/system-connections/*.nmconnection 2>/dev/null |
    cut -d= -f2- | sed 's|^file://||' | sort -u | while read -r cert; do
    sudo cp "$cert" "$OUT/secrets/" 2>/dev/null && echo "copied cert: $cert" >>"$REPORT"
  done
  sudo chown -R "$(id -u):$(id -g)" "$OUT/secrets"
  chmod 600 "$OUT/secrets"/* 2>/dev/null
fi

echo "Wrote $REPORT"
ls -la "$OUT" "$OUT/secrets"
