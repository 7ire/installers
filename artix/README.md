# Artix Linux

Keyboard

``` bash
loadkeys us
```

NTP - OpenNTP

``` bash
ln -s /etc/runit/sv/openntpd /run/runit/service
sv up openntpd
pacman -Syy
```

Pacman configuration and keyrings

``` bash
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
pacman -S --noconfirm archlinux-keyring artix-keyring
pacman-key --init
pacman -Syy
```

Clean disk

``` bash
pacman -S --noconfirm gptfdisk
wipefs -af /dev/sda
sgdisk --zap-all --clear /dev/sda
partx /dev/sda
```

Fill with random data

``` bash
cryptsetup open --type plain -d /dev/urandom /dev/sda target
dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct
cryptsetup close target
```

Partition disk

1. ESP Partition
2. Root Partition

``` bash
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:ESP /dev/sda
sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs /dev/sda
```

(Optional) If encrypt change to lusk

``` bash
sgdisk -t 2:8309 /dev/sda
cryptsetup --type luks2 -v -y luksFormat /dev/sda2 --key-file=-
cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent /dev/sda2 cryptdev --key-file=-
```

Format partitions

1. FAT32
2. Ext4 / BTRFS

``` bash
mkfs.vfat -F32 -n ESP /dev/sda1
mkfs.ext4 -L artixlinux /dev/sda2
# OR
mkfs.btrfs -L artixlinux /dev/sda2
```

Mount partitions

``` bash
mkdir /mnt/esp
mount /dev/sda1 /mnt/esp
mount /dev/sda2 /mnt
```