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

# ^-^-^-^-^-^-^-^-^-^        Configuration Parameters        ^-^-^-^-^-^-^-^-^-^
#
# Customize these variables according to your preferences 
# to install the system as desired.
# ==============================================================================

# Preparation settings for installation
#
# Optimizes package downloads by selecting the fastest mirrors using Reflector.
#
# - reflector_countries: Countries used to fetch the fastest mirrors.
#   To list available countries, use `reflector --list-countries`.
reflector_countries="Italy,Germany,France"  # Selected countries for mirror optimization

# System settings
#
# Defines essential system configuration options.
#
# - hostname : Sets the system hostname.
# - lang     : System language, available locales can be listed with `locale -a` or found in /etc/locale.gen.
# - timezone : Set the timezone. Use `timedatectl list-timezones` to view available options.
# - keyboard : Keyboard layout. List available layouts with `localectl list-keymaps`.
hostname="archlinux"         # System hostname
lang="en_US.UTF-8"           # Locale for system language
timezone="America/New_York"  # System timezone
keyboard="us"                # Keyboard layout

# Disk settings
#
# Defines disk partitioning, encryption, and filesystem setup.
#
# - target        : Target disk. Use `lsblk -f` to list available disks.
# - is_ssd        : Specifies if the disk is an SSD (yes/no). Used for SSD optimization later.
# - encrypt       : Encrypt the disk (yes/no).
# - encrypt_type  : Encryption type (luks/luks2).
# - encrypt_key   : Encryption key.
# - encrypt_label : Label for the encrypted device.
# - part1_size    : Size of the EFI partition.
# - part1_mount   : Mount point for the EFI partition.
# - part1_label   : Label for the EFI partition (use uppercase).
# - part2_fs      : Filesystem type for the root partition.
# - part2_label   : Label for the root partition.
# - btrfs_subvols : Btrfs subvolumes.
# - btrfs_subvols_mount: Mount points for the Btrfs subvolumes.
# - btrfs_opts    : Mount options for Btrfs.
target="/dev/sda"         # Target disk
is_ssd="no"               # Is the disk an SSD?
encrypt="no"              # Enable disk encryption?
encrypt_type="luks2"      # Type of encryption
encrypt_key="changeme"    # Encryption key
encrypt_label="cryptdev"  # Label for the encrypted device
part1_size="512MiB"       # EFI partition size
part1_mount="esp"         # EFI partition mount point
part1_label="ESP"         # Label for the EFI partition
part2_fs="ext4"           # Filesystem type for the root partition
part2_label="archlinux"   # Label for the root partition
# Btrfs subvolumes and their mount points
btrfs_subvols=(           
  "libvirt"
  "docker"
  "flatpak"
  "distrobox"
  "containers"
)
btrfs_subvols_mount=(     
  "/var/lib/libvirt"
  "/var/lib/docker"
  "/var/lib/flatpak"
  "/var/lib/distrobox"
  "/var/lib/containers"
)
# Btrfs mount options
btrfs_opts=(              
  "rw"
  "noatime"
  "compress-force=zstd:1"
  "space_cache=v2"
)

# Driver settings
#
# Defines the drivers to be installed for CPU and GPU.
# - cpu : Specifies the CPU driver to use (intel/amd).
# - gpu : Specifies the GPU driver to use (intel/nvidia).
cpu="intel"   # CPU driver selection
gpu="nvidia"  # GPU driver selection



# User
rootpwd="dummy"   # Root password
username="dummy"  # Username
password="dummy"  # Password

# ^-^-^-^-^-^-^-^        End of Configuration Parameters         ^-^-^-^-^-^-^-^



# ^-^-^-^-^-^-^-^-^-^-^-^-^        Script Core         ^-^-^-^-^-^-^-^-^-^-^-^-^
#
# !DISCLAMER!: DO NOT TOUCH or EDIT THIS CODE 
# - You can do it but at your own risk!
#
# Constant(s)
# ==============================================================================

# Partition support var
# If the target disk is a NVMe disk, add 'p' to the target disk
[[ $target =~ ^/dev/nvme[0-9]+n[0-9]+$ ]] && target_part="${target}p" || target_part="$target"

# Disk option(s)
BTRFS_SV_OPTS=$(IFS=,; echo "${btrfs_opts[*]}")   ## Btrfs mount option(s)
# Base system package(s)
LNX="linux-zen linux-zen-headers linux-firmware"  ## Base linux pkg(s)
BASE="base base-devel git"                        ## Base system pkg(s)
CPU="${cpu}-ucode"                                ## CPU driver
BOOTLOADER="grub efibootmgr os-prober"            ## Bootloader
NETWORK="networkmanager"                          ## Network
CRYPT="cryptsetup lvm2"                           ## Encryption
EXTRA="vim"                                       ## Extra pkg(s)
# Desktop Enviroment package(s)


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
# Checks if the script is run with root privileges and if the system is in UEFI mode.
# If either condition fails, the script exits with an error message.
checker() {
  # Check for root privileges
  [ "$EUID" -ne 0 ] && { echo "Please run as root. Aborting script."; exit 1; }
  
  # Check if the system is in UEFI mode
  [ -d /sys/firmware/efi/efivars ] || { echo "UEFI mode not detected. Aborting script."; exit 1; }
}

# Preparation
#
# Prepares the machine for installation by setting the keyboard layout, enabling NTP, 
# updating the mirrorlist, and refreshing the package database. Also updates the 
# Arch Linux keyring for successful package installations.
preparation() {
  # Set keyboard layout
  loadkeys $keyboard

  # Enable NTP for time synchronization
  timedatectl set-ntp true &> /dev/null

  # Update mirrorlist and refresh package databases
  pacman -Syy &> /dev/null
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup  # Backup mirrorlist
  reflector --country "${reflector_countries}" \
            --protocol https \
            --age 6 \
            --sort rate \
            --save /etc/pacman.d/mirrorlist &> /dev/null

  # Enable parallel downloads and update keyring
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf 
  pacman -Syy &> /dev/null
  pacman -S --noconfirm archlinux-keyring &> /dev/null
  pacman-key --init &> /dev/null
  pacman -Syy &> /dev/null
}


# Function(s)
# ==============================================================================

# Pacman Configuration
#
# This function configures the Pacman package manager to improve user experience 
# and system maintenance. It enables parallel downloads in `/etc/pacman.conf`, 
# allowing multiple packages to be downloaded simultaneously for faster updates. 
# It also enables color output for better readability and adds the "ILoveCandy" option 
# to enhance the visual output with a more playful appearance. 
# Additionally, the function installs the `pacman-contrib` package, which includes 
# useful tools for Pacman, and enables the `paccache.timer` service to automatically 
# clean old package caches, helping to free up disk space and keep the system tidy.
pacman_conf() {
  # Configure pacman 
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf  # Enable parallel downloads
  sed -i 's/^#Color/Color/' /etc/pacman.conf                          # Enable color output
  sed -i '/^Color/a ILoveCandy' /etc/pacman.conf                      # Enable fancy output
  # Paccache
  pacman -S --noconfirm pacman-contrib &> /dev/null                   # Install 'pacman-contrib' pkg
  systemctl enable paccache.timer &> /dev/null                        # Enable the cache cleaner service
  # Server repository(s)
  sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf            # Enable multilib repository
  pacman -Syy &> /dev/null                                            # Refresh the package database(s)
}

# Disk formatting
#
# Configures the target disk by wiping, partitioning, optional encryption, and formatting.
# Supports both Btrfs (with subvolumes) and EXT4 filesystems. Handles the EFI partition setup.
disk_formatting() {
  umount -A --recursive /mnt  # Ensure everything is unmounted

  # Wipe the target disk
  wipefs -af "$target"                             # Wipe all data
  sgdisk --zap-all --clear "$target" &> /dev/null  # Clear partition table
  sgdisk -a 2048 -o "$target" &> /dev/null         # Align sectors to 2048
  partprobe "$target" &> /dev/null                 # Inform system of disk changes

  # Fill disk with random data for security
  cryptsetup open --type plain -d /dev/urandom $target target &> /dev/null
  dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct &> /dev/null
  cryptsetup close target

  # Partition the target disk
  sgdisk -n 0:0:+${part1_size} -t 0:ef00 -c 0:ESP $target &> /dev/null  # EFI partition
  sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs $target &> /dev/null            # Root partition
  partprobe "$target" &> /dev/null                                      # Update partition info

  # (Optional) Encrypt the root partition
  if [ "$encrypt" = "yes" ]; then
    sgdisk -t 2:8309 $target &> /dev/null  # Set partition 2 type to LUKS
    partprobe "$target" &> /dev/null       # Update partition info

    # Encrypt root partition
    echo -n "$encrypt_key" | cryptsetup --type $encrypt_type -v -y luksFormat ${target_part}2 --key-file=- &> /dev/null
    echo -n "$encrypt_key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${target_part}2 $encrypt_label --key-file=- &> /dev/null
    root_device="/dev/mapper/${encrypt_label}"  # Set root to encrypted partition
  else
    root_device=${target_part}2  # Set root to non-encrypted partition
  fi

  # Format the EFI partition
  mkfs.vfat -F32 -n $part1_label ${target_part}1 &> /dev/null

  # Format and mount the root partition
  if [ "$part2_fs" = "btrfs" ]; then
    mkfs.btrfs -L $part2_label $root_device &> /dev/null  # Format as Btrfs
    mount $root_device /mnt                               # Mount root

    # Create Btrfs subvolumes
    btrfs subvolume create /mnt/@ &> /dev/null           # System subvolume
    btrfs subvolume create /mnt/@home &> /dev/null       # Home subvolume
    btrfs subvolume create /mnt/@snapshots &> /dev/null  # Snapshots subvolume
    btrfs subvolume create /mnt/@cache &> /dev/null      # Cache subvolume
    btrfs subvolume create /mnt/@log &> /dev/null        # Log subvolume
    btrfs subvolume create /mnt/@tmp &> /dev/null        # Temp subvolume

    # Create additional subvolumes
    for subvol in "${btrfs_subvols[@]}"; do
      btrfs subvolume create /mnt/@$subvol &> /dev/null
    done

    umount /mnt  # Unmount to remount with subvolume options

    # Remount with Btrfs subvolumes
    mount -o ${BTRFS_SV_OPTS},subvol=@ $root_device /mnt &> /dev/null
    mkdir -p /mnt/{home,.snapshots,var/cache,var/log,var/tmp} &> /dev/null
    mount -o ${BTRFS_SV_OPTS},subvol=@home $root_device /mnt/home
    mount -o ${BTRFS_SV_OPTS},subvol=@snapshots $root_device /mnt/.snapshots
    mount -o ${BTRFS_SV_OPTS},subvol=@cache $root_device /mnt/var/cache
    mount -o ${BTRFS_SV_OPTS},subvol=@log $root_device /mnt/var/log
    mount -o ${BTRFS_SV_OPTS},subvol=@tmp $root_device /mnt/var/tmp

    # Mount additional subvolumes
    for i in "${!btrfs_subvols[@]}"; do
      mkdir -p /mnt${btrfs_subvols_mount[$i]}
      mount -o ${BTRFS_SV_OPTS},subvol=@${btrfs_subvols[$i]} $root_device /mnt${btrfs_subvols_mount[$i]}
    done
  else
    mkfs.ext4 -L $part2_label $root_device &> /dev/null  # Format as EXT4
    mount $root_device /mnt                              # Mount root
  fi

  # Mount EFI partition
  mkdir -p /mnt/$part1_mount
  mount ${target_part}1 /mnt/$part1_mount
}


gnome() {}

# Bootloader Configuration
bootloader() {
  cp /etc/default/grub /etc/default/grub.backup  # Backup current GRUB configuration

  # Modify GRUB default settings
  sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub
  sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
  sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=y/" /etc/default/grub
  sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
  sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

  if [ "$encrypt" = "yes" ]; then
    uuid=$(blkid -s UUID -o value ${target_part}2)  # Determine UUID of the encrypted partition

    # Modify GRUB configuration for encrypted disk
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
    sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
    sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
  fi

  # Install GRUB to the EFI system partition
  grub-install --target=x86_64-efi --efi-directory=/${part1_mount} --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
  grub-mkconfig -o /boot/grub/grub.cfg       # Generate GRUB configuration file
  sbctl create-keys && sbctl enroll-keys -m  # Create and enroll signing keys
  # Sign the necessary files
  sbctl sign -s /boot/EFI/GRUB/grubx64.efi \
            -s /boot/grub/x86_64-efi/core.efi \
            -s /boot/grub/x86_64-efi/grub.efi \
            -s /boot/vmlinuz-linux-zen
}

# Kernel modules Configuration
init_ramdisk() {}

# Service(s) Configuration
#
# This function configures essential system services for network management, 
# SSH access, mirrorlist updates, firewall setup, and kernel network parameters. 
# It installs and enables the OpenSSH server to allow remote access via SSH. 
# NetworkManager is enabled to manage network connections, including waiting 
# for the network to be fully online at boot. 
# The Reflector service is configured to periodically update the system's 
# mirrorlist by selecting the fastest mirrors based on the country and connection speed. 
# The firewall is configured using nftables, which includes a default ruleset for basic security, 
# such as dropping invalid connections and allowing ICMP traffic. 
# Kernel network parameters are adjusted to disable IP forwarding, prevent ICMP redirects, 
# and enable SYN flood protection.
#
# If the system uses an SSD, the `fstrim.timer` service is enabled to periodically 
# run the `fstrim` command, optimizing SSD performance.
#
# For more information on the values used for services like Reflector or SSD detection, 
# refer to the 'Disk' section in the Configuration Parameters.
serv_conf() {
  # SSH
  pacman -S --noconfirm openssh &> /dev/null
  systemctl enable sshd.service &> /dev/null

  # NetworkManager
  systemctl enable NetworkManager.service &> /dev/null
  systemctl enable NetworkManager-wait-online.service &> /dev/null

  # Reflector
  pacman -S --noconfirm reflector &> /dev/null
  cat > /etc/xdg/reflector/reflector.conf <<EOF
--country "${reflector_countries}"
--protocol https
--age 6
--sort rate
--save /etc/pacman.d/mirrorlist
EOF
  systemctl enable reflector.service &> /dev/null
  systemctl enable reflector.timer &> /dev/null

  # Firewall
  pacman -S --noconfirm nftables &> /dev/null
  NFTABLES_CONF="/etc/nftables.conf"
  bash -c "cat << EOF > $NFTABLES_CONF
#!/usr/sbin/nft -f

table inet filter
delete table inet filter
table inet filter {
  chain input {
    type filter hook input priority filter
    policy drop

    ct state invalid drop comment 'early drop of invalid connections'
    ct state {established, related} accept comment 'allow tracked connections'
    iifname lo accept comment 'allow from loopback'
    ip protocol icmp accept comment 'allow icmp'
    meta l4proto ipv6-icmp accept comment 'allow icmp v6'
    pkttype host limit rate 5/second counter reject with icmpx type admin-prohibited
    counter
  }

  chain forward {
    type filter hook forward priority filter
    policy drop
  }
}
EOF"
  systemctl enable --now nftables &> /dev/null

  # Kernel parameters
  SYSCTL_CONF="/etc/sysctl.d/90-network.conf"  # sysctl configuration file
  # Create or overwrite the sysctl configuration file with the specified parameters
  bash -c "cat << EOF > $SYSCTL_CONF
# Do not act as a router
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# SYN flood protection
net.ipv4.tcp_syncookies = 1

# Disable ICMP redirect
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Do not send ICMP redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
EOF"
  sysctl --system &> /dev/null  # Load the new sysctl settings

  # SSD improvements
  if [ "is_ssd" = "yes" ]; then
    pacman -S --noconfirm util-linux &> /dev/null
    systemctl enable --now fstrim.timer &> /dev/null
  fi
}

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

# System Installation
#
# Installs the base system packages and generates the fstab file.
sys_installation() {
  # Install base system packages
  pacstrap /mnt $LNX $BASE $CPU $BOOTLOADER $NETWORK $CRYPT $EXTRA

  # Generate fstab file
  genfstab -U -p /mnt >> /mnt/etc/fstab &> /dev/null
}


# User Configuration
#
# This function configures the root and user accounts for the system. 
# It sets the root password by passing the provided password to the `chpasswd` command.
# A new user is then created with the specified username, assigned to the `wheel` group 
# to grant administrative privileges, and given the Bash shell as the default login shell. 
# The password for the new user is also set using the `chpasswd` command. 
# Finally, it modifies the `/etc/sudoers` file to allow members of the `wheel` group to 
# execute any command using `sudo`, enabling administrative access for the new user.
#
# For more information on the values used for rootpwd, username, and password, 
# refer to the 'User' section in the Configuration Parameters.
user_conf() {
  echo "root:$rootpwd" | chpasswd &> /dev/null                                               # Set the root password
  useradd -m -G wheel -s /bin/bash "$username" &> /dev/null                                  # Add a new user and assign to 'wheel' group with bash shell
  echo "$username:$password" | chpasswd &> /dev/null                                         # Set password for the new user
  sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers &> /dev/null  # Enable 'wheel' group users to use sudo
}


# Script main
# ==============================================================================
checker

print_info "[*] Preparing the machine for the installation ..."
preparation
print_success "[+] The machine is ready for the installation!"

print_info "[*] Formatting the disk ..."
disk_formatting
print_success "[+] The disk has been formatted!"

print_info "[*] Installing the base system ..."
sys_installation
print_success "[+] The base system has been installed!"

print_info "[*] CHRooting into the new system ..."
arch-chroot /mnt /bin/bash
print_success "[+] CHRooted into the new system!"



# ^-^-^-^-^-^-^-^-^-^        End of Script Core          ^-^-^-^-^-^-^-^-^-^-^-^














# User experience
de="gnome"     # Desktop environment - (gnome/kde)
use_wm="no"    # Use window manager? - (yes/no)
wm="hyprland"  # Window manager      - (hyprlad/dwm)

# ------------------------------------------------------------------------------

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