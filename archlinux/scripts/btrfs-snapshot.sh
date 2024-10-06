# !/bin/bash
#
# Utility functions
print_debug() { echo -e "\e[${1}m${2}\e[0m"; }
print_success() { print_debug "32" "$1"; }
print_info() { print_debug "36" "$1"; }



# ------------------------------------------------------------------------------
#                               Parameters
# ------------------------------------------------------------------------------
TIMELINE_MIN_AGE="1800"     # Minimum age of a snapshot in seconds
TIMELINE_LIMIT_HOURLY="5"   # Limit of hourly snapshots
TIMELINE_LIMIT_DAILY="7"    # Limit of daily snapshots
TIMELINE_LIMIT_WEEKLY="0"   # Limit of weekly snapshots
TIMELINE_LIMIT_MONTHLY="0"  # Limit of monthly snapshots
TIMELINE_LIMIT_YEARLY="0"   # Limit of yearly snapshots




# ------------------------------------------------------------------------------
#                     Install and configure snapshot tools
# ------------------------------------------------------------------------------
print_info "[*] Installing and configuring snapshot tools..."

sudo pacman -S --noconfirm snapper snap-pac &> /dev/null  # Install 'snapper' and 'snap-pac'
SNAPPER_CONF="/etc/snapper/configs/root"                  # Snapper configuration file
# Unmount and remove existing /.snapshots subvolume and mount point
sudo umount /.snapshots &> /dev/null
sudo rm -rf /.snapshots &> /dev/null
# Create new snapper configuration for root subvolume
sudo snapper -c root create-config / &> /dev/null
# Remove snapper-generated subvolume
sudo btrfs subvolume delete .snapshots &> /dev/null
# Re-create and re-mount /.snapshots mount point
sudo mkdir /.snapshots &> /dev/null
sudo mount -a &> /dev/null
# Set permissions for /.snapshots
sudo chmod 750 /.snapshots &> /dev/null
sudo chown :wheel /.snapshots &> /dev/null

print_success "[+] Snapshot tools configured successfully."




# ------------------------------------------------------------------------------
#                        Modify snapshot configuration
# ------------------------------------------------------------------------------
print_info "[*] Modifying snapshot configuration..."

# Update Snapper configuration parameters
sudo sed -i "s/^ALLOW_USERS=.*/ALLOW_USERS=\"$user\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_MIN_AGE=.*/TIMELINE_MIN_AGE=\"$TIMELINE_MIN_AGE\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY=\"$TIMELINE_LIMIT_HOURLY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY=\"$TIMELINE_LIMIT_DAILY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_WEEKLY=.*/TIMELINE_LIMIT_WEEKLY=\"$TIMELINE_LIMIT_WEEKLY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY=\"$TIMELINE_LIMIT_MONTHLY\"/" $SNAPPER_CONF
sudo sed -i "s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY=\"$TIMELINE_LIMIT_YEARLY\"/" $SNAPPER_CONF

print_success "[+] Snapshot configuration updated."



# ------------------------------------------------------------------------------
#                          Enable and start services
# ------------------------------------------------------------------------------
print_info "[*] Enabling and starting snapshot services..."

# Enable and start Snapper timeline and cleanup timers
sudo systemctl enable --now snapper-timeline.timer &> /dev/null
sudo systemctl enable --now snapper-cleanup.timer &> /dev/null

print_success "[+] Snapshot services enabled."



# ------------------------------------------------------------------------------
#                           Check and install 'locate'
# ------------------------------------------------------------------------------
print_info "[*] Checking for locate utility..."

# Install mlocate if not already installed
if ! command -v updatedb &> /dev/null; then
    sudo pacman -S --noconfirm mlocate &> /dev/null
fi
# Add /.snapshots to PRUNENAMES in updatedb configuration
sudo sed -i "/^PRUNENAMES/s/\"$/ .snapshots\"/" /etc/updatedb.conf
sudo updatedb &> /dev/null  # Update 'mlocate' database(s)

print_success "[+] Locate utility configured."



# ------------------------------------------------------------------------------
#                    Install and configure 'grub-btrfs'
# ------------------------------------------------------------------------------
print_info "[*] Installing and configuring GRUB-BTRFS..."

sudo pacman -S --noconfirm grub-btrfs inotify-tools &> /dev/null  # Install 'grub-btrfs' and 'inotify-tools'
# Configure GRUB-BTRFS to use the correct GRUB directory
sudo sed -i "s|^GRUB_BTRFS_GRUB_DIRNAME=.*|GRUB_BTRFS_GRUB_DIRNAME=\"/esp/grub\"|" /etc/default/grub-btrfs/config
sudo systemctl enable --now grub-btrfs.path &> /dev/null                  # Enable 'grub-btrfs.path' service
sudo sed -i "/^HOOKS=/ s/)/ grub-btrfs-overlayfs)/" /etc/mkinitcpio.conf  # Add 'grub-btrfs-overlayfs' to HOOKS
sudo mkinitcpio -P &> /dev/null  # Generate the initial ramdisk

print_success "[+] GRUB-BTRFS configured successfully."