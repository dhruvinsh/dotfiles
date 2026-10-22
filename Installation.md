# Arch Linux installation

UEFI only. Arch goes on its **own disk** with its own ESP; any other OS (e.g. Ubuntu on
a second drive) is left untouched and booted from Arch's GRUB via a chainload entry.
The base install is scripted: [`scripts/arch-install.bash`](scripts/arch-install.bash).

Resulting system: `linux-lts`, btrfs (`@`, `@home`, `@log`, `@pkg`, zstd), ESP at `/boot`,
zram swap, GRUB, NetworkManager pinned to the permanent MAC.

## 1. Before: capture the old system (on the existing OS)

Run on the machine's current OS (e.g. Ubuntu), with a USB stick mounted:

```bash
bash scripts/capture-machine-info.bash /media/$USER/USB/machine-info
```

It records hostname, permanent Wi-Fi MAC, the active Wi-Fi profile (incl. 802.1X/EAP
details), proxy + corporate CA certificates, GPUs, disks/ESPs, and `efibootmgr -v`.
`secrets/` holds the NetworkManager profiles and certificates; delete it after install.

Check from the report:

- **Hostname** + **permanent MAC** of the Wi-Fi card: what the network whitelists.
- **Which disk is Ubuntu's** (model/serial): the Arch target must be the *other* one.
- **Secure Boot** (`mokutil --sb-state`): the Arch ISO doesn't boot with it on. Make
  sure you can get into firmware setup to disable it (IT-locked BIOS = stop here).
  Ubuntu keeps booting with Secure Boot off.
- **Proxy / custom CA** sections: if present, pacman and curl need them too.

## 2. Install (from the live ISO)

Boot the ISO in UEFI mode (firmware boot menu, often F12/F11/F8), then:

```bash
# Present the whitelisted identity BEFORE joining the network: the live ISO's DHCP
# client sends the hostname ("archiso" by default). The MAC is the card's own.
hostnamectl hostname <work-hostname>
ip link                                     # confirm the wlan MAC matches the report

iwctl station wlan0 connect "<SSID>"        # PSK networks
ping -c2 archlinux.org

curl -fsSLO https://raw.githubusercontent.com/dhruvinsh/dotfiles/main/scripts/arch-install.bash
lsblk -o NAME,SIZE,MODEL,SERIAL             # pick the NON-Ubuntu disk
bash arch-install.bash --disk /dev/nvme1n1 --hostname <work-hostname>
```

- Asks to retype the disk path, then root + user passwords.
- **Refuses** a disk whose ESP holds another OS's bootloader (protects the Ubuntu disk).
- A PSK network joined with `iwctl` is carried over to NetworkManager automatically.
  For WPA2-Enterprise (802.1X), mount the USB stick and add
  `--nm-import /path/to/machine-info/secrets`. Certificate paths inside the
  `.nmconnection` files must exist on Arch: copy the certs to the same paths,
  or edit `ca-cert=` after boot.

Then `umount -R /mnt && reboot`, and remove the USB stick.

### How dual boot works

- GRUB is installed to **Arch's ESP only**: NVRAM entry `GRUB` (made first in
  BootOrder) + the fallback `EFI/BOOT/BOOTX64.EFI` for firmware that forgets entries.
- Ubuntu gets a menu entry that **chainloads `EFI/ubuntu/shimx64.efi`** from Ubuntu's
  ESP (`/etc/grub.d/45_other_os`, matched by filesystem UUID). Ubuntu's own GRUB then
  boots Ubuntu, so Ubuntu kernel updates never make the entry stale, and it works even
  with an encrypted Ubuntu root. os-prober is not used.
- The firmware boot menu can still pick `ubuntu` directly.
- If an Ubuntu GRUB update ever puts `ubuntu` back first in BootOrder, fix it from Arch:
  `efibootmgr` (find GRUB's `BootXXXX`) then `sudo efibootmgr -o XXXX,YYYY`.

## 3. First boot: dotfiles

Log in on the TTY as your user:

```bash
nmcli device                                # Wi-Fi should already be connected
chezmoi init dhruvinsh --apply --exclude externals
chezmoi apply                               # second pass pulls the externals
sudo reboot                                 # SDDM -> Hyprland
```

`chezmoi init` asks: personal machine (work = `n`), light/dark, color scheme. It prompts
for the age passphrase once (decrypts `~/.key.txt`) and for sudo along the way; AUR
builds and `mise install` take a while.

Hardware handled automatically by the scripts:

- **NVIDIA driving the display**: driver, early KMS, Wayland env vars.
- **NVIDIA compute-only** (display on the iGPU, e.g. CUDA/LLM cards): driver +
  `nvidia-container-toolkit` + `nvidia-persistenced`, no DRM modesetting, no NVIDIA env
  vars. Hyprland stays on the iGPU.
- **Intel/AMD GPU**: Vulkan + VA-API drivers.
