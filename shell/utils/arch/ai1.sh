#!/usr/bin/bash
# print command before executing, and exit when any command fails
set -xe

# Update the system clock
#timedatectl set-ntp true

device=/dev/sda

parted $device mklabel msdos -s
parted $device mkpart primary ext4 1M 500M
parted $device set 1 boot on
parted $device mkpart primary linux-swap 500 3G
parted $device mkpart primary ext4 3G 100%

yes | mkfs.ext4 /dev/sda1
yes | mkfs.ext4 /dev/sda3
mkswap /dev/sda2

mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
swapon /dev/sda2

echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist

pacman -Syy

# Install the base packages
pacstrap /mnt base base-devel linux dhcpcd #linux-firmware 

# Generate fstab
genfstab /mnt >> /mnt/etc/fstab

# Setup new system
curl -k https://s.d.ucode.cc/ai2.sh -o /mnt/ai2.sh
chmod +x /mnt/ai2.sh
arch-chroot /mnt /ai2.sh

if [[ "$?" == "0" ]]; then
  echo "Finished successfully."
  read -r -p "Reboot now? [Y/n]" confirm
  if [[ ! "$confirm" =~ ^(n|N) ]]; then
    reboot
  fi
fi
