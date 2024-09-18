#        /\        
#       /  \       | Title: Tir3 Artix Linux (runit) - Installer               |
#      /`'.,\      |-----------------------------------------------------------|
#     /     ',     |     OS      | Artix Linux (runit init-system)             |
#    /      ,`\    | Description | Install Artix Linux system w/ user config   |
#   /   ,.'`.  \   |    Owner    | Tir3                                        |
#  /.,'`     `'.\  |   GitHub    | https://github.com/7ire                     |



# Configuration parameters
# ------------------------------------------------------------------------------

# System
hostname="artix"  # Hostname



# Locale
lang="en_US.UTF-8"           # Language
timezone="America/New_York"  # Timezone
keyboard="us"                # Keyboard layout



# Disk
target="/dev/sda"      # Target disk     -    'lsblk'
is_ssd="no"            # Is SSD disk?    -   (yes/no)

# Encryption
encrypt="no"              # Encrypt disk?   -   (yes/no)
encrypt_type="luks2"      # Encryption type - (luks/luks2)
encrypt_key="changeme"    # Encryption key
encrypt_label="cryptdev"  # Encryption device label

## partition 1 - EFI
part1_size="512M"        # EFI partition size
part1_mount="esp"        # Mount point
part1_label="ESP"        # Partition label (use uppercase)

## partition 2 - root
part2_fs="ext4"          # Filesystem type - (ext4/btrfs)
part2_label="artixlinux" # Partition label

### Btrfs additional components
btrfs_subvols=(          # Btrfs subvolumes
  "libvirt"
  "docker"
  "containers"
)
btrfs_subvols_mount=(    # Btrfs subvolumes mount points (RESPECT THE ORDER OF THE SUBVOLUMES)
  "/var/lib/libvirt"
  "/var/lib/docker"
  "/var/lib/containers"
)
btrfs_opts=(             # Btrfs mount options
  "rw"
  "noatime"
  "compress-force=zstd:1"
  "space_cache=v2"
)

# User
username="dummy"  # Username
password="dummy"  # Password
rootpwd="dummy"   # Root password

# User experience
de="gnome"     # Desktop environment - (gnome/kde)
use_wm="no"    # Use window manager? - (yes/no)
wm="hyprland"  # Window manager      - (hyprlad/dwm)

# ------------------------------------------------------------------------------

# Intallation Script 
#
# DON'T TOUCH THE CODE BELOW
# ------------------------------------------------------------------------------

# Utilities
# =====================================

# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  echo -e "\e[${color}m${message}\e[0m"
}
# Wrapper functions for specific colors
print_success() { print_debug "32" "$1"; }  # Success (green)
print_info() { print_debug "36" "$1";}      # Info (cyan)

# Function(s)
# =====================================

# Checker
chekcer() {
  [ "$EUID" -ne 0 ] && { echo "Please run as root. Aborting script."; exit 1; }                     # If script is not run as root, exit
  [ -d /sys/firmware/efi/efivars ] || { echo "UEFI mode not detected. Aborting script."; exit 1; }  # If UEFI mode is not detected, exit
}

# [0] Preparation
#
# Tasks:
# - Set the keyboard layout
# - Enable NTP
# - Enable parrallel downloads
# - Update the mirrorlist to use the fastest mirrors in specified countries
# - Download updated keyring(s) and initialize it
preparation() {
  loadkeys $keyboard                               # Set the keyboard layout
  # Enable NTP
  ln -s /etc/runit/sv/openntpd /run/runit/service  # Link the service
  sv up openntpd                                   # Start the service
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf  # Enable parrallel downloads
  pacman -Syy &> /dev/null                         # Refresh database(s)
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup  # Backup the current mirrorlist
  # Update the mirrorlist to use the fastest mirrors
  rate-mirrors --protocol https --allow-root --disable-comments --disable-comments-in-file --save /etc/pacman.d/mirrorlist artix
  pacman -Syy &> /dev/null                         # Refresh database(s)
  pacman -S --noconfirm archlinux-keyring artix-keyring &> /dev/null  # Download updated keyring(s)
  pacman-key --init         # Initialize keyring(s)
  pacman -Syy &> /dev/null  # Refresh database(s)
}

# [1] Disk format
#
# Tasks:
# - Check if the target disk is a NVMe disk
# - Wipe data in the target disk
# - Fill the target disk with random data
# - Create partitions
# - (optional) Encrypt partitions
# - Format partitions
# - Mount partitions
disk() {
  # If target is a NVMe disk, add 'p' to the target disk if is NVMe
  [[ $target =~ ^/dev/nvme[0-9]+n[0-9]+$ ]] && target_part="${target}p" || target_part="$target"

  # Wipe data in the target disk
  pacman -S --noconfirm gptfdisk &> /dev/null    # Install dependecy packages - 'sgdisk'
  wipefs -af $target                             # Wipe data from target disk
  sgdisk --zap-all --clear $target &> /dev/null  # Clear partition table from target disk
  partx $target                                  # Update target disk info(s) and inform system

  # Fill target disk w/ random datas (security measure)
  echo YES | cryptsetup open --type plain -d /dev/urandom $target target &> /dev/null
  dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null
  cryptsetup close target

  # Partition the target disk
  sgdisk -n 0:0:+${part1_size} -t 0:ef00 -c 0:ESP $target &> /dev/null  # Partition 1: EFI System Partition
  sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $target &> /dev/null            # Partition 2: Root Partition (non-encrypted)
  partx $target &> /dev/null                                            # Update target disk info(s) and inform system

  # (optional) Encrypt partitions
  if [ "$encrypt" = "yes" ]; then
    sgdisk -t 2:8309 $target &> /dev/null      # Change partition 2 type to LUKS (for encryption)
    partx $target &> /dev/null                 # Update target disk info(s) and inform system
    # Encrypt partition 2 using the provided key
    echo -n "$encrypt_key" | cryptsetup --type $encrypt_type -v -y luksFormat ${target_part}2 --key-file=- &> /dev/null
    # Open the encrypted partition
    echo -n "$encrypt_key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${target_part}2 $encrypt_name --key-file=- &> /dev/null
    root_device="/dev/mapper/${encrypt_name}"  # Set the root device to the encrypted partition
  else
    root_device=${target_part}2         # Set the root device to the non-encrypted partition
  fi
}






# [1.1] Create support variables
if [ "$encrypt" = "yes" ]; then
  # Change partition 2 type to LUKS (for encryption)
  sgdisk -t 2:8309 $target &> /dev/null
  # Update target disk info(s) and inform system
  partx $target &> /dev/null

  # Encrypt partition 2 using the provided key
  # TODO: controllare per le opzioni di YES e doppia pwd insert
  echo -n "$encrypt_key" | cryptsetup --type $encrypt_type -v -y luksFormat ${target_part}2 --key-file=- &> /dev/null
  # Open the encrypted partition
  echo -n "$encrypt_key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${target_part}2 $encrypt_name --key-file=- &> /dev/null
  root_device="/dev/mapper/${encrypt_name}"  # Set the root device to the encrypted partition
else
  root_device=${target_part}2         # Set the root device to the non-encrypted partition
fi

# [1.2] Format partitions
mkfs.vfat -F32 -n $part1_label ${target_part}1 &> /dev/null  # Partition 1: EFI System Partition
# Partition 2: Root Partition
if [ $part2_fs = "btrfs" ]; then
  mkfs.btrfs -L $part2_label $root_device &> /dev/null  # BTRFS
else
  mkfs.ext4 -L $part2_label $root_device &> /dev/null   # EXT4
fi

# Mount partitions
mkdir -p /mnt/$part1_mount               # Create mount point for EFI partition
mount ${target_part}1 /mnt/$part1_mount  # Mount EFI partition
mount $root_device /mnt                  # Mount root partition

if [ $part2_fs = "btrfs" ]; then
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
  umount /mnt
  # Set mount options for Btrfs subvolumes
  sv_opts=$(IFS=,; echo "${btrfs_opts[*]}")
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

  # Mount additional subvolumes
  for i in "${!btrfs_subvols[@]}"; do
    mkdir -p /mnt${btrfs_subvols_mount[$i]}
    mount -o ${sv_opts},subvol=@${btrfs_subvols[$i]} $root_device /mnt${btrfs_subvols_mount[$i]}
  done
fi

# For ext4 filesystem there is no need other operations



# [2]. Install Artix Linux base system
# Install base system packages
basestrap -i base base-devel \
  runit elogind-runit \
  linux-zen linux-zen-headers linux-firmware \
  grub efibootmgr \
  networkmanager networkmanager-runit \
  cryptsetup lvm2 lvm2-runit \
  vim \
  &> /dev/null

genfstab -U /mnt >> /mnt/etc/fstab  # Generate fstab
artix-chroot /mnt bash              # Chroot into the new system
pacman -Syy &> /dev/null            # Refresh database(s)



# [3]. Artix Linux system configuration
# Timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Hostname
echo $hostname > /etc/hostname

# Local hostname resolution
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF

# Locale
sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen    # Uncomment the desired locale in /etc/locale.gen
echo "LANG=${lang}" > /etc/locale.conf          # Set the system language/locale
locale-gen &> /dev/null                         # Generate the locale configuration
echo "KEYMAP=${keyboard}" > /etc/vconsole.conf  # Set the console keymap

# User
echo "root:$rootpwd" | chpasswd                                               # Set the root password
useradd -m -G wheel -s /bin/bash "$username"                                  # Add a new user and assign to 'wheel' group with bash shell
echo "$username:$userpwd" | chpasswd                                          # Set password for the new user
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers  # Enable 'wheel' group users to use sudo

# Configure pacman
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf  # Enable parallel downloads
sed -i 's/^#Color/Color/' /etc/pacman.conf                          # Enable colored output
sed -i '/^Color/a ILoveCandy' /etc/pacman.conf                      # Fancy progress bar
pacman -Syy &> /dev/null                                            # Refresh database(s)

# Network
ln -s /etc/runit/sv/NetworkManager /etc/runit/runsvdir/current  # Enable NetworkManager service

# Network Time Protocol
pacman -S --noconfirm openntpd &> /dev/null               # Install OpenNTP
ln -s /etc/runit/sv/openntpd /etc/runit/runsvdir/current  # Enable OpenNTP service

# TODO: mkinitcpio
# TODO: bootloader

