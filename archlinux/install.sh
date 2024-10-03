# !/bin/bash
#
# ------------------------------------------------------------------------------
#        /\        | Title: Tir3 Arch Linux - Installer                        |
#       /  \       |-----------------------------------------------------------|
#      /\   \      |     OS      | Arch Linux                                  |
#     /      \     | Description | Arch Linux system installation              |
#    /   ,,   \    |    Owner    | Tir3                                        |
#   /   |  |  -\   |   GitHub    | https://github.com/atirelli3                |
#  /_-''    ''-_\  |   Version   | 0.1.0                                       |
# ------------------------------------------------------------------------------

# Constants
[[ $target =~ ^/dev/nvme[0-9]+n[0-9]+$ ]] && target_part="${target}p" || target_part="$target"
BTRFS_SV_OPTS=$(IFS=,; echo "${btrfs_opts[*]}")   ## Btrfs mount options
LNX="linux-zen linux-zen-headers linux-firmware"  ## Base Linux packages
BASE="base base-devel git"                        ## Base system packages
CPU="${cpu}-ucode"                                ## CPU driver
BOOTLOADER="grub efibootmgr os-prober"            ## Bootloader
NETWORK="networkmanager"                          ## Network manager
CRYPT="cryptsetup"                                ## Encryption
EXTRA="sudo"                                      ## Extra packages

# Conditional package addition
[ "$encrypt" = "yes" ] && [ "$part2_fs" != "btrfs" ] && CRYPT+=" lvm2"
[ "$part2_fs" = "btrfs" ] && EXTRA+=" btrfs-progs"
USR_EXT_PKGS=$(IFS=" "; echo "${pkgs[*]}")         ## User extra packages

# Utility functions
print_debug() { echo -e "\e[${1}m${2}\e[0m"; }
print_success() { print_debug "32" "$1"; }
print_info() { print_debug "36" "$1"; }

# Check prerequisites => root privileges and system is in UEFI mode
[ "$EUID" -ne 0 ] && { echo "Please run as root. Aborting script."; exit 1; }
[ -d /sys/firmware/efi/efivars ] || { echo "UEFI mode not detected. Aborting script."; exit 1; }



# ------------------------------------------------------------------------------
#                                  Preparation
# ------------------------------------------------------------------------------
print_info "[*] Preparing the machine for installation..."

loadkeys $keyboard                     # Set keyboard layout
timedatectl set-ntp true &> /dev/null  # Enable NTP for time synchronization
pacman -Syy &> /dev/null               # Refresh package manager database(s)
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup  # Backup current mirrorlist
reflector --country "${reflector_countries}" \               # Search for better mirror(s)
            --protocol https \
            --age 6 \
            --sort rate \
            --save /etc/pacman.d/mirrorlist &> /dev/null
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf  # Enable 'ParalleDownloads' 4pacman
pacman -S --noconfirm archlinux-keyring &> /dev/null                # Download updated keyrings
pacman-key --init &> /dev/null                                      # Initialize newer keyrings
pacman -Syy &> /dev/null                                            # Refresh package manager database(s)

print_success "[+] The machine is ready for the installation!"



# ------------------------------------------------------------------------------
#                                Disk Formatting
# ------------------------------------------------------------------------------
print_info "[*] Formatting the disk..."

umount -A --recursive /mnt &> /dev/null          # Ensure everything is unmounted
# Wipe data(s)
wipefs -af "$target" &> /dev/null                # Wipe all data
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
partprobe "$target" &> /dev/null                                      # Inform system of disk changes
# (Optional) Encrypt the root partition
if [ "$encrypt" = "yes" ]; then
    sgdisk -t 2:8309 $target &> /dev/null  # Set partition 2 type to LUKS
    partprobe "$target" &> /dev/null       # Inform system of disk changes
    # Encrypt root partition
    echo -n "$encrypt_key" | cryptsetup --type $encrypt_type -v -y luksFormat ${target_part}2 --key-file=- &> /dev/null
    echo -n "$encrypt_key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${target_part}2 $encrypt_label --key-file=- &> /dev/null
    root_device="/dev/mapper/${encrypt_label}"  # Set root to encrypted partition
else
    root_device=${target_part}2                 # Set root to non-encrypted partition
fi

mkfs.vfat -F32 -n $part1_label ${target_part}1 &> /dev/null  # Format the EFI partition

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
    umount /mnt                                          # Unmount to remount with subvolume options
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

mkdir -p /mnt/$part1_mount
mount ${target_part}1 /mnt/$part1_mount  # Mount EFI partition

print_success "[+] Disk formatting completed."



# ------------------------------------------------------------------------------
#                            Base System Installation
# ------------------------------------------------------------------------------
print_info "[*] Installing the base system..."

# Install base system packages
pacstrap /mnt $LNX $BASE $CPU $BOOTLOADER $NETWORK $CRYPT $EXTRA &> /dev/null
genfstab -U -p /mnt >> /mnt/etc/fstab &> /dev/null  # Generate fstab file table

print_success "[+] Base system installation completed."



arch-chroot /mnt /bin/bash
# ------------------------------------------------------------------------------
#                              System Configuration
# ------------------------------------------------------------------------------
print_info "[*] Configuring the system..."

echo "$hostname" > /etc/hostname  # Set system hostname
cat > /etc/hosts << EOF           # Configure /etc/hosts for local hostname resolution
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${hostname}.localdomain ${hostname}
EOF
sed -i "s/^#\(${lang}\)/\1/" /etc/locale.gen  # Enable the desired locale in /etc/locale.gen
echo "LANG=${lang}" > /etc/locale.conf        # Set system language/locale
locale-gen &> /dev/null                       # Generate locale
# Set system timezone and sync hardware clock
ln -sf /usr/share/zoneinfo/"$timezone" /etc/localtime &> /dev/null
hwclock --systohc &> /dev/null
echo "KEYMAP=${keyboard}" > /etc/vconsole.conf  # Set console keymap

print_success "[+] System configuration completed."



# ------------------------------------------------------------------------------
#                               User Configuration
# ------------------------------------------------------------------------------
print_info "[*] Configuring system root user and local user ..."

echo "root:$rootpwd" | chpasswd &> /dev/null        # Set root password
# Add new user, assign to 'wheel' group, and set Bash as default shell
useradd -m -G wheel -s /bin/bash "$username" &> /dev/null
echo "$username:$password" | chpasswd &> /dev/null  # Set user password
# Enable sudo for 'wheel' group
sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers &> /dev/null

print_success "[+] User(s) configuration completed!"



# ------------------------------------------------------------------------------
#                              Pacman Configuration
# ------------------------------------------------------------------------------
print_info "[*] Configuring pacman..."

sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf  # Enable 'ParalleDownloads' 4pacman
sed -i 's/^#Color/Color/' /etc/pacman.conf                          # Make output colored
sed -i '/^Color/a ILoveCandy' /etc/pacman.conf                      # Fancy progress bar (pacman)
pacman -S --noconfirm pacman-contrib &> /dev/null  # pacman utils & scripts
systemctl enable paccache.timer &> /dev/null       # Enable automatic cache cleaning (every week)
sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf  # Enable multilib repository
pacman -Syy &> /dev/null                                  # Refresh package manager database(s)

print_success "[+] Pacman configuration completed."



# ------------------------------------------------------------------------------
#                          Base Services Configuration
# ------------------------------------------------------------------------------
print_info "[*] Configuring base services..."

# Network
systemctl enable NetworkManager.service &> /dev/null              # Enable 'NetworkManager'
systemctl enable NetworkManager-wait-online.service &> /dev/null  # Extra service
# Mirror(s)
pacman -S --noconfirm reflector &> /dev/null                 # Install 'reflector'
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup  # Backup current mirrorlist
reflector --country "${reflector_countries}" \               # Search for better mirror(s)
            --protocol https \
            --age 6 \
            --sort rate \
            --save /etc/pacman.d/mirrorlist &> /dev/null
systemctl enable reflector.service &> /dev/null              # Enable 'reflector' 
systemctl enable reflector.timer &> /dev/null                # Periodic update
# Firewall
pacman -S --noconfirm nftables &> /dev/null  # Install 'nftables'
NFTABLES_CONF="/etc/nftables.conf"           # Configuration file
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
systemctl enable nftables &> /dev/null       # Enable 'nftables'
# Kernel network parameters
SYSCTL_CONF="/etc/sysctl.d/90-network.conf"  # Configuration file
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
# SSDs
if [ "is_ssd" = "yes" ]; then
    pacman -S --noconfirm util-linux &> /dev/null     # Install 'util-linux'
    systemctl enable --now fstrim.timer &> /dev/null  # Enable fstrim
fi

print_success "[+] Base services configuration completed!"



# ------------------------------------------------------------------------------
#                         Initial Ramdisk Configuration
# ------------------------------------------------------------------------------
print_info "[*] Configuring initial ramdisk ..."

# Key decryption file (to prevent double asking of the passkey)
if [ "$encrypt" = "yes" ]; then
    # Generate keyfile for LUKS encryption
    dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin &> /dev/null
    chmod 600 /key.bin &> /dev/null                                        # Restrict keyfile access
    cryptsetup luksAddKey "${target_part}2" /key.bin &> /dev/null          # Add keyfile to LUKS
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
    if [ "$part2_fs" = "btrfs" ]; then
        sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block btrfs filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
    else
        sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block filesystems fsck)/' /etc/mkinitcpio.conf &> /dev/null
    fi
fi
# Include 'btrfs' module if btrfs filesystem is used on the disk
if [ "$part2_fs" = "btrfs" ]; then
    sed -i '/^MODULES=/ s/)/ btrfs)/' /etc/mkinitcpio.conf &> /dev/null
fi
mkinitcpio -P &> /dev/null  # Generate the initial ramdisk

print_success "[+] Initial ramdisk configuration completed!"



# ------------------------------------------------------------------------------
#                                   Bootloader
# ------------------------------------------------------------------------------
print_info "[*] Configuring the bootloader ..."

cp /etc/default/grub /etc/default/grub.backup  # Backup current GRUB configuration
# Update GRUB settings
sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub                          # Timeout = 30s
sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub                       # Use last selection
sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=y/" /etc/default/grub                  # Save last selection
sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub          # Sub-menus
sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub  # Os-prober
# UUID 4 encrypt disk
if [ "$encrypt" = "yes" ]; then
    uuid=$(blkid -s UUID -o value ${target_part}2)  # Get UUID of the encrypted partition
    # Update GRUB for encrypted disk
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
    sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
    sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
fi
# Install GRUB to EFI partition
grub-install --target=x86_64-efi --efi-directory=/${part1_mount} --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
grub-mkconfig -o /boot/grub/grub.cfg       # Generate GRUB configuration
# Secure boot (make sure system secure boot is in 'Setup mode')
pacman -S --noconfirm sbctl &> /dev/null   # Install 'sbctl'
sbctl create-keys && sbctl enroll-keys -m  # Create and enroll secure boot keys
# Sign the necessary files
sbctl sign -s /${part1_mount}/EFI/GRUB/grubx64.efi \
           -s /${part1_mount}/grub/x86_64-efi/core.efi \
           -s /${part1_mount}/grub/x86_64-efi/grub.efi \
           -s /${part1_mount}/vmlinuz-linux-zen

print_success "[+] Bootloader configuration completed!"



su $username
# ------------------------------------------------------------------------------
#                           (User) Extra Configuration
# ------------------------------------------------------------------------------
print_info "[*] User extra configuration ..."

sudo pacman -S --noconfirm $editor &> /dev/null  # Install default editor
sudo echo "EDITOR=${editor}" > /etc/environment  # Set the default editor
sudo echo "VISUAL=${editor}" >> /etc/environment
sudo pacman -S --noconfirm $USR_EXT_PKGS &> /dev/null  # Install additional packages
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
# SSH
if [ "$ssh" = "yes" ]; then
  sudo pacman -S --noconfirm openssh &> /dev/null  # Install 'openSSH'
  sudo systemctl enable sshd.service &> /dev/null  # Enable 'sshd'
fi
# Bluetooth
if [ "$bluetooth" = "yes" ]; then
    # Install Bluetooth packages
    sudo pacman -S --noconfirm bluez bluez-utils bluez-tools &> /dev/null
    BLUETOOTH_CONF="/etc/bluetooth/main.conf"  # Configuration file
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
fi
# Printer
if [ "$printer" = "yes" ]; then
    sudo pacman -S --noconfirm cups cups-pdf bluez-cups &> /dev/null  # Install 'cups' and related packages
    sudo systemctl enable cups.service &> /dev/null                   # Enable 'cups'
fi

print_success "[+] User extra configuration completed!"



exit            # Exit user
exit            # Exit arch-chroot
umount -R /mnt  # Unmount all device(s)
reboot now      # Reboot