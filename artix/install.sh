#        /\        
#       /  \       | Title: Tir3 Artix Linux (runit) - Installer             |
#      /`'.,\      |---------------------------------------------------------|
#     /     ',     |     OS      | Artix Linux (runit init-system)           |
#    /      ,`\    | Description | Install Artix Linux system w/ user config |
#   /   ,.'`.  \   |    Owner    | Tir3                                      |
#  /.,'`     `'.\  |   GitHub    | https://github.com/7ire                   |



# Configuration parameters
# -----------------------------------------------------------------------------

# Locale
lang=""        # Language
timezone=""    # Timezone
keyboard="us"  # Keyboard layout

# Disk
target="/dev/sda"  # Target disk     -    'lsblk'
is_ssd="no"        # Is SSD disk?    -   (yes/no)
encrypt="no"       # Encrypt disk?   -   (yes/no)
type="lusk2"       # Encryption type - (lusk/lusk2)
key="changeme"     # Encryption key
## partition 1 - EFI
# TODO: espsize
# TODO: name
# TODO: 
## partition 2 - root

# Script body
# -----------------------------------------------------------------------------

# TODO: Check if UEFI (ls /sys/firmware/efi/efivars), if not abort the script

# [0]. Preparation to install Artix
loadkeys $keyboard              # Set the keyboard layout
# Enable OpenNTP
ln -s /etc/runit/sv/openntpd /run/runit/service
sv up openntpd
pacman -Syy &> /dev/null        # Refresh database(s)

# Enable parrallel downloads in pacman
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
# Update keyrings
pacman -S --noconfirm archlinux-keyring &> /dev/null # (Archlinux)
pacman -S --noconfirm artix-keyring &> /dev/null     # (Artix)
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
# Check if target need to be encrypt
if [ "$is_enc" = "yes" ]; then
    sgdisk -t 2:8309 $disk &> /dev/null                            # Change partition 2 type to LUKS (for encryption)

    # Encrypt partition 2 using the provided key
    echo -n "$key" | cryptsetup --type luks2 -v -y luksFormat ${target}p2 --key-file=- &> /dev/null
    # Open the encrypted partition
    echo -n "$key" | cryptsetup open --perf-no_read_workqueue --perf-no_write_workqueue --persistent ${target}p2 cryptdev --key-file=- &> /dev/null
    # Set the root device to the encrypted partition
    root_device="/dev/mapper/cryptdev"
else
    # Set the root device to the non-encrypted partition
    root_device="${disk}p2"
fi
