# Artix Linux

## 0. Installation preparation

In this phase we are gonna perform some **best-practice** step to a good Artix Linux installation.

The following steps are:

- Set keyboard layout with `loadkeys us`.
- Enable and activate **Network Time Protocol** by using **OpenNTP**.
- Pacman configuration for faster download and refreshing the mirrorlist with [**rate-mirrors**](https://github.com/westandskif/rate-mirrors) script.

> [!IMPORTANT]
> For the `loadkeys` command it is used a default value of `us`. To list avaible layouts `localectl list-keymaps`.

> [!WARNING]
> To the correct execution of the commands to update mirrorlist with [**rate-mirrors**](https://github.com/westandskif/rate-mirrors) script, make sure to have it installed and to have installed an AUR Helper like **paru** or **yay**.

``` bash
# Set the keyboard layout
loadkeys us

# Enable Network Time Protocol - OpenNTP
ln -s /etc/runit/sv/openntpd /run/runit/service  # Link the service
sv up openntpd                                   # Start the service

# Update mirrorlist - rate-mirrors
rate-mirrors --protocol https --allow-root --disable-comments --disable-comments-in-file --save /etc/pacman.d/mirrorlist artix
pacman -Syy # Refresh database(s)

# Tweak pacman
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf  # Enable parrallel downloads in pacman
# Update keyrings
pacman -S --noconfirm archlinux-keyring artix-keyring  # Download updated keyring(s)
pacman-key --init                                      # Initialize keyring(s)
pacman -Syy                                            # Refresh database(s)
```

## 1. Disk formatting where Artix Linux will be install

Now we are gonna prepare the desired target disk where we want Artix Linux to be installed.

The following steps are:

- Installing base tool like `gptfdisk` to be able to use the command `sgdisk`.
- Clean all data inside the target disk.
- (optional) Fill the disk with random data for security reason.
- Disk partitioning

There are more steps based on if you want to **encrypt** the disk and also if the disk is formatted as **ext4** or **btrfs** filesystem that are shown after in more details.

> [!IMPORTANT]
> Adopt the following command with the correct **target disk** and the *size* of the **EFI partition**.
> For convience it is used `/dev/sda` as target disk and `512MiB` as the size of the EFI partition.

``` bash
# Install dependecy packages - 'sgdisk'
pacman -S --noconfirm gptfdisk

# Clean all data inside the disk
wipefs -af /dev/sda                # Wipe data from target disk
sgdisk --zap-all --clear /dev/sda  # Clear partition table from target disk
partx /dev/sda                     # Update target disk info(s) and inform system

# (optional) Fill the disk w/ random datas
cryptsetup open --type plain -d /dev/urandom /dev/sda target
dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct
cryptsetup close target

# Partition the target disk
sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:ESP /dev/sda  # Partition 1: EFI System Partition
sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs /dev/sda     # Partition 2: Root Partition (non-encrypted)

# Update target disk info(s) and inform system
partx /dev/sda
```

### 1.1 Disk encryption

This step is optional, but it is reccomended for more security of the device.

We are going to encrypt the disk as:

- **LUKS2** (reccomended)
- **LUKS**

``` bash
# Change partition 2 type to LUKS (for encryption)
sgdisk -t 2:8309 /dev/sda
# Update target disk info(s) and inform system
partx /dev/sda
# Encrypt partition 2 using a master key
cryptsetup --type luks2 -v -y luksFormat /dev/sda2 --key-file=-
# Open the encrypted partition
cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent /dev/sda2 cryptdev --key-file=-
```