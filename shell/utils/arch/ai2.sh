#!/usr/bin/bash
# print command before executing, and exit when any command fails
set -xe

hostname=arch
# regular user name
username=arch
# password for regular user. Password for root will not be set
password=123456

# Timezone
rm -f /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
hwclock --systohc --utc

# Locale
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen
sed -i 's/^#zh_CN.GB18030/zh_CN.GB18030/' /etc/locale.gen
sed -i 's/^#zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo $hostname > /etc/hostname

# Install intel-ucode for Intel CPU
is_intel_cpu=$(lscpu | grep 'Intel' &> /dev/null && echo 'yes' || echo '')
if [[ -n "$is_intel_cpu" ]]; then
  pacman -S --noconfirm intel-ucode --overwrite=/boot/intel-ucode.img
fi

# Bootloader
# Use system-boot for EFI mode, and grub for others
if [[ -d "/sys/firmware/efi/efivars" ]]; then
  bootctl install

  cat <<EOF > /boot/loader/entries/arch.conf
    title      Arch Linux
    linux      /vmlinuz-linux
    initrd     /intel-ucode.img
    initrd     /initramfs-linux.img
    options    root=/dev/sda2 rw
EOF

  cat <<EOF > /boot/loader/loader.conf
    default arch
    timeout 3
    editor no
EOF

  if [[ -z "$is_intel_cpu" ]]; then
    sed -i '/intel-ucode/d' /boot/loader/entries/arch.conf
  fi

  # remove leading spaces
  sed -i 's#^ \+##g' /boot/loader/entries/arch.conf
  sed -i 's#^ \+##g' /boot/loader/loader.conf

  # modify root partion in loader conf
  root_partition=$(mount | grep 'on / ' | cut -d' ' -f1)
  root_partition=$(df / | tail -1 | cut -d' ' -f1)
  sed -i "s#/dev/sda2#$root_partition#" /boot/loader/entries/arch.conf
else
  disk=$(df / | tail -1 | cut -d' ' -f1 | sed 's#[0-9]\+##g')
  pacman --noconfirm -S grub os-prober
  grub-install --target=i386-pc "$disk"
  grub-mkconfig -o /boot/grub/grub.cfg
fi

# Config sudo
# allow users of group wheel to use sudo
sed -i 's/^# %wheel ALL=(ALL) ALL$/%wheel ALL=(ALL) ALL/' /etc/sudoers

# Create regular user
# useradd -m -g users -G wheel -s /bin/bash $username
# echo "$username:$password" | chpasswd
echo "root:pwd" | chpasswd


# compression/decompression tools
pacman -S --noconfirm unrar p7zip

# useful shell utils
pacman -S --noconfirm bash-completion openssh

# Use vim instead vi
ln -s /usr/bin/vim /usr/local/bin/vi

systemctl enable dhcpcd

systemctl enable sshd


