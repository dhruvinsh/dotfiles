### Before installing Arch Linux, make sure your computer is connected to the internet.
```
dhcpcd
ping -c 3 archlinux.org
```
If none is available, stop the dhcpcd service with systemctl stop dhcpcd@<TAB> and see Network configuration. https://wiki.archlinux.org/index.php/Network_configuration#Device_driver

### Disk Partition

| /dev/sda | size | mount point |
|----------|------|-------------|
| sda1     | 15G  | /           |
| sda2     | 1G   | swap        |

```
lsblk
cfdisk /dev/sda
```
Format the sda partition sda to above table in dos mode, making sure that appropriate partition is marked as bootable.
```
mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

# Swap partition
mkswap /dev/sda2
swapon /dev/sda2
```

### Choose closest mirror list
```
pacman -Sy
pacman -S reflector
reflector --verbose -l 5 --sort rate --save /etc/pacman.d/mirrorlist
```
Install arch linux base packages
```
pacstrap -i /mnt base base-devel
```

### Configure Fstab and chroot /mnt
```
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
arch-chroot /mnt
```

### Configure language and location
```
vi /etc/locale.gen  # uncomment: en_US.UTF-8 UTF8 
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
```

### Set time zone
```
ln -s /usr/share/zoneinfo/America/Toronto > /etc/localtime
hwclock --systohc --utc
```

### Configure the repository
```
vi /etc/pacman.conf
Uncomment the line: [multilib] and include = /etc/pacman.d/mirrorlist
pacman -Sy
```

### Set hostname and network
```
echo linux-fanboy > /etc/hostname

Add matching entries to hosts(5):
vi /etc/hosts
127.0.0.1	localhost
::1		localhost
127.0.1.1	myhostname.localdomain	myhostname

systemctl enable dhcpcd
```

### Set root password and create new user
```
passwd
pacman -S sudo bash-completion
useradd -m -g users -G wheel,storage,power -s /bin/bash henri
passwd henri
# Allow the users in wheel group to be able to preformance administrative tasks with sudo:
EDITOR=vi visudo
# Uncomment the line: %wheel ALL=(ALL)
```

### Install and configure bootloader
```
mkinitcpio -p linux
pacman -S grub os-prober
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

### Setup openssh-server
```
pacman -S openssh
systemctl enable sshd
```

### Unmount the partitions and reboot
```
exit
umount -R /mnt
reboot
```

### i3 installation in virtual box
```
sudo pacman -S xorg xorg-apps xorg-xinit i3 playerctl xf86-video-vesa xf86-input-libinput xf86-input-vmmouse xf86-video-fbdev xf86-video-vmware dmenu
```
now update the .xinitrc with 'exec i3'
```
echo "exec i3" >> ~/.xinitrc
```
Auto login to i3 session, run below command one time
```
printf 'if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then\n  exec startx\nfi' >> .bash_profile
```
