# !/bin/bash
# ------------------------------------------------------------------------------
#        /\        | Title: Tir3 Arch Linux - Installer                        |
#       /  \       |-----------------------------------------------------------|
#      /\   \      |     OS      | Arch Linux                                  |
#     /      \     | Description | Install Arch Linux system w/ user config    |
#    /   ,,   \    |    Owner    | Tir3                                        |
#   /   |  |  -\   |   GitHub    | https://github.com/7ire                     |
#  /_-''    ''-_\  |   Version   | 0.1.0                                       |
# ------------------------------------------------------------------------------
#
# Configuration Parameters
#
# Customize these variables according to your preferences 
# to install the system as desired.
# ==============================================================================
#
# System
#
# This section defines essential system settings. 
# Use the following helper commands or file paths to find available options 
# for each parameter.
# - 'lang': to list available locales, check /etc/locale.gen or run `locale -a`.
# - 'timezone': to find your timezone, use the command `timedatectl list-timezones`.
# - 'keyboard': to view available layouts, use `localectl list-keymaps`.
hostname="archlinux"         # Hostname
lang="en_US.UTF-8"           # Language
timezone="America/New_York"  # Timezone
keyboard="us"                # Keyboard
#
# Disk
# - 'target': to list avaible disk, use the command `lsblk -f`.
# - 'is_ssd': to know if the disk is type a SSD or an HDD. 
# Option avaible `yes/no`.
# (it this necessary to apply ssd optimization futher in the installation script)
# 
target="/dev/sda"         # Target disk
is_ssd="no"               # Is SSD disk?

#
# Script body
# DO NOT TOUCH or EDIT THIS CODE - You can do it but at your own risk!
#
# Utilities function(s)
# ==============================================================================
#
# Output debug message with color
print_debug() {
  local color="$1"
  local message="$2"
  echo -e "\e[${color}m${message}\e[0m"
}
# Wrapper functions for specific colors
print_success() { print_debug "32" "$1"; }  # Success (green)
print_info() { print_debug "36" "$1";}      # Info (cyan)
#
# Checker
#
# This function checks if the script is being run with root privileges and 
# if the system is in UEFI mode.
# If either of these conditions is not met, the script terminates with 
# an error message.
checker() {
  [ "$EUID" -ne 0 ] && { echo "Please run as root. Aborting script."; exit 1; }                     # Checks if the script is run as root, otherwise exits
  [ -d /sys/firmware/efi/efivars ] || { echo "UEFI mode not detected. Aborting script."; exit 1; }  # Checks if the system is in UEFI mode, otherwise exits
}
#
# Function(s)
# ==============================================================================
#
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












# Disk
target="/dev/sda"         # Target disk     -    'lsblk'
is_ssd="no"               # Is SSD disk?    -   (yes/no)
## encryption
encrypt="no"              # Encrypt disk?   -   (yes/no)
encrypt_type="luks2"      # Encryption type - (luks/luks2)
encrypt_key="changeme"    # Encryption key
encrypt_label="cryptdev"  # Encryption device label
## partition 1 - EFI
part1_size="512M"         # EFI partition size
part1_mount="esp"         # Mount point
part1_label="ESP"         # Partition label (use uppercase)
## partition 2 - root
part2_fs="ext4"           # Filesystem type - (ext4/btrfs)
part2_label="archlinux"   # Partition label
### Btrfs additional components
btrfs_subvols=(           # Btrfs subvolumes
  "libvirt"
  "docker"
  "flatpak"
  "distrobox"
  "containers"
)
btrfs_subvols_mount=(     # Btrfs subvolumes mount points (RESPECT THE ORDER OF THE SUBVOLUMES)
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
  loadkeys $keyboard                     # Set the keyboard layout
  timedatectl set-ntp true &> /dev/null  # Enable NTP
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf # Enable parrallel downloads
  pacman -Syy &> /dev/null               # Refresh database(s)
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup  # Backup the current mirrorlist
  # Update the mirrorlist to use the fastest mirrors in specified countries
  reflector --country 'Italy,France,Germany' --protocol https --age 6 --sort rate --save /etc/pacman.d/mirrorlist &> /dev/null
  pacman -Syy &> /dev/null               # Refresh database(s)
  pacman -S --noconfirm archlinux-keyring &> /dev/null  # Download updated keyring(s)
  pacman-key --init &> /dev/null         # Initialize the pacman keyring
  pacman -Syy &> /dev/null               # Refresh database(s)
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