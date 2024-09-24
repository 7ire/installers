# !/bin/bash
# ------------------------------------------------------------------------------
#        /\        | Title: Tir3 Arch Linux - Installer                        |
#       /  \       |-----------------------------------------------------------|
#      /\   \      |     OS      | Arch Linux                                  |
#     /      \     | Description | Install Arch Linux system w/ user config    |
#    /   ,,   \    |    Owner    | Tir3                                        |
#   /   |  |  -\   |   GitHub    | https://github.com/atirelli3                |
#  /_-''    ''-_\  |   Version   | 0.1.0                                       |
# ------------------------------------------------------------------------------

# Configuration Parameters
#
# Customize these variables according to your preferences 
# to install the system as desired.
# ==============================================================================

# Preparation
#
# This section defines preparation settings for the installation, particularly for 
# optimizing package downloads by selecting the fastest mirrors using Reflector.
# Use the following command to assist in choosing appropriate countries.
#
# - 'reflector_countries': Set the countries from which to fetch the fastest mirrors.
#   To view available countries, you can run the command `reflector --list-countries`.
reflector_countries="Italy,Germany,France"  # Countries for mirror selection

# System
#
# This section defines essential system settings. 
# Use the following helper commands or file paths to find available options 
# for each parameter.
#
# - 'lang'    : List available locales, check /etc/locale.gen or run `locale -a`.
# - 'timezone': Find your timezone, use the command `timedatectl list-timezones`.
# - 'keyboard': View available layouts, use `localectl list-keymaps`.
hostname="archlinux"         # Hostname
lang="en_US.UTF-8"           # Language
timezone="America/New_York"  # Timezone
keyboard="us"                # Keyboard

# Disk
#
# This section defines the disk formatting parameters, including partitioning, encryption, 
# and filesystem setup. Use the following helper commands to assist in selecting values 
# for each parameter.
#
# - 'target': List avaible disk, use the command `lsblk -f`.
# - 'is_ssd': Know if the disk is type a SSD or an HDD. 
# Option avaible `yes/no`.
# (it this necessary to apply ssd optimization futher in the installation script)
#
# - 'encrypt'      : Encrypt the disk. Option avaible `yes/no`.
# - 'encrypt_type' : Choose the encryption type. Option avaible `luks/luks2`.
# - 'encrypt_key'  : Set the encryption key.
# - 'encrypt_label': Set the encryption device label.
#
# - 'part1_size' : Set the EFI partition size.
# - 'part1_mount': Set the mount point for the EFI partition.
# - 'part1_label': set the partition label for the EFI partition (use uppercase).
#
# - 'part2_fs'   : Set the filesystem type for the root partition.
# - 'part2_label': Set the partition label for the root partition.
#
# - 'btrfs_subvols'      : Set the Btrfs subvolumes.
# - 'btrfs_subvols_mount': Set the Btrfs subvolumes mount points.
# - 'btrfs_opts'         : Set the Btrfs mount options.
target="/dev/sda"         # Target disk
is_ssd="no"               # Is SSD disk?
encrypt="no"              # Encrypt disk?
encrypt_type="luks2"      # Encryption type
encrypt_key="changeme"    # Encryption key
encrypt_label="cryptdev"  # Encryption device label
part1_size="512M"         # EFI partition size
part1_mount="esp"         # Mount point
part1_label="ESP"         # Partition label
part2_fs="ext4"           # Filesystem type
part2_label="archlinux"   # Partition label
btrfs_subvols=(           # Btrfs subvolumes
  "libvirt"
  "docker"
  "flatpak"
  "distrobox"
  "containers"
)
btrfs_subvols_mount=(     # Btrfs subvolumes mount points
  "/var/lib/libvirt"
  "/var/lib/docker"
  "/var/lib/flatpak"
  "/var/lib/distrobox"
  "/var/lib/containers"
)
btrfs_opts=(              # Btrfs mount options
  "rw"
  "noatime"
  "compress-force=zstd:1"
  "space_cache=v2"
)

# Script body
# DO NOT TOUCH or EDIT THIS CODE - You can do it but at your own risk!
#
# Utilities function(s)
# ==============================================================================

# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  echo -e "\e[${color}m${message}\e[0m"
}
# Wrapper functions for specific colors
print_success() { print_debug "32" "$1"; }  # Success (green)
print_info() { print_debug "36" "$1";}      # Info (cyan)

# Checker
#
# This function checks if the script is being run with root privileges and 
# if the system is in UEFI mode.
# If either of these conditions is not met, the script terminates with 
# an error message.
checker() {
  # Checks if the script is run as root, otherwise exits
  [ "$EUID" -ne 0 ] && { echo "Please run as root. Aborting script."; exit 1; }
  # Checks if the system is in UEFI mode, otherwise exits
  [ -d /sys/firmware/efi/efivars ] || { echo "UEFI mode not detected. Aborting script."; exit 1; }
}

# Preparation
#
# This function prepares the system for installation by setting the keyboard layout,
# enabling NTP, updating the mirrorlist, and refreshing the package database(s).
# It also updates the Arch Linux keyring to ensure that package installations succeed.
#
# For more information on the values used for keyboard and reflector_countries, refer 
# to the 'Preparation' and 'System' sections in the Configuration Parameters.
preparation() {
  # Base preparation tasks
  loadkeys $keyboard  ## Set the keyboard layout
  ## Enable NTP (Network Time Protocol) for automatic time synchronization
  timedatectl set-ntp true &> /dev/null

  # Mirrorlist configuration
  ## Backup the current mirrorlist before updating
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
  ## Update the mirrorlist using Reflector to find the fastest mirrors from specified countries
  reflector --country "${reflector_countries}" \
            --protocol https \
            --age 6 \
            --sort rate \
            --save /etc/pacman.d/mirrorlist &> /dev/null

  # Configure package manager
  ## Enable parallel downloads in pacman configuration
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf 
  pacman -Syy &> /dev/null  ## Refresh the package database(s)
  ## Update the Arch Linux keyring to avoid issues with package signing
  pacman -S --noconfirm archlinux-keyring &> /dev/null
  ## Initialize the pacman keyring for verifying package signatures
  pacman-key --init &> /dev/null
  pacman -Syy &> /dev/null  ## Refresh the package database(s)
}


# Function(s)
# ==============================================================================

# Bootloader Configuration
bootloader() {}

# Kernel modules Configuration
init_ramdisk() {}

# System Configuration
#
# This function configures essential system settings such as the hostname, 
# locale, timezone, and keyboard layout.
# It directly modifies system files to ensure that these settings are 
# applied correctly.
#
# For more information on the values used for hostname, locale, timezone, 
# and keyboard layout, refer to the 'System' section in the 
# Configuration Parameters.
sys_conf() {
  # Set the system hostname
  echo "$hostname" > /etc/hostname  
  # Configure the /etc/hosts file for local hostname resolution
cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF

  # Uncomment the desired locale in /etc/locale.gen
  sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen
  # Set the system language/locale
  echo "LANG=${lang}" > /etc/locale.conf
  # Generate the locale configuration
  locale-gen &> /dev/null

  # Set the system timezone
  ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime &> /dev/null
  # Synchronize hardware clock with system clock
  hwclock --systohc &> /dev/null

  # Set the console keymap
  echo "KEYMAP=${keyboard}" > /etc/vconsole.conf
}

# Disk Configuration
disk_formatting() {
  # If the target disk is a NVMe disk, add 'p' to the target disk
  [[ $target =~ ^/dev/nvme[0-9]+n[0-9]+$ ]] && target_part="${target}p" || target_part="$target"

  # Make sure everything is unmounted before we start
  umount -A --recursive /mnt

  # Wipe data on the target disk
  wipefs -af "$target"                             # Wipe data from target disk
  sgdisk --zap-all --clear "$target" &> /dev/null  # Clear partition table from target disk
  sgdisk -a 2048 -o "$target" &> /dev/null         # Align target disk to 2048 sectors
  partprobe "$target" &> /dev/null                 # Update target disk info(s) and inform system

  # Fill target disk w/ random datas (security measure)
  cryptsetup open --type plain -d /dev/urandom $disk target &> /dev/null
  dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null
  cryptsetup close target

  # Partition the target disk
  sgdisk -n 0:0:+${part1_size} -t 0:ef00 -c 0:ESP $target &> /dev/null  # Partition 1: EFI System Partition
  sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $target &> /dev/null            # Partition 2: Root Partition (non-encrypted)
  partprobe "$target" &> /dev/null                                      # Update target disk info(s) and inform system

  # (optional) Encrypt partitions
  if [ "$encrypt" = "yes" ]; then
    sgdisk -t 2:8309 $target &> /dev/null  # Change partition 2 type to LUKS (for encryption)
    partprobe "$target" &> /dev/null       # Update target disk info(s) and inform system

    # Encrypt partition 2 using the provided key
    echo -n "$key" | cryptsetup --type luks2 -v -y luksFormat ${disk}p2 --key-file=- &> /dev/null
    # Open the encrypted partition
    echo -n "$key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${disk}p2 cryptdev --key-file=- &> /dev/null
    root_device="/dev/mapper/${encrypt_name}"  # Set the root device to the encrypted partition
  else
    root_device=${target_part}2         # Set the root device to the non-encrypted partition
  fi
}














# User
username="dummy"  # Username
password="dummy"  # Password
rootpwd="dummy"   # Root password

# User experience
de="gnome"     # Desktop environment - (gnome/kde)
use_wm="no"    # Use window manager? - (yes/no)
wm="hyprland"  # Window manager      - (hyprlad/dwm)

# ------------------------------------------------------------------------------



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
  partprobe $target                              # Update target disk info(s) and inform system
  
  # Fill target disk w/ random datas (security measure)
  echo YES | cryptsetup open --type plain -d /dev/urandom $target target &> /dev/null
  dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null
  cryptsetup close target

  # Create partitions
  sgdisk -n 0:0:+${part1_size} -t 0:ef00 -c 0:ESP $target &> /dev/null  # Partition 1: EFI System Partition
  sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $target &> /dev/null            # Partition 2: Root Partition (non-encrypted)
  partprobe $target &> /dev/null                                        # Update target disk info(s) and inform system

  # (optional) Encrypt partitions
  if [ "$encrypt" = "yes" ]; then
    sgdisk -t 2:8309 $target &> /dev/null  # Change partition 2 type to LUKS (for encryption)
    partprobe $target &> /dev/null         # Update target disk info(s) and inform system
  else
    root_device=${target_part}2         # Set the root device to the non-encrypted partition
  fi
}

# Script body
# =====================================
chekcer
print_success "The system is ready for installation."

print_info "[0]. Preparing the system for installation..."
preparation
print_success "[0]. The system is ready for installation."

print_info "[1]. Formatting the target disk..."
disk
print_success "[1]. The target disk has been formatted."