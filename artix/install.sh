#        /\        
#       /  \       | Title: Tir3 Artix Linux (runit) - Installer             |
#      /`'.,\      |---------------------------------------------------------|
#     /     ',     |     OS      | Artix Linux (runit init-system)           |
#    /      ,`\    | Description | Install Artix Linux system w/ user config |
#   /   ,.'`.  \   |    Owner    | Tir3                                      |
#  /.,'`     `'.\  |   GitHub    | https://github.com/7ire                   |



# Configuration parameters
# -----------------------------------------------------------------------------

# System
hostname="artix"  # Hostname

# Locale
lang=""        # Language
timezone=""    # Timezone
keyboard="us"  # Keyboard layout

# Disk
target="/dev/sda"      # Target disk     -    'lsblk'
is_ssd="no"            # Is SSD disk?    -   (yes/no)
encrypt="no"           # Encrypt disk?   -   (yes/no)
type="lusk2"           # Encryption type - (lusk/lusk2)
key="changeme"         # Encryption key
## partition 1 - EFI
espsize="512M"         # EFI partition size
espmountpt="esp"       # Mount point
esplabel="boot"        # Partition label
## partition 2 - root
filesystem="ext4"      # Filesystem type - (ext4/btrfs)
rootlabel="artixlinux" # Partition label
btrfssubvols=(         # Btrfs subvolumes
  "libvirt"
  "docker"
  "container"
)
btrfsopts=(            # Btrfs mount options
  "rw"
  "noatime"
  "compress-force=zstd:1"
  "space_cache=v2"
)

# User
username="dummy"  # Username
password="dummy"  # Password
rootpass="dummy"  # Root password

# User experience
de="gnome"     # Desktop environment - (gnome/kde)
use_wm="no"    # Use window manager? - (yes/no)
wm="hyprland"  # Window manager      - (hyprlad/dwm)


# Script body
# -----------------------------------------------------------------------------

# Check if root
[ "$EUID" -ne 0 ] && { echo "Please run as root. Aborting script."; exit 1; }
# Check if UEFI
[ -d /sys/firmware/efi/efivars ] || { echo "UEFI mode not detected. Aborting script."; exit 1; }

# [0]. Preparation to install Artix
loadkeys $keyboard              # Set the keyboard layout
# Enable OpenNTP
ln -s /etc/runit/sv/openntpd /run/runit/service
sv up openntpd
pacman -Syy &> /dev/null        # Refresh database(s)

# Enable parrallel downloads in pacman
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
# Update keyrings
pacman -S --noconfirm archlinux-keyring artix-keyring &> /dev/null # (Archlinux)
pacman-key --init &>            # Initialize keyring(s)
pacman -Syy &> /dev/null        # Refresh database(s)



# [1]. Format disk where Artix will be install
pacman -S --noconfirm gptfdisk &> /dev/null    # Install dependecy packages - 'sgdisk'
wipefs -af $target                             # Wipe data from target disk
sgdisk --zap-all --clear $target &> /dev/null  # Clear partition table from target disk
partx $target &> /dev/null                     # Update target disk info(s) and inform system

# Fill target disk w/ random data (security measure)
echo YES | cryptsetup open --type plain -d /dev/urandom $target target
dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null
cryptsetup close target

# Partition the target disk
sgdisk -n 0:0:+${espsize} -t 0:ef00 -c 0:ESP $target &> /dev/null  # Partition 1: EFI System Partition
sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $target &> /dev/null         # Partition 2: Root Partition (non-encrypted)

# If target is encrypted
if [ "$encrypt" = "yes" ]; then
  sgdisk -t 2:8309 $disk &> /dev/null  # Change partition 2 type to LUKS (for encryption)
fi

# Update target disk info(s) and inform system
partx $target &> /dev/null

# Create support variables
if [ "$encrypt" = "yes" ]; then
  # Encrypt partition 2 using the provided key
  echo -n "$key" | cryptsetup --type luks2 -v -y luksFormat ${target}p2 --key-file=- &> /dev/null
  # Open the encrypted partition
  echo -n "$key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${target}p2 cryptdev --key-file=- &> /dev/null
  # Set the root device to the encrypted partition
  root_device="/dev/mapper/cryptdev"
else
  root_device="${disk}p2"
fi

# Format partitions
mkfs.vfat -F32 -n ESP ${target}p1 &> /dev/null  # Partition 1: EFI System Partition
# Partition 2: Root Partition
if [ "filesystem" = "btrfs" ]; then
  mkfs.btrfs -L $label $root_device &> /dev/null  # BTRFS
else
  mkfs.ext4 -L $label $root_device &> /dev/null   # EXT4
fi

# Mount partitions
mkdir /mnt/$espmountpt
mount ${target}p1 /mnt/$espmountpt &> /dev/null  # Mount EFI partition
mount $root_device /mnt &> /dev/null             # Mount root partition

if [ "filesystem" = "btrfs" ]; then
  # Create Btrfs subvolumes for system and data segregation
  btrfs subvolume create /mnt/@ &> /dev/null           # Main system subvolume
  btrfs subvolume create /mnt/@home &> /dev/null       # Home directory subvolume
  btrfs subvolume create /mnt/@snapshots &> /dev/null  # Snapshots subvolume
  btrfs subvolume create /mnt/@cache &> /dev/null      # Cache subvolume
  btrfs subvolume create /mnt/@log &> /dev/null        # Log files subvolume
  btrfs subvolume create /mnt/@tmp &> /dev/null        # Temporary files subvolume

  # Create additional Btrfs subvolumes
  for subvol in "${btrfssubvols[@]}"; do
    btrfs subvolume create /mnt/@$subvol &> /dev/null
  done

  # Unmount the root device to remount with options
  umount /mnt &> /dev/null
  # Set mount options for Btrfs subvolumes
  sv_opts=""
  # Remount the main system subvolume
  mount -o ${sv_opts},subvol=@ $root_device /mnt &> /dev/null

  # Create mount points for additional subvolumes
  mkdir -p /mnt/{home,.snapshots,var/cache,var/log,var/tmp} &> /dev/null

  # Mount subvolumes
  mount -o ${sv_opts},subvol=@home $root_device /mnt/home
  mount -o ${sv_opts},subvol=@snapshots $root_device /mnt/.snapshots
  mount -o ${sv_opts},subvol=@cache $root_device /mnt/var/cach
  mount -o ${sv_opts},subvol=@log $root_device /mnt/var/log
  mount -o ${sv_opts},subvol=@tmp $root_device /mnt/var/tmp
else
  # TODO: ext4 additional steps
fi


# [2]. Install Artix Linux base system
basestrap -i base base-devel \
  runit elogind-runit \
  linux-zen linux-zen-headers linux-firmware \
  grub efibootmgr \
  networkmanager networkmanager-runit \
  cryptsetup lvm2 lvm2-runit \
  vim \
  &> /dev/null

# [3]. Artix Linux system configuration
artix-chroot /mnt bash
# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
# Timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc
# Hostname
echo $hostname > /etc/hostname
# Locale
sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen
echo "LANG=${lang}" > /etc/locale.conf
locale-gen