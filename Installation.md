# Arch Linux installation

## Arch Installation:

Simply follow this steps/cmds to install arch linux with LTS kernel.

- Obtain latest iso image for Arch linux from [Here (latest version)](http://mirror.csclub.uwaterloo.ca/archlinux/iso/latest/archlinux-x86_64.iso) and boot to it.
- Verify EFI boot mode: `ls /sys/firmware/efi/efivars`. All of my system should be EFI.
- Connect to Internet via Ethernet or `iwctl`. In below example we are using wifi over wlan0 but we can have different network type
  ```bash
  iwctl
  device list
  station wlan0 scan
  station wlan0 get-networks
  station wlan0 connect "Name of Network/WiFi"
  ```
- Update the clock: `timedatectl set-ntp true`
- Disk partition:
  Mount Point Partition Partition Type Size

  _mnt/boot_ /dev/sda1 fat32 512MiB (1MiB to 512MiB)
  swap /dev/sda2 linux-swap 1.5GiB (512MiB to 2GiB)
  /mnt /dev/sda3 ext4 remaining (2GiB to 100%)

  Use `parted` to create the partitions

  ```bash
  parted /dev/sda -- mklabel gpt
  parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
  parted /dev/sda -- set 1 esp on
  parted /dev/sda -- mkpart primary linux-swap 512MiB 2GiB
  parted /dev/sda -- mkpart primary 2GiB 100%
  ```

  Formatting the disks:

  ```bash
  mkfs.fat -F 32 -n BOOT /dev/sda1
  mkswap -L SWAP /dev/sda2
  mkfs.ext4 -L ARCH /dev/sda3
  ```

- Mounting partitions:
  ```bash
  mount /dev/sda3 /mnt
  swapon /dev/sda2
  ```
- Install archlinux:
  ```bash
  pacstrap /mnt base base-devel linux-lts linux-firmware neovim sudo
  ```
- Fstab setup:

  ```bash
  genfstab -U /mnt >> /mnt/etc/fstab
  ```

- Change root: \~\~

  ```bash
  arch-chroot /mnt
  ```

- Zoneinfo update:

  ```bash
  ln -sf /usr/share/zoneinfo/America/Toronto /etc/localtime
  ```

- Localization: `nvim /etc/locale.gen` and un-comment
  `en_US.UTF-8 UTF-8` once that done generate locale by `locale-gen`

- Update language:

  ```bash
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
  export LANG=en_US.UTF-8
  ```

- Update hostname:

  ```bash
  echo "<hostname>" > /etc/hostname
  ```

- Update hosts file with `nvim /etc/hosts`:

  ```
  127.0.0.1     localhost
  ::1           localhost
  127.0.1.1     ds-laptop
  ```

- Setup root password: `passwd`

- Adding a user:

  ```bash
  useradd -m ds
  passwd ds
  usermod -aG wheel,audio,video,storage,power ds
  EDITOR=nvim visuod
  # uncomment this line: %wheel ALL=(ALL:ALL) ALL
  ```

- Install Grub

  ```bash
  pacman -S grub efibootmgr os-prober mtools
  mount --mkdir /dev/sda1 /boot/efi
  grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi
  grub-mkconfig -o /boot/grub/grub.cfg
  ```

- Install microcode and few extra essential software:

  ```bash
  pacman -S intel-ucode curl wget git xdg-user-dirs networkmanager
  ```

- Enable Some services

  ```bash
  systemctl enable NetworkManager
  ```

- Exit and shutdown

  ```bash
  exit
  umount -R /mnt
  swapoff /dev/sda2
  shutdown now
  ```

## Graphical Desktop/Windows manager Installation:

All packages installation are taken care by `chezmoi` so look at the [Arch Installation](home/.chezmoiscripts/linux/run_onchange_before_11_install-arch-packages.sh.tmpl) script.
