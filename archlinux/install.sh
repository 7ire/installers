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
#
# - cpu : Specifies the CPU driver to use (intel/amd).
# - gpu : Specifies the GPU driver to use (intel/nvidia).
cpu="intel"   # CPU driver selection
gpu="nvidia"  # GPU driver selection

# User settings
#
# Defines the root and user account credentials.
#
# - rootpwd  : Password for the root user.
# - username : Name of the regular user.
# - password : Password for the regular user.
rootpwd="dummy"    # Root user password
username="dummy"   # Regular user name
password="dummy"   # Regular user password

# User Extra settings
#
# Defines additional user preferences, services, and extra packages.
#
# - editor   : Default text editor (vim/nano).
# - aur      : AUR helper to use (paru/yay).
editor="vim"    # Default text editor
aur="paru"      # AUR helper
# Service settings
#
# - ssh       : Enable SSH service (yes/no).
# - bluetooth : Enable Bluetooth service (yes/no).
# - printer   : Enable Printer service (yes/no).
ssh="yes"       # Enable SSH service
bluetooth="no"  # Enable Bluetooth service
printer="no"    # Enable Printer service
# Extra packages
#
# Specifies additional packages to install.
pkgs=(          
  bash-completion  # Bash auto-completion
  man-db           # Man page database
  man-pages        # Manual pages
  git              # Git version control
  curl             # Data transfer utility
  wget             # Network downloader
  rsync            # File synchronization tool
)

# Desktop Environment settings

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
CRYPT="cryptsetup"                                ## Encryption
EXTRA="sudo"                                      ## Extra pkg(s)
# if encrypt is enabled and part2_fs is not btrfs, add lvm2 to the base system packages
[ "$encrypt" = "yes" ] && [ "$part2_fs" != "btrfs" ] && CRYPT+=" lvm2"  # Add LVM2 package
# if part2_fs is btrfs, add btrfs-progs to the base system packages
[ "$part2_fs" = "btrfs" ] && EXTRA+=" btrfs-progs"  # Add Btrfs package
# Desktop Enviroment package(s)
USR_EXT_PKGS=$(IFS=" "; echo "${pkgs[*]}")         ## Extra pkg(s)


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

# Package Manager Configuration
#
# Configures Pacman for parallel downloads, color output, and enables automatic cache cleaning.
pacman_conf() {
  # Enable parallel downloads and color output in pacman
  sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
  sed -i 's/^#Color/Color/' /etc/pacman.conf
  sed -i '/^Color/a ILoveCandy' /etc/pacman.conf  # Add playful visual effect

  # Install pacman-contrib and enable automatic cache cleaning
  pacman -S --noconfirm pacman-contrib &> /dev/null
  systemctl enable paccache.timer &> /dev/null

  # Enable multilib repository and refresh package database
  sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
  pacman -Syy &> /dev/null
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

# Bootloader
#
# Configures and installs the GRUB bootloader, including encryption support if enabled.
bootloader() {
  # Backup current GRUB configuration
  cp /etc/default/grub /etc/default/grub.backup

  # Update GRUB settings
  sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub
  sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
  sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=y/" /etc/default/grub
  sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
  sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub

  if [ "$encrypt" = "yes" ]; then
    # Get UUID of the encrypted partition
    uuid=$(blkid -s UUID -o value ${target_part}2)

    # Update GRUB for encrypted disk
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
    sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
    sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
  fi

  # Install GRUB to EFI partition
  grub-install --target=x86_64-efi --efi-directory=/${part1_mount} --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
  grub-mkconfig -o /boot/grub/grub.cfg  # Generate GRUB configuration

  # Create and enroll secure boot keys
  sbctl create-keys && sbctl enroll-keys -m

  # Sign necessary boot files
  sbctl sign -s /boot/EFI/GRUB/grubx64.efi \
            -s /boot/grub/x86_64-efi/core.efi \
            -s /boot/grub/x86_64-efi/grub.efi \
            -s /boot/vmlinuz-linux-zen
}

# Initial Ramdisk Configuration
#
# Configures kernel modules and initial ramdisk, including encryption and filesystem setup.
init_ramdisk() {
  if [ "$encrypt" = "yes" ]; then
    # Generate keyfile for LUKS encryption
    dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin &> /dev/null
    chmod 600 /key.bin &> /dev/null  # Restrict keyfile access
    cryptsetup luksAddKey "${target_part}2" /key.bin &> /dev/null  # Add keyfile to LUKS
  fi

  # Include btrfs module if btrfs is used
  if [ "$part2_fs" = "btrfs" ]; then
    sed -i '/^MODULES=/ s/)/ btrfs)/' /etc/mkinitcpio.conf &> /dev/null
  fi

  # Configure hooks based on encryption and filesystem
  if [ "$is_enc" = "True" ]; then
    sed -i '/^FILES=/ s/)/ \/key.bin)/' /etc/mkinitcpio.conf &> /dev/null  # Add keyfile to mkinitcpio

    if [ "$part2_fs" = "btrfs" ]; then
      # Hooks for encryption and btrfs
      sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block encrypt btrfs filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
    else
      # Hooks for encryption without btrfs
      sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
    fi
  else
    # Hooks without encryption
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
  fi

  # Generate the initial ramdisk
  mkinitcpio -P &> /dev/null
}

# Base Services Configuration
#
# Configures essential system services for network management, SSH, mirrorlist updates, 
# firewall setup, and kernel network parameters. Enables fstrim for SSDs if detected.
serv_conf() {
  # Enable NetworkManager
  systemctl enable NetworkManager.service &> /dev/null
  systemctl enable NetworkManager-wait-online.service &> /dev/null

  # Configure and enable Reflector for mirrorlist updates
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

  # Configure nftables firewall and enable the service
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

    ct state invalid drop comment 'drop invalid connections'
    ct state {established, related} accept comment 'allow established connections'
    iifname lo accept comment 'allow loopback'
    ip protocol icmp accept comment 'allow ICMP'
    meta l4proto ipv6-icmp accept comment 'allow ICMPv6'
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

  # Apply kernel network parameters
  SYSCTL_CONF="/etc/sysctl.d/90-network.conf"
  bash -c "cat << EOF > $SYSCTL_CONF
# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Enable SYN flood protection
net.ipv4.tcp_syncookies = 1

# Disable ICMP redirects
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
  sysctl --system &> /dev/null  # Apply sysctl settings

  # Enable fstrim for SSDs
  if [ "is_ssd" = "yes" ]; then
    pacman -S --noconfirm util-linux &> /dev/null
    systemctl enable --now fstrim.timer &> /dev/null
  fi
}

# System Configuration
#
# Configures essential system settings like hostname, locale, timezone, and keyboard layout.
sys_conf() {
  # Set system hostname
  echo "$hostname" > /etc/hostname

  # Configure /etc/hosts for local hostname resolution
  cat > /etc/hosts << EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF

  # Enable the desired locale in /etc/locale.gen
  sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen

  # Set system language/locale
  echo "LANG=${lang}" > /etc/locale.conf
  locale-gen &> /dev/null  # Generate locale

  # Set system timezone and sync hardware clock
  ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime &> /dev/null
  hwclock --systohc &> /dev/null

  # Set console keymap
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
# Configures the root and user accounts, sets passwords, and grants sudo access to the user.
user_conf() {
  # Set root password
  echo "root:$rootpwd" | chpasswd &> /dev/null

  # Add new user, assign to 'wheel' group, and set Bash as default shell
  useradd -m -G wheel -s /bin/bash "$username" &> /dev/null
  
  # Set user password
  echo "$username:$password" | chpasswd &> /dev/null
  
  # Enable sudo for 'wheel' group
  sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers &> /dev/null
}

# (User) Bluetooth Configuration
#
# Install Bluetooth packages and configures Bluetooth settings.
usr_blth() {
  # Install Bluetooth packages
  sudo pacman -S --noconfirm bluez bluez-utils bluez-tools &> /dev/null

  BLUETOOTH_CONF="/etc/bluetooth/main.conf"

  # Ensure ControllerMode is set to 'dual'
  if grep -q "^#*ControllerMode = dual" "$BLUETOOTH_CONF"; then
    sudo sed -i 's/^#*ControllerMode = dual/ControllerMode = dual/' "$BLUETOOTH_CONF"
  else
    echo "ControllerMode = dual" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null
  fi

  # Ensure [General] section contains Experimental = true
  if grep -q "^\[General\]" "$BLUETOOTH_CONF"; then
    if grep -q "^#*Experimental = false" "$BLUETOOTH_CONF"; then
      sudo sed -i 's/^#*Experimental = false/Experimental = true/' "$BLUETOOTH_CONF"
    elif ! grep -q "^Experimental = true" "$BLUETOOTH_CONF"; then
      sudo sed -i '/^\[General\]/a Experimental = true' "$BLUETOOTH_CONF"
    fi
  else
    echo -e "\n[General]\nExperimental = true" | sudo tee -a "$BLUETOOTH_CONF" > /dev/null
  fi

  # Enable and start Bluetooth service
  sudo systemctl enable bluetooth.service &> /dev/null
}

# (User) SSH Configuration
#
# Installs and enables the OpenSSH service.
usr_ssh() {
  # Install OpenSSH
  sudo pacman -S --noconfirm openssh &> /dev/null

  # Enable SSH service
  sudo systemctl enable sshd.service &> /dev/null
}

# (User) Printer Configuration
#
# Installs and enables printing services, including CUPS and Bluetooth printing support.
usr_printer() {
  # Install CUPS and related packages
  sudo pacman -S --noconfirm cups cups-pdf bluez-cups &> /dev/null

  # Enable CUPS service
  sudo systemctl enable cups.service &> /dev/null
}

# (User) Extra Configuration
#
# Installs extra user packages, sets default editor, and optionally installs AUR helper, SSH, Bluetooth, and printer support.
user_extra() {
  # Install and set the default editor
  sudo pacman -S --noconfirm $editor &> /dev/null
  sudo echo "EDITOR=${editor}" > /etc/environment
  sudo echo "VISUAL=${editor}" >> /etc/environment

  # Install additional packages
  sudo pacman -S --noconfirm $USR_EXT_PKGS &> /dev/null

  # Install AUR helper (paru or yay)
  if [ "$aur" = "paru" ]; then
    git clone https://aur.archlinux.org/paru.git /tmp/paru &> /dev/null
    cd /tmp/paru
    makepkg -si --noconfirm &> /dev/null
    cd - && rm -rf /tmp/paru
    sudo pacman -Syyu --noconfirm &> /dev/null
    paru -Syyu --noconfirm &> /dev/null
  elif [ "$aur" = "yay" ]; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay &> /dev/null
    cd /tmp/yay
    makepkg -si --noconfirm &> /dev/null
    cd - && rm -rf /tmp/yay
    sudo pacman -Syyu --noconfirm &> /dev/null
    yay -Syyu --noconfirm &> /dev/null
  fi

  # Install and enable optional services
  [ "$ssh" = "yes" ] && usr_ssh
  [ "$bluetooth" = "yes" ] && usr_blth
  [ "$printer" = "yes" ] && usr_printer
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

print_info "[*] Configuring the system ..."
sys_conf
print_success "[+] System configuration completed!"

print_info "[*] Configuring system root user and local user ..."
user_conf
print_success "[+] User(s) configuration completed!"

print_info "[*] Configuring the pacman manager ..."
pacman_conf
print_success "[+] Pacman manager configuration completed!"

print_info "[*] Configuring base services ..."
serv_conf
print_success "[+] Base services configuration completed!"

print_info "[*] Configuring initial ramdisk ..."
init_ramdisk
print_success "[+] Initial ramdisk configuration completed!"

print_info "[*] Configuring the bootloader ..."
bootloader
print_success "[+] Bootloader configuration completed!"

print_info "[*] User extra configuration ..."
su $username
user_extra
exit
print_success "[+] User extra configuration completed!"

exit
print_success "[+] Installation completed successfully!"
reboot -now

# ^-^-^-^-^-^-^-^-^-^        End of Script Core          ^-^-^-^-^-^-^-^-^-^-^-^