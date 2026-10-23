#!/usr/bin/env bash
#
# Base Arch Linux install, run from the official live ISO (UEFI only).
#
#   curl -fsSLO https://raw.githubusercontent.com/dhruvinsh/dotfiles/main/scripts/arch-install.bash
#   bash arch-install.bash --disk /dev/nvme1n1 --hostname my-host [--user ds]
#
# Layout (mirrors the existing machines):
#   p1  1 GiB  FAT32  ESP, mounted at /boot (kernels + GRUB live here)
#   p2  rest   btrfs  subvolumes @ / @home / @log / @pkg, zstd compression
#   swap: zram (zram-generator), no swap partition
#
# Dual boot: ONLY --disk is touched. Any other disk's ESP (e.g. Ubuntu on a second
# drive) is detected read-only and gets a GRUB *chainload* entry, which hands off to
# that OS's own bootloader. Unlike os-prober entries, these don't go stale when the
# other OS updates its kernel, and they work if the other OS's root is encrypted.
#
# Wi-Fi: a PSK network joined with iwctl in the live ISO is carried over to
# NetworkManager, so the installed system reconnects on first boot. NetworkManager is
# pinned to the permanent MAC (no randomization) for MAC-whitelisted networks.
#
# Non-interactive use (testing): ROOT_PASSWORD / USER_PASSWORD env vars and --yes.
set -euo pipefail
shopt -s extglob

DISK=""
NEW_HOSTNAME=""
USERNAME="ds"
TIMEZONE="America/Toronto"
MIRROR_COUNTRIES="CA,US"
NM_IMPORT_DIR=""
ASSUME_YES=0

ESP_GUID="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
BTRFS_OPTS="rw,relatime,compress=zstd:3,space_cache=v2"

usage() {
  cat <<EOF
Usage: $0 --disk /dev/XXX --hostname NAME [options]

  --disk DEV         target disk -- will be ERASED entirely
  --hostname NAME    hostname (use the whitelisted one on MAC/hostname-filtered Wi-Fi)
  --user NAME        login user (default: $USERNAME)
  --timezone TZ      default: $TIMEZONE
  --mirrors LIST     reflector mirror countries (default: $MIRROR_COUNTRIES)
  --nm-import DIR    copy *.nmconnection files from DIR (e.g. exported from Ubuntu)
  --yes              skip the confirmation prompt
EOF
  exit 1
}

log() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
die() {
  printf '\033[1;31mERROR: %s\033[0m\n' "$*" >&2
  exit 1
}

while [ $# -gt 0 ]; do
  case "$1" in
    --disk) DISK="$2" && shift ;;
    --hostname) NEW_HOSTNAME="$2" && shift ;;
    --user) USERNAME="$2" && shift ;;
    --timezone) TIMEZONE="$2" && shift ;;
    --mirrors) MIRROR_COUNTRIES="$2" && shift ;;
    --nm-import) NM_IMPORT_DIR="$2" && shift ;;
    --yes) ASSUME_YES=1 ;;
    *) usage ;;
  esac
  shift
done

if [ -z "$DISK" ] || [ -z "$NEW_HOSTNAME" ]; then usage; fi

# partition N of $DISK: /dev/sda -> /dev/sda1, /dev/nvme0n1 -> /dev/nvme0n1p1
part() {
  if [[ "$DISK" =~ [0-9]$ ]]; then echo "${DISK}p$1"; else echo "${DISK}$1"; fi
}

# ---------------------------------------------------------------------------
log "Pre-flight checks"
[ "$(id -u)" -eq 0 ] || die "run as root (from the Arch live ISO)"
[ -d /sys/firmware/efi/efivars ] || die "not booted in UEFI mode"
[ -b "$DISK" ] || die "$DISK is not a block device"
[ "$(lsblk -dno TYPE "$DISK")" = disk ] || die "$DISK is not a whole disk"
[ -e "/usr/share/zoneinfo/$TIMEZONE" ] || die "unknown timezone $TIMEZONE"
if lsblk -nrpo MOUNTPOINTS "$DISK" | grep -q .; then
  die "$DISK has mounted partitions (is it the live USB?)"
fi
curl -fsS --max-time 10 -o /dev/null https://archlinux.org || die "no internet -- connect first (iwctl)"

# The ISO's own reflector run sorts mirrors by sync age, not speed, so a slow or stalled
# mirror can end up first ("Operation too slow"). Replace it with the fastest recent
# HTTPS mirrors; pacstrap copies this mirrorlist into the new system too.
log "Selecting fast mirrors ($MIRROR_COUNTRIES)"
systemctl stop reflector.service 2>/dev/null || true
reflector --protocol https --country "$MIRROR_COUNTRIES" --age 12 --latest 20 \
  --fastest 8 --download-timeout 5 --save /etc/pacman.d/mirrorlist ||
  echo "reflector failed -- keeping the ISO's mirrorlist"
grep -m 3 '^Server' /etc/pacman.d/mirrorlist

# pacstrap verifies packages against the live ISO's keyring, which pacman-init.service
# builds in the background after boot. Wait for it, build it here if it never appeared,
# then refresh archlinux-keyring so an older ISO trusts the current packager keys.
log "Preparing the pacman keyring"
for _ in {1..30}; do
  systemctl is-active --quiet pacman-init.service && break
  sleep 2
done
if [ ! -r /etc/pacman.d/gnupg/pubring.gpg ] || [ ! -r /etc/pacman.d/gnupg/trustdb.gpg ]; then
  pacman-key --init
  pacman-key --populate archlinux
fi
pacman -Sy --needed --noconfirm archlinux-keyring

# Other operating systems' ESPs: never on the target disk.
# Each entry: "<menu title>|<fs uuid>|<loader path>"
foreign_entries=()
scan_dir=$(mktemp -d)
while read -r dev parttype uuid pkname; do
  [ "$parttype" = "$ESP_GUID" ] || continue
  [ "/dev/$pkname" = "$DISK" ] && continue
  mount -o ro "$dev" "$scan_dir" 2>/dev/null || continue
  for candidate in \
    "Ubuntu|EFI/ubuntu/shimx64.efi" \
    "Ubuntu|EFI/ubuntu/grubx64.efi" \
    "Fedora|EFI/fedora/shimx64.efi" \
    "Windows Boot Manager|EFI/Microsoft/Boot/bootmgfw.efi"; do
    title="${candidate%%|*}"
    loader="${candidate#*|}"
    if [ -f "$scan_dir/$loader" ]; then
      # one entry per OS per ESP (shim preferred over plain grub)
      if ! printf '%s\n' "${foreign_entries[@]}" | grep -q "^$title on $dev|"; then
        foreign_entries+=("$title on $dev|$uuid|/$loader")
      fi
    fi
  done
  umount "$scan_dir"
done < <(lsblk -nrpo NAME,PARTTYPE,UUID,PKNAME | awk 'NF == 4')
rmdir "$scan_dir"

# Refuse to wipe a disk that itself carries another OS's bootloader.
if lsblk -nrpo NAME,PARTTYPE "$DISK" | grep -q "$ESP_GUID"; then
  esp_check=$(mktemp -d)
  while read -r dev parttype; do
    [ "$parttype" = "$ESP_GUID" ] || continue
    if mount -o ro "$dev" "$esp_check" 2>/dev/null; then
      if compgen -G "$esp_check/EFI/@(ubuntu|Microsoft|fedora)" >/dev/null; then
        umount "$esp_check"
        die "$DISK ($dev) has an ESP with another OS's bootloader -- wrong disk?"
      fi
      umount "$esp_check"
    fi
  done < <(lsblk -nrpo NAME,PARTTYPE "$DISK" | awk 'NF == 2')
  rmdir "$esp_check"
fi

echo
lsblk -o NAME,SIZE,TYPE,FSTYPE,LABEL,MODEL
echo
echo "Target disk : $DISK ($(lsblk -dno SIZE,MODEL "$DISK" | xargs)) -- WILL BE ERASED"
echo "Hostname    : $NEW_HOSTNAME"
echo "User        : $USERNAME"
echo "Timezone    : $TIMEZONE"
if [ ${#foreign_entries[@]} -gt 0 ]; then
  echo "GRUB will chainload (read-only, untouched):"
  printf '  - %s\n' "${foreign_entries[@]%%|*}"
else
  echo "No other OS bootloaders found on other disks."
fi
if [ "$ASSUME_YES" -ne 1 ]; then
  read -rp "Type the disk path again to erase it: " confirm
  [ "$confirm" = "$DISK" ] || die "confirmation did not match"
fi

if [ -z "${ROOT_PASSWORD:-}" ]; then
  read -rsp "Root password: " ROOT_PASSWORD && echo
fi
if [ -z "${USER_PASSWORD:-}" ]; then
  read -rsp "Password for $USERNAME: " USER_PASSWORD && echo
fi

# ---------------------------------------------------------------------------
log "Partitioning $DISK"
timedatectl set-ntp true
wipefs -af "$DISK"
sgdisk --zap-all "$DISK"
sgdisk -n 1:0:+1G -t 1:ef00 -c 1:ARCH_ESP \
  -n 2:0:0 -t 2:8300 -c 2:ARCH_ROOT "$DISK"
partprobe "$DISK"
udevadm settle

ESP=$(part 1)
ROOT=$(part 2)
mkfs.fat -F 32 -n ARCH_ESP "$ESP"
mkfs.btrfs -f -L ARCH "$ROOT"

log "Creating btrfs subvolumes"
mount "$ROOT" /mnt
for sv in @ @home @log @pkg; do btrfs subvolume create "/mnt/$sv"; done
umount /mnt
mount -o "$BTRFS_OPTS,subvol=/@" "$ROOT" /mnt
mount --mkdir -o "$BTRFS_OPTS,subvol=/@home" "$ROOT" /mnt/home
mount --mkdir -o "$BTRFS_OPTS,subvol=/@log" "$ROOT" /mnt/var/log
mount --mkdir -o "$BTRFS_OPTS,subvol=/@pkg" "$ROOT" /mnt/var/cache/pacman/pkg
mount --mkdir "$ESP" /mnt/boot

# ---------------------------------------------------------------------------
log "Installing base system"
ucode=()
grep -q GenuineIntel /proc/cpuinfo && ucode=(intel-ucode)
grep -q AuthenticAMD /proc/cpuinfo && ucode=(amd-ucode)

pacstrap -K /mnt \
  base base-devel linux-lts linux-lts-headers linux-firmware sof-firmware "${ucode[@]}" \
  btrfs-progs dosfstools grub efibootmgr zram-generator \
  networkmanager iwd wireless-regdb openssh \
  sudo git curl wget unzip zsh vim man-db man-pages chezmoi

genfstab -U /mnt >>/mnt/etc/fstab

# ---------------------------------------------------------------------------
log "Configuring system"
ln -sf "/usr/share/zoneinfo/$TIMEZONE" /mnt/etc/localtime
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" >/mnt/etc/locale.conf
echo "KEYMAP=us" >/mnt/etc/vconsole.conf
echo "$NEW_HOSTNAME" >/mnt/etc/hostname
cat >/mnt/etc/hosts <<EOF
127.0.0.1     localhost
::1           localhost
127.0.1.1     $NEW_HOSTNAME
EOF

printf '[zram0]\n' >/mnt/etc/systemd/zram-generator.conf

echo '%wheel ALL=(ALL:ALL) ALL' >/mnt/etc/sudoers.d/10-wheel
chmod 0440 /mnt/etc/sudoers.d/10-wheel

# Hostname/MAC-whitelisted networks: always present the burned-in MAC (also while
# scanning), and send the hostname in DHCP (NetworkManager's default, made explicit).
mkdir -p /mnt/etc/NetworkManager/conf.d
cat >/mnt/etc/NetworkManager/conf.d/20-permanent-mac.conf <<'EOF'
[device]
wifi.scan-rand-mac-address=no

[connection]
wifi.cloned-mac-address=permanent
ethernet.cloned-mac-address=permanent
ipv4.dhcp-send-hostname=true
ipv6.dhcp-send-hostname=true
EOF

# Wi-Fi profiles: explicit NetworkManager exports win; otherwise convert the PSK
# networks iwd joined in this live session.
NM_CONN_DIR=/mnt/etc/NetworkManager/system-connections
mkdir -p "$NM_CONN_DIR"
if [ -n "$NM_IMPORT_DIR" ]; then
  cp -v "$NM_IMPORT_DIR"/*.nmconnection "$NM_CONN_DIR"/
else
  for psk in /var/lib/iwd/*.psk; do
    [ -f "$psk" ] || continue
    ssid=$(basename "$psk" .psk)
    # iwd hex-encodes SSIDs with special characters as =<hex>
    if [[ "$ssid" == =* ]]; then ssid=$(echo "${ssid#=}" | xxd -r -p); fi
    pass=$(sed -n 's/^Passphrase=//p' "$psk")
    if [ -z "$pass" ]; then
      echo "Skipping $ssid: no Passphrase= in $psk (re-add it with nmtui after boot)"
      continue
    fi
    cat >"$NM_CONN_DIR/$ssid.nmconnection" <<EOF
[connection]
id=$ssid
type=wifi

[wifi]
mode=infrastructure
ssid=$ssid

[wifi-security]
key-mgmt=wpa-psk
psk=$pass

[ipv4]
method=auto

[ipv6]
method=auto
EOF
    echo "Carried over Wi-Fi network: $ssid"
  done
  for other in /var/lib/iwd/*.8021x; do
    [ -f "$other" ] && echo "NOTE: enterprise network $(basename "$other") not converted -- use --nm-import"
  done
fi
chmod 600 "$NM_CONN_DIR"/*.nmconnection 2>/dev/null || true

# GRUB: kernel cmdline matches the existing machines (zram replaces zswap).
sed -i -E \
  -e 's/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="zswap.enabled=0 rootfstype=btrfs"/' \
  -e 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=5/' \
  -e 's/^#?GRUB_TIMEOUT_STYLE=.*/GRUB_TIMEOUT_STYLE=menu/' \
  /mnt/etc/default/grub
# GRUB >= 2.16 adds an "(EFI BootNext)" entry for every firmware boot entry (DVD, PXE,
# shell, ...). The chainload entries below cover the other OSes, so keep the menu clean.
echo 'GRUB_DISABLE_BOOTNEXT=true' >>/mnt/etc/default/grub

if [ ${#foreign_entries[@]} -gt 0 ]; then
  {
    echo '#!/bin/sh'
    echo '# Generated by arch-install.bash: chainload other OSes from their own ESPs.'
    # shellcheck disable=SC2016 # literal $0 for the generated grub.d script
    echo 'exec tail -n +4 $0'
    for entry in "${foreign_entries[@]}"; do
      IFS='|' read -r title uuid loader <<<"$entry"
      cat <<EOF
menuentry '$title' --class os {
    insmod part_gpt
    insmod fat
    insmod chain
    search --no-floppy --fs-uuid --set=root $uuid
    chainloader $loader
}
EOF
    done
  } >/mnt/etc/grub.d/45_other_os
  chmod 755 /mnt/etc/grub.d/45_other_os
fi

arch-chroot /mnt /bin/bash -e <<EOF
hwclock --systohc
locale-gen
useradd -m -G wheel,audio,video,storage,power,input -s /bin/bash "$USERNAME"
mkinitcpio -P

# NVRAM entry "GRUB" (put first in BootOrder) + the fallback path EFI/BOOT/BOOTX64.EFI,
# for firmware that forgets NVRAM entries. Both live on this disk's own ESP.
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --removable
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager.service systemd-timesyncd.service fstrim.timer
EOF

printf 'root:%s\n%s:%s\n' "$ROOT_PASSWORD" "$USERNAME" "$USER_PASSWORD" | arch-chroot /mnt chpasswd

# ---------------------------------------------------------------------------
log "Done"
echo "GRUB menu entries:"
grep -E "^(menuentry|submenu)" /mnt/boot/grub/grub.cfg | cut -d"'" -f2 | sed 's/^/  - /'
echo
efibootmgr | grep -E '^Boot(Order|[0-9A-F]{4})'
cat <<EOF

Next:
  umount -R /mnt && reboot
  log in as $USERNAME, check Wi-Fi (nmcli device), then bootstrap the dotfiles:
    chezmoi init dhruvinsh --apply --exclude externals && chezmoi apply
EOF
