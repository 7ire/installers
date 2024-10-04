# Arch Linux Installer Guide

## Installer Overview

This guide will help you use the **Arch Linux Installer** to set up an Arch Linux system. The installer simplifies the installation process by allowing you to define your preferences in a configuration file.

### Running the Installer

To execute the installer, run the following command:

```bash
./install.sh arch.conf
```

Where `arch.conf` is your custom configuration file containing all the settings for the installation.

> [!NOTE]
> Ensure that you have made the script executable before running it:
> 
> ```bash
> chmod +x install.sh
> ```

### Configuration File Parameters

Below is a breakdown of the key sections of the configuration file, with each section's parameters and their supported values.

---

#### 1. Preparation Settings

This section allows you to optimize the package downloads by selecting the fastest mirrors based on your location.

| Parameter             | Description                                    | Example Value                  |
|-----------------------|------------------------------------------------|--------------------------------|
| **reflector_countries**| Countries used to fetch mirrors.               | `"Italy,Germany,France"`       |

> [!TIP]
> Use `reflector --list-countries` to view a list of available countries.

---

#### 2. System Settings

Define essential system configurations such as hostname, language, timezone, and keyboard layout.

| Parameter   | Description                             | Supported Values               | Example Value         |
|-------------|-----------------------------------------|---------------------------------|-----------------------|
| **hostname**| System hostname                         | Any string                     | `"archlinux"`         |
| **lang**    | Primary system language                 | Locale (e.g., `locale -a`)      | `"en_US.UTF-8"`       |
| **timezone**| System timezone                         | Use `timedatectl list-timezones`| `"America/New_York"`  |
| **keyboard**| Keyboard layout                         | Use `localectl list-keymaps`    | `"us"`                |
| **extra_lang** | Additional locales                   | Locale array                   | `("it_IT.UTF-8")`     |
| **lc_time** | Locale for time display                 | Locale                         | `"en_US.UTF-8"`       |

> [!NOTE]
> Use `timedatectl list-timezones` and `locale -a` to check available values.

---

#### 3. Disk Settings

Configure disk partitioning, encryption, and the filesystem setup.

| Parameter             | Description                                           | Supported Values                   | Example Value          |
|-----------------------|-------------------------------------------------------|-------------------------------------|------------------------|
| **target**            | Target disk for installation                          | Use `lsblk -f` to identify disks    | `"/dev/sda"`           |
| **is_ssd**            | Specifies if the disk is an SSD                       | `"yes"`, `"no"`                     | `"no"`                 |
| **encrypt**           | Enable disk encryption                                | `"yes"`, `"no"`                     | `"no"`                 |
| **encrypt_type**      | Type of encryption                                    | `"luks"`, `"luks2"`                 | `"luks2"`              |
| **encrypt_key**       | Encryption key                                        | Any string                         | `"changeme"`           |
| **encrypt_label**     | Label for the encrypted device                        | Any string                         | `"cryptdev"`           |
| **part1_size**        | Size of the EFI partition                             | Size in MiB, GiB, etc.             | `"512MiB"`             |
| **part1_mount**       | Mount point for the EFI partition                     | Any string                         | `"esp"`                |
| **part1_label**       | Label for the EFI partition                           | Any string                         | `"ESP"`                |
| **part2_fs**          | Filesystem type for the root partition                | `"ext4"`, `"btrfs"`                 | `"ext4"`               |
| **part2_label**       | Label for the root partition                          | Any string                         | `"archlinux"`          |
| **btrfs_subvols**     | Btrfs subvolumes to create                            | Array of subvolume names           | `("libvirt", "docker")`|
| **btrfs_opts**        | Mount options for Btrfs                               | Array of options                   | `("rw", "noatime")`    |

> [!WARNING]
> Be cautious when setting the `target` parameter, as it will wipe the disk. Double-check the disk identifier (e.g., `/dev/sda` or `/dev/nvme0n1`).

---

#### 4. Bootloader Settings

Choose the bootloader to install and whether to enable Secure Boot.

| Parameter      | Description                       | Supported Values            | Example Value   |
|----------------|-----------------------------------|-----------------------------|-----------------|
| **bootldr**    | Bootloader to install             | `"grub"`, `"systemd-boot"`   | `"grub"`        |
| **secure_boot**| Enable Secure Boot                | `"yes"`, `"no"`              | `"no"`          |

---

#### 5. Driver Settings

Install the appropriate CPU and GPU drivers.

| Parameter   | Description                    | Supported Values   | Example Value  |
|-------------|--------------------------------|--------------------|----------------|
| **cpu**     | CPU driver to install          | `"intel"`, `"amd"` | `"intel"`      |
| **gpu**     | GPU driver to install          | `"intel"`, `"nvidia"`| `"nvidia"`   |

---

#### 6. User Settings

Set up the root and regular user credentials.

| Parameter   | Description                    | Supported Values   | Example Value   |
|-------------|--------------------------------|--------------------|-----------------|
| **rootpwd** | Password for the root user      | Any string         | `"changeme"`    |
| **username**| Regular user account name       | Any string         | `"archuser"`    |
| **password**| Password for the regular user   | Any string         | `"changeme"`    |

---

#### 7. User Extra Settings

Configure additional preferences such as the default text editor, AUR helper, and optional services or extra packages.

| Parameter   | Description                    | Supported Values                  | Example Value    |
|-------------|--------------------------------|-----------------------------------|------------------|
| **editor**  | Default text editor            | `"vim"`, `"nano"`                 | `"vim"`          |
| **aur**     | AUR helper to install          | `"paru"`, `"yay"`                 | `"paru"`         |
| **ssh**     | Enable SSH service             | `"yes"`, `"no"`                   | `"yes"`          |
| **bluetooth**| Enable Bluetooth service      | `"yes"`, `"no"`                   | `"no"`           |
| **printer** | Enable Printer service         | `"yes"`, `"no"`                   | `"no"`           |
| **pkgs**    | Additional packages to install | Array of package names            | `("git", "curl")`|

> [!TIP]
> You can add more packages to the `pkgs` array to customize your system setup.

---

#### 8. Desktop Environment Settings

Choose the desktop environment to install.

| Parameter   | Description                    | Supported Values   | Example Value  |
|-------------|--------------------------------|--------------------|----------------|
| **de**      | Desktop environment to install | `"gnome"`, `"kde"` | `"gnome"`      |

---

### Additional Information

After completing the configuration file, you can begin the installation by running:

```bash
./install.sh arch.conf
```

The script will take care of partitioning the disk, installing the base system, setting up the bootloader, and configuring your Arch Linux installation.

> [!CAUTION]
> **Always back up important data** before running the script, as it will erase all data on the target disk.

---

## Manual Overview

### 1. Machine Preparation

This section guides you through the basic preparation of an Arch Linux machine for manual installation. It includes configuring the keyboard, enabling time synchronization, refreshing package databases, updating mirrorlists, and setting up the package manager `pacman`.

#### Base Configuration

- **Keyboard layout configuration**: Sets the keyboard layout to `us` for the installation process.
  - Command: `loadkeys us`
  
> [!NOTE]
> You can change the keyboard layout later if needed using `localectl`.

- **Enable NTP**: Activates automatic time synchronization to keep the system clock accurate.
  - Command: `timedatectl set-ntp true`
  
> [!TIP]
> You can verify that NTP is active with `timedatectl status`.

- **Update package databases**: Refreshes the local package database to ensure the latest package information is available.
  - Command: `pacman -Syy`

#### Setup Mirrorlists

- **Backup current mirrorlist**: Creates a backup of the current mirrorlist to prevent data loss during updates.
  - Command: `cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup`

> [!IMPORTANT]
> It's always a good practice to create a backup before modifying important system files.

- **Update mirrors using Reflector**: Updates the mirrorlist to use the fastest mirrors in Italy, Germany, and France.
  - Command:
    ```bash
    reflector --country "Italy,Germany,France" \
              --protocol https \
              --age 6 \
              --sort rate \
              --save /etc/pacman.d/mirrorlist
    ```

> [!TIP]
> These countries are selected based on proximity to Europe, providing fast download speeds. Adjust them according to your location.

#### Configure pacman

- **Modify pacman configuration**: Enables colorized output, a custom progress bar, verbose package lists, and parallel downloads.
  - Command:
    ```bash
    sed -i "/etc/pacman.conf" \
      -e "s|^#Color|&\nColor\nILoveCandy|" \
      -e "s|^#VerbosePkgLists|&\nVerbosePkgLists|" \
      -e "s|^#ParallelDownloads.*|&\nParallelDownloads = 20|"
    ```

> [!NOTE]
> `ILoveCandy` adds a fun graphical element to the progress bar but is optional.

- **Update pacman keyring**: Installs and initializes the latest security keys for verifying package authenticity.
  - Commands:
    - Install keyring: `pacman -S --noconfirm archlinux-keyring`
    - Initialize keys: `pacman-key --init`

> [!IMPORTANT]
> Keyring initialization is crucial to ensure package integrity and avoid verification errors.

- **Refresh package databases**: Re-run the database refresh after keyring setup.
  - Command: `pacman -Syy`

> [!CAUTION]
> Ensure that you refresh the package databases after updating the keyring to avoid package mismatch issues.

---

### 2. Disk Partitioning and Formatting

This section walks you through preparing the target disk, setting up partitions, and optionally encrypting the root partition. We will also format the partitions as either Btrfs or EXT4, depending on your setup.

#### Disk Preparation

- **Unmount all mounted partitions**: Ensures that all mounted partitions are safely unmounted.
  - Command: `umount -A --recursive /mnt`
  
> [!NOTE]
> This step ensures that no partitions on `/mnt` are active during the process.

- **Wipe all data**: Completely erases the target disk and clears the partition table.
  - Command:
    ```bash
    wipefs -af /dev/sda
    sgdisk --zap-all --clear /dev/sda
    sgdisk -a 2048 -o /dev/sda
    partprobe /dev/sda
    ```

> [!IMPORTANT]
> This operation will **erase all data** on `/dev/sda`. Make sure you have selected the correct target disk before proceeding.

- **Fill disk with random data (optional)**: This step improves security by filling the disk with random data before partitioning.
  - Command:
    ```bash
    cryptsetup open --type plain -d /dev/urandom /dev/sda target
    dd if=/dev/zero of=/dev/mapper/target bs=1M status=progress oflag=direct
    cryptsetup close target
    ```

> [!WARNING]
> This step can take a long time depending on the disk size.

#### Partitioning the Disk

- **Create partitions**: We create an EFI partition for UEFI boot and a root partition for the main system.
  - Command:
    ```bash
    sgdisk -n 0:0:+512MiB -t 0:ef00 -c 0:ESP /dev/sda  # EFI partition
    sgdisk -n 0:0:0 -t 0:8300 -c 0:rootfs /dev/sda     # Root partition
    partprobe /dev/sda
    ```

> [!TIP]
> EFI partition is 512MiB, and the root partition occupies the rest of the disk.

#### Encryption (Optional)

- **Encrypt the root partition**: If encryption is enabled, encrypt the root partition using LUKS2.
  - Command:
    ```bash
    sgdisk -t 2:8309 /dev/sda  # Set partition 2 type to LUKS
    partprobe /dev/sda
    echo -n "changeme" | cryptsetup --type luks2 -v -y luksFormat /dev/sda2 --key-file=-
    echo -n "changeme" | cryptsetup open /dev/sda2 cryptdev --key-file=-
    ```

> [!IMPORTANT]
> Replace it with a strong, secure password for production systems.

#### Formatting and Mounting

- **Format the EFI partition**: Format the EFI partition as FAT32.
  - Command: `mkfs.vfat -F32 -n ESP /dev/sda1`

- **Format the root partition**: Depending on your configuration, format the root partition as Btrfs or EXT4.

  - **For Btrfs**:
    - Command: `mkfs.btrfs -L archlinux /dev/mapper/cryptdev` (or `/dev/sda2` if not encrypted)
    - Mount root: `mount /dev/mapper/cryptdev /mnt` (or `/dev/sda2`)

    - **Create Btrfs subvolumes**:
      ```bash
      btrfs subvolume create /mnt/@
      btrfs subvolume create /mnt/@home
      btrfs subvolume create /mnt/@snapshots
      btrfs subvolume create /mnt/@cache
      btrfs subvolume create /mnt/@log
      btrfs subvolume create /mnt/@tmp
      ```

    - **Mount subvolumes**:
      ```bash
      umount /mnt
      mount -o rw,noatime,compress-force=zstd:1,space_cache=v2,subvol=@ /dev/mapper/cryptdev /mnt
      mkdir -p /mnt/{home,.snapshots,var/cache,var/log,var/tmp}
      mount -o rw,noatime,compress-force=zstd:1,space_cache=v2,subvol=@home /dev/mapper/cryptdev /mnt/home
      mount -o rw,noatime,compress-force=zstd:1,space_cache=v2,subvol=@snapshots /dev/mapper/cryptdev /mnt/.snapshots
      mount -o rw,noatime,compress-force=zstd:1,space_cache=v2,subvol=@cache /dev/mapper/cryptdev /mnt/var/cache
      mount -o rw,noatime,compress-force=zstd:1,space_cache=v2,subvol=@log /dev/mapper/cryptdev /mnt/var/log
      mount -o rw,noatime,compress-force=zstd:1,space_cache=v2,subvol=@tmp /dev/mapper/cryptdev /mnt/var/tmp
      ```

> [!TIP]
> Btrfs allows creating subvolumes to better organize and manage the filesystem.

> [!NOTE]
> Ensure you mount the Btrfs subvolumes in the correct directories.

  - **For EXT4**:
    - Command: `mkfs.ext4 -L archlinux /dev/mapper/cryptdev` (or `/dev/sda2` if not encrypted)
    - Mount root: `mount /dev/mapper/cryptdev /mnt` (or `/dev/sda2`)

- **Mount the EFI partition**: Finally, mount the EFI partition.
  - Command: `mkdir -p /mnt/esp && mount /dev/sda1 /mnt/esp`

---

### 3. Base System Installation

In this section, we will install the base system packages, generate the `fstab` file, and change root to the new system for further configuration.

#### Install Base System Packages

- **Install essential packages**: Use `pacstrap` to install the base Linux system, including the kernel, bootloader, and additional utilities.
  - Command:
    ```bash
    pacstrap /mnt base linux linux-firmware intel-ucode grub networkmanager
    ```

> [!IMPORTANT]
> The `pacstrap` command installs the basic system components, including:
> - `base`: Core system packages.
> - `linux`: The Linux kernel.
> - `linux-firmware`: Firmware for various hardware.
> - `intel-ucode`: Microcode updates for Intel CPUs (replace with `amd-ucode` for AMD CPUs).
> - `grub`: The GRUB bootloader (you can replace this with another bootloader if needed).
> - `networkmanager`: Networking service for managing connections.
  
> [!NOTE]
> You can adjust the list of packages based on your hardware or system preferences. For example, use `amd-ucode` if you're using an AMD processor, and ensure that your desired bootloader is installed.

#### Generate `fstab`

- **Generate the fstab file**: This file maps the partitions to their respective mount points.
  - Command: 
    ```bash
    genfstab -U -p /mnt >> /mnt/etc/fstab
    ```

> [!TIP]
> The `genfstab` command automatically detects the mounted partitions and generates a proper file system table (`fstab`). Always review the `fstab` to ensure all partitions are correctly listed and have the appropriate mount options.

#### Change Root into the New System

- **Change root to the new system**: After installing the base system, use `arch-chroot` to switch into the new system for further configuration.
  - Command:
    ```bash
    arch-chroot /mnt /bin/bash
    ```

> [!NOTE]
> You are now working inside your new system. Further configuration, such as setting the timezone, creating users, and installing additional packages, will be done from this environment.

---

### 4. System Configuration

This section walks through the basic configuration of the system, including setting the hostname, configuring locale settings, and setting the timezone and hardware clock.

#### Set System Hostname

- **Configure the system hostname**: Set the machine's hostname, which is used to identify the system on the network.
  - Command:
    ```bash
    echo "archlinux" > /etc/hostname
    ```

- **Configure `/etc/hosts`**: Set up local hostname resolution by adding the hostname to the `/etc/hosts` file.
  - Command:
    ```bash
    cat > /etc/hosts << EOF
    127.0.0.1   localhost
    ::1         localhost
    127.0.1.1   archlinux.localdomain archlinux
    EOF
    ```

  > [!NOTE]
  > This ensures that the system resolves its own hostname correctly.

#### Set System Locale

- **Enable the primary locale**: Edit the `/etc/locale.gen` file to enable the desired locale, in this case, `en_US.UTF-8`.
  - Command:
    ```bash
    sed -i "s/^#\(en_US.UTF-8 UTF-8\)/\1/" /etc/locale.gen
    ```

- **Enable additional locales**: If necessary, enable additional locales in `/etc/locale.gen`. For example, `it_IT.UTF-8`.
  - Command:
    ```bash
    sed -i "s/^#\(it_IT.UTF-8 UTF-8\)/\1/" /etc/locale.gen
    ```

> [!TIP]
> This step is optional and only needed if you want to support multiple languages on your system.

- **Set system language**: Configure the system's default language by setting the `LANG` variable in `/etc/locale.conf`.
  - Command:
    ```bash
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
    ```

  - **Set time locale**: Optionally, configure the time display format using `LC_TIME`.
    - Command:
      ```bash
      echo "LC_TIME=en_US.UTF-8" >> /etc/locale.conf
      ```

- **Generate locales**: Finally, generate the locales based on the configuration in `/etc/locale.gen`.
  - Command: `locale-gen`

> [!IMPORTANT]
> Make sure to run `locale-gen` to apply the locale settings correctly.

#### Set Timezone and Sync Clock

- **Set the system timezone**: Link the system timezone to `/etc/localtime`. Here, it's set to `"America/New_York"`.
  - Command:
    ```bash
    ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
    ```

- **Sync hardware clock**: Synchronize the hardware clock with the system clock.
  - Command: `hwclock --systohc`

> [!TIP]
> This ensures that the hardware clock stays in sync with the system time, even after reboots.

#### Set Console Keymap

- **Configure console keymap**: Set the console keymap to `us`.
  - Command:
    ```bash
    echo "KEYMAP=us" > /etc/vconsole.conf
    ```

> [!NOTE]
> You can change the keymap later if you need a different layout for the console.

---

### 5. User and Permissions Configuration

In this section, you will configure the root password, create a new user with `sudo` privileges, and set up password authentication for both accounts.

#### Set Root Password

- **Configure the root password**: Set the password for the `root` user to ensure secure access to the system.
  - Command:
    ```bash
    echo "root:dummy" | chpasswd
    ```

#### Create a New User

- **Add a new user**: Create a new user named `"dummy"`, assign them to the `wheel` group (for `sudo` privileges), and set their default shell to Bash.
  - Command:
    ```bash
    useradd -m -G wheel -s /bin/bash dummy
    ```

- **Set the user password**: Set the password for the new user.
  - Command:
    ```bash
    echo "dummy:dummy" | chpasswd
    ```

#### Enable Sudo for the Wheel Group

- **Grant sudo privileges**: Edit the `/etc/sudoers` file to allow members of the `wheel` group to execute commands as the superuser (`sudo`).
  - Command:
    ```bash
    sed -i "s/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/" /etc/sudoers
    ```

> [!NOTE]
> By enabling the `wheel` group in `/etc/sudoers`, the new user will be able to use `sudo` to execute administrative commands.

---

### 6. Package Manager and Build System Configuration

In this section, we will configure the `pacman` package manager for a better user experience, optimize the build system for `makepkg`, and enable automatic cache cleaning.

#### Configure `pacman`

- **Enable colored output, progress bar, verbose package lists, and parallel downloads**: Modify the `pacman.conf` file to improve the output and performance of the `pacman` package manager.
  - Command:
    ```bash
    sed -i "/etc/pacman.conf" \
        -e "s|^#Color|&\nColor\nILoveCandy|" \
        -e "s|^#VerbosePkgLists|&\nVerbosePkgLists|" \
        -e "s|^#ParallelDownloads.*|&\nParallelDownloads = 20|"
    ```

#### Optimize `makepkg`

- **Improve `makepkg` quality of life settings**: Modify the `makepkg.conf` file to optimize the package build process, setting up directories, compilation flags, and other options.
  - Command:
    ```bash
    sed -i "/etc/makepkg.conf" \
        -e "s|^#BUILDDIR=.*|&\nBUILDDIR=/var/tmp/makepkg|" \
        -e "s|^PKGEXT.*|PKGEXT='.pkg.tar'|" \
        -e "s|^OPTIONS=.*|#&\nOPTIONS=(docs \!strip \!libtool \!staticlibs emptydirs zipman purge \!debug lto)|" \
        -e "s|-march=.* -mtune=generic|-march=native|" \
        -e "s|^#RUSTFLAGS=.*|&\nRUSTFLAGS=\"-C opt-level=2 -C target-cpu=native\"|" \
        -e "s|^#MAKEFLAGS=.*|&\nMAKEFLAGS=\"-j$(($(nproc --all)-1))\"|"
    ```

> [!NOTE]
> These changes improve build performance by using all available CPU cores, optimizing build flags, and configuring other useful options like `lto` (link-time optimization).

#### Additional Package Manager Configuration

- **Install `pacman` utilities**: Install the `pacman-contrib` package, which includes useful utilities and scripts for `pacman`.
  - Command:
    ```bash
    pacman -S --noconfirm pacman-contrib
    ```

- **Enable automatic cache cleaning**: Set up `paccache.timer` to automatically clean the package cache every week.
  - Command:
    ```bash
    systemctl enable paccache.timer
    ```

- **Enable the multilib repository**: Uncomment the `[multilib]` section in `pacman.conf` to enable support for 32-bit packages.
  - Command:
    ```bash
    sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
    ```

> [!IMPORTANT]
> The multilib repository is required if you need to install 32-bit software on a 64-bit system.

- **Refresh the package database**: After modifying `pacman.conf`, refresh the package databases to apply the changes.
  - Command:
    ```bash
    pacman -Syy
    ```

> [!CAUTION]
> Always refresh the package database after enabling new repositories to avoid issues with package installations.

---

### 7. Network and System Services Configuration

This section covers enabling network services, setting up mirrors, configuring the firewall with `nftables`, and applying additional system-level configurations for network and SSD management.

#### Enable Network Services

- **Enable NetworkManager**: Start the `NetworkManager` service for managing network connections, and enable it to start at boot.
  - Command:
    ```bash
    systemctl enable NetworkManager.service
    systemctl enable NetworkManager-wait-online.service
    ```

  > [!TIP]
  > `NetworkManager-wait-online` ensures that the system waits for a stable network connection before proceeding with boot tasks.

#### Set Up Mirrors

- **Install Reflector**: Use `reflector` to optimize the mirror list based on speed and location.
  - Command:
    ```bash
    pacman -S --noconfirm reflector
    ```

- **Backup current mirrorlist**: Always backup the existing mirrorlist before making changes.
  - Command:
    ```bash
    cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
    ```

- **Optimize mirrors**: Update the mirrorlist to use the fastest HTTPS mirrors in Italy, Germany, and France.
  - Command:
    ```bash
    reflector --country "Italy,Germany,France" \
              --protocol https \
              --age 6 \
              --sort rate \
              --save /etc/pacman.d/mirrorlist
    ```

  > [!TIP]
  > Adjust the countries based on your geographical location to get the best download speeds.

- **Enable Reflector for periodic updates**: Enable the `reflector` service and timer to periodically update the mirrorlist.
  - Command:
    ```bash
    systemctl enable reflector.service
    systemctl enable reflector.timer
    ```

  > [!NOTE]
  > This ensures that your mirrorlist stays optimized automatically.

#### Firewall Configuration

- **Install and configure `nftables`**: Set up `nftables` for firewall protection and enable it to start on boot.
  - Command:
    ```bash
    pacman -S --noconfirm nftables
    ```

- **Configure `nftables`**: Set up basic firewall rules in the `/etc/nftables.conf` file to block all incoming connections except those explicitly allowed.
  - Command:
    ```bash
    bash -c "cat << EOF > /etc/nftables.conf
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
    ```

- **Enable `nftables`**: Enable the firewall service to ensure it starts on boot.
  - Command:
    ```bash
    systemctl enable nftables
    ```

> [!NOTE]
> Configuring `nftables` with these rules provides a solid security baseline by blocking unwanted traffic and allowing only trusted connections.

#### Network Kernel Parameters

- **Apply network security settings**: Set network kernel parameters in `/etc/sysctl.d/90-network.conf` to improve security.
  - Command:
    ```bash
    bash -c "cat << EOF > /etc/sysctl.d/90-network.conf
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
    ```

- **Apply the settings**: Use `sysctl` to apply the new kernel parameters.
  - Command:
    ```bash
    sysctl --system
    ```

> [!CAUTION]
> These settings enhance security by disabling IP forwarding, ICMP redirects, and enabling protection against SYN flood attacks.

#### SSD Configuration (Optional)

- **Enable `fstrim` for SSDs**: If your system is using an SSD, enable `fstrim` to periodically free unused blocks.
  - Command:
    ```bash
    pacman -S --noconfirm util-linux
    systemctl enable --now fstrim.timer
    ```

> [!NOTE]
> `fstrim` is a maintenance service that helps prolong the lifespan of SSDs by optimizing storage block usage.

---

### 8. Keyfile Setup and Initramfs Configuration

In this section, you will learn how to configure a keyfile for LUKS encryption to avoid being prompted for a passphrase multiple times. Additionally, we will update the initramfs (`mkinitcpio`) configuration based on whether encryption and Btrfs are used.

#### Configure Keyfile for LUKS Encryption (Optional)

- **Generate a keyfile**: If encryption is enabled, create a keyfile that can be used to unlock the encrypted partition without prompting for a passphrase multiple times.
  - Command:
    ```bash
    dd bs=512 count=4 iflag=fullblock if=/dev/random of=/key.bin
    chmod 600 /key.bin
    cryptsetup luksAddKey /dev/sda2 /key.bin
    ```

> [!IMPORTANT]
> The keyfile is stored as `/key.bin`, and its permissions are restricted to ensure security (`chmod 600`). Make sure this file is backed up securely.

- **Add the keyfile to initramfs**: Update the `mkinitcpio.conf` to include the keyfile in the initramfs so that it's available at boot time.
  - Command:
    ```bash
    sed -i '/^FILES=/ s/)/ \/key.bin)/' /etc/mkinitcpio.conf
    ```

> [!TIP]
> Adding the keyfile to `FILES=` ensures that it is included during the boot process, allowing the system to decrypt the partition automatically.

#### Update Hooks in Initramfs

- **Configure hooks for encrypted Btrfs setups**: If both encryption and Btrfs are used, update the `HOOKS` section in `/etc/mkinitcpio.conf` to include the necessary hooks for encryption and the Btrfs filesystem.
  - Command:
    ```bash
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block encrypt btrfs filesystems fsck)/' /etc/mkinitcpio.conf
    ```

> [!NOTE]
> The `encrypt` and `btrfs` hooks are crucial for properly handling encrypted Btrfs partitions during boot.

- **Configure hooks for non-Btrfs encrypted setups**: If encryption is enabled but Btrfs is not used, update the hooks without including the `btrfs` module.
  - Command:
    ```bash
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block encrypt lvm2 filesystems fsck)/' /etc/mkinitcpio.conf
    ```

- **Configure hooks without encryption**: If encryption is not enabled, configure the hooks accordingly. For systems using Btrfs:
  - Command:
    ```bash
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block btrfs filesystems fsck)/' /etc/mkinitcpio.conf
    ```

  For systems without encryption and without Btrfs:
  - Command:
    ```bash
    sed -i '/^HOOKS=/ s/(.*)/(base udev keyboard autodetect microcode keymap consolefont modconf block filesystems fsck)/' /etc/mkinitcpio.conf
    ```

> [!IMPORTANT]
> The hooks determine how the system initializes during boot. Make sure to adjust them based on your filesystem and encryption setup.

#### Include Btrfs Module (Optional)

- **Add `btrfs` module**: If Btrfs is used as the root filesystem, add the `btrfs` module to the `MODULES` section in `/etc/mkinitcpio.conf`.
  - Command:
    ```bash
    sed -i '/^MODULES=/ s/)/ btrfs)/' /etc/mkinitcpio.conf
    ```

> [!NOTE]
> Adding the `btrfs` module ensures that the system can properly mount Btrfs partitions during the boot process.

#### Generate Initramfs

- **Regenerate the initramfs**: After making changes to the `mkinitcpio.conf`, regenerate the initramfs to apply the configuration.
  - Command:
    ```bash
    mkinitcpio -P
    ```

> [!CAUTION]
> Failing to regenerate the initramfs after making changes to the configuration may result in an unbootable system.

---

### 9. Bootloader Configuration (GRUB)

In this section, we configure the GRUB bootloader, update its settings, and handle encrypted partitions if needed. We also cover optional Secure Boot setup.

#### Backup GRUB Configuration

- **Backup current GRUB configuration**: It's a good practice to create a backup of the current GRUB configuration before making any changes.
  - Command:
    ```bash
    cp /etc/default/grub /etc/default/grub.backup
    ```

#### Update GRUB Settings

- **Modify GRUB timeout**: Set the GRUB menu timeout to 30 seconds.
  - Command:
    ```bash
    sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=30/" /etc/default/grub
    ```

- **Use the last boot selection**: Set GRUB to remember and boot the last selected menu entry by default.
  - Command:
    ```bash
    sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/" /etc/default/grub
    sed -i "s/^#GRUB_SAVEDEFAULT=.*/GRUB_SAVEDEFAULT=y/" /etc/default/grub
    ```

- **Disable GRUB submenus**: Simplify the GRUB menu by disabling submenus.
  - Command:
    ```bash
    sed -i "s/^#GRUB_DISABLE_SUBMENU=.*/GRUB_DISABLE_SUBMENU=y/" /etc/default/grub
    ```

- **Enable OS Prober**: Allow GRUB to detect other operating systems installed on the system.
  - Command:
    ```bash
    sed -i "s/^#GRUB_DISABLE_OS_PROBER=.*/GRUB_DISABLE_OS_PROBER=false/" /etc/default/grub
    ```

> [!NOTE]
> Enabling OS Prober is useful if you have a dual-boot setup.

#### Configure GRUB for Encrypted Partitions (Optional)

- **Add encryption support to GRUB**: If encryption is enabled, modify GRUB to include the UUID of the encrypted partition.
  - Command:
    ```bash
    uuid=$(blkid -s UUID -o value /dev/sda2)  # Get UUID of the encrypted partition
    sed -i "s/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 cryptdevice=UUID=$uuid:cryptdev\"/" /etc/default/grub
    sed -i "s/^GRUB_PRELOAD_MODULES=.*/GRUB_PRELOAD_MODULES=\"part_gpt part_msdos luks\"/" /etc/default/grub
    sed -i "s/^#GRUB_ENABLE_CRYPTODISK=.*/GRUB_ENABLE_CRYPTODISK=y/" /etc/default/grub
    ```

  > [!IMPORTANT]
  > These changes ensure that GRUB is aware of the encrypted partition and can unlock it at boot.

#### Install GRUB to EFI Partition

- **Install GRUB to the EFI partition**: Install GRUB on the system in UEFI mode, ensuring it is configured correctly.
  - Command:
    ```bash
    grub-install --target=x86_64-efi --efi-directory=/esp --bootloader-id=GRUB --modules="tpm" --disable-shim-lock
    ```

  > [!TIP]
  > Replace `/esp` with the mount point of your EFI partition if it differs.

- **Generate GRUB configuration**: After modifying GRUB, regenerate its configuration to apply the changes.
  - Command:
    ```bash
    grub-mkconfig -o /boot/grub/grub.cfg
    ```

#### Configure Secure Boot (Optional)

- **Set up Secure Boot**: If Secure Boot is enabled, use `sbctl` to manage keys and sign the necessary boot files.
  - Command:
    ```bash
    pacman -S --noconfirm sbctl
    sbctl create-keys && sbctl enroll-keys -m
    ```

- **Sign boot files**: Sign the bootloader and kernel with Secure Boot keys.
  - Command:
    ```bash
    sbctl sign -s /esp/EFI/GRUB/grubx64.efi \
            -s /esp/grub/x86_64-efi/core.efi \
            -s /esp/grub/x86_64-efi/grub.efi \
            -s /esp/vmlinuz-linux-zen
    ```

> [!CAUTION]
> Make sure your system is in "Setup Mode" for Secure Boot when enrolling the keys, or the process may fail.

#### Alternative Bootloader (Systemd-boot)

- **Systemd-boot (WIP)**: The configuration for systemd-boot is still in progress and not yet available in this guide.

---

### 10. PipeWire Installation and Configuration

In this section, we install and configure PipeWire, which is a modern multimedia server for handling audio and video streams, replacing traditional sound servers like PulseAudio and JACK.

#### Install PipeWire and Related Packages

- **Install PipeWire**: Install the core PipeWire packages along with additional modules for handling various audio systems such as JACK, ALSA, and PulseAudio.
  - Command:
    ```bash
    pacman -S --noconfirm pipewire lib32-pipewire \
                    pipewire-jack lib32-pipewire-jack \
                    wireplumber \
                    pipewire-alsa \
                    pipewire-audio \
                    pipewire-ffado \
                    pipewire-pulse \
                    pipewire-docs
    ```

> [!NOTE]
> This command installs both the 64-bit and 32-bit versions of PipeWire, along with important modules:
> - **pipewire-jack**: Provides compatibility with JACK applications.
> - **pipewire-alsa**: Provides ALSA support.
> - **pipewire-pulse**: Replaces PulseAudio for better performance and integration.
> - **wireplumber**: The session manager for PipeWire.
> - **pipewire-ffado**: Provides support for FireWire devices (if needed).

> [!TIP]
> Installing `pipewire-docs` includes the official documentation, which is helpful for reference.

#### Post-installation Setup

- **Set PipeWire as the default sound server**: Ensure that PipeWire replaces PulseAudio and JACK as the system's default sound server.
  
> [!IMPORTANT]
> After installation, you may need to stop and disable PulseAudio if it’s currently running:
> ```bash
> systemctl --user disable pulseaudio.service pulseaudio.socket
> systemctl --user stop pulseaudio.service pulseaudio.socket
> ```
> Additionally, ensure that PipeWire is enabled:
> ```bash
> systemctl --user enable pipewire pipewire-pulse
> systemctl --user start pipewire pipewire-pulse
> ```

#### Verify Installation

- **Check PipeWire status**: After installation, verify that PipeWire is running correctly.
  - Command:
    ```bash
    systemctl --user status pipewire
    ```

> [!TIP]
> Use `pw-cli info` to get detailed information about the current PipeWire setup, including connected devices and active streams.

---

### 11. GPU Driver Installation and Configuration

In this section, we will install and configure the appropriate drivers for either NVIDIA or Intel GPUs. Depending on your system's GPU, follow the corresponding instructions for installation and kernel module configuration.

#### NVIDIA GPU Setup

- **Install NVIDIA drivers**: Install the open-source NVIDIA drivers, along with necessary utilities and 32-bit libraries.
  - Command:
    ```bash
    pacman -S --noconfirm nvidia-open nvidia-open-dkms \
                    nvidia-utils opencl-nvidia \
                    lib32-nvidia-utils lib32-opencl-nvidia \
                    nvidia-settings
    ```

> [!TIP]
> `nvidia-open` and `nvidia-open-dkms` are the open-source variants of the NVIDIA drivers. `nvidia-utils` and `lib32-nvidia-utils` provide support for both 64-bit and 32-bit applications, while `nvidia-settings` allows you to adjust GPU settings.

- **Configure kernel modules**: Add the necessary NVIDIA kernel modules to the `mkinitcpio.conf` file.
  - Command:
    ```bash
    sed -i '/^MODULES=/ s/(\(.*\))/(\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    ```

- **Enable modesetting**: Modify the GRUB configuration to enable `nvidia_drm.modeset=1` for proper graphics handling.
  - Command:
    ```bash
    sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 nvidia_drm.modeset=1"/' /etc/default/grub
    ```

- **Add udev rule for NVIDIA**: Create a `udev` rule to ensure proper handling of the NVIDIA driver during system events.
  - Command:
    ```bash
    bash -c 'echo "ACTION==\"add\", DEVPATH==\"/bus/pci/drivers/nvidia\", RUN+=\"/usr/bin/nvidia-modprobe -c 0 -u\"" > /etc/udev/rules.d/70-nvidia.rules'
    ```

- **Enable power management**: Configure the NVIDIA driver to preserve video memory allocations across sleep and suspend states.
  - Command:
    ```bash
    bash -c 'echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" > /etc/modprobe.d/nvidia-power-mgmt.conf'
    ```

- **Regenerate initramfs and GRUB configuration**: After making these changes, regenerate the initial ramdisk and GRUB configuration to apply the changes.
  - Commands:
    ```bash
    mkinitcpio -P
    grub-mkconfig -o /boot/grub/grub.cfg
    ```

> [!IMPORTANT]
> These steps are crucial for ensuring that the NVIDIA drivers are properly loaded during boot and that modesetting is enabled for optimal performance.

#### Intel GPU Setup

- **Install Intel drivers**: Install the necessary drivers and libraries for Intel GPUs.
  - Command:
    ```bash
    pacman -S --noconfirm mesa lib32-mesa \
                    intel-media-driver libva-intel-driver \
                    vulkan-intel lib32-vulkan-intel
    ```

> [!NOTE]
> `mesa` provides the open-source graphics drivers for Intel, while `vulkan-intel` and `lib32-vulkan-intel` enable Vulkan support for both 64-bit and 32-bit applications. `intel-media-driver` and `libva-intel-driver` provide media acceleration.

- **Configure kernel modules**: Add the Intel GPU kernel module `i915` to the `mkinitcpio.conf` file.
  - Command:
    ```bash
    sed -i '/^MODULES=/ s/(\(.*\))/(\1 i915)/' /etc/mkinitcpio.conf
    ```

- **Regenerate initramfs and GRUB configuration**: As with NVIDIA, regenerate the initial ramdisk and GRUB configuration after making the necessary changes.
  - Commands:
    ```bash
    mkinitcpio -P
    grub-mkconfig -o /boot/grub/grub.cfg
    ```

> [!TIP]
> The `i915` module is required for Intel integrated graphics, ensuring proper loading during boot.

---

### 12. Extra Software and Service Configuration

In this section, we will install the default editor, additional user packages, AUR helpers, and optional services like SSH, Bluetooth, and printer support.

#### Install Default Editor

- **Install the default text editor**: Install `vim` as the default editor.
  - Command:
    ```bash
    sudo pacman -S --noconfirm vim
    ```

- **Set environment variables for the editor**: Configure both `EDITOR` and `VISUAL` environment variables to use `vim`.
  - Command:
    ```bash
    echo "EDITOR=vim" | sudo tee -a /etc/environment
    echo "VISUAL=vim" | sudo tee -a /etc/environment
    ```

> [!NOTE]
> Setting both `EDITOR` and `VISUAL` ensures that the preferred editor is consistently used across different applications.

#### Install Additional Packages

- **Install extra user packages**: Install additional packages like `git`, `curl`, and `wget`.
  - Command:
    ```bash
    sudo pacman -S --noconfirm git curl wget
    ```

#### Install AUR Helper

- **Install `paru` AUR helper**: If `paru` is selected as the AUR helper, install it by cloning from the AUR and building the package.
  - Command:
    ```bash
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd - && rm -rf /tmp/paru
    sudo pacman -Syyu --noconfirm
    paru -Syyu --noconfirm
    ```

- **Install `yay` AUR helper**: If `yay` is preferred, follow the same steps but use `yay` instead of `paru`.
  - Command:
    ```bash
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd - && rm -rf /tmp/yay
    sudo pacman -Syyu --noconfirm
    yay -Syyu --noconfirm
    ```

> [!NOTE]
> Both `paru` and `yay` are popular AUR helpers that allow easy installation of packages from the Arch User Repository.

#### Install Quality of Life Tools

- **Install `pkgfile`**: Install `pkgfile`, which provides command-not-found support and allows searching for packages containing specific files.
  - Command:
    ```bash
    paru -S --noconfirm pkgfile
    sudo pkgfile --update
    ```

- **Install `tealdeer`**: Install the `tealdeer` tool for quick access to `tldr` pages, which offer simplified manual pages for common commands.
  - Command:
    ```bash
    paru -S --noconfirm tealdeer
    tldr --update
    ```

- **Install `mlocate`**: Install `mlocate`, a fast file search tool, and update the file database.
  - Command:
    ```bash
    sudo pacman -S --noconfirm mlocate
    sudo updatedb
    ```

#### Enable Command-not-found Support

- **Add command-not-found support**: Append the necessary configuration to `.bashrc` to enable command-not-found support using `pkgfile`.
  - Command:
    ```bash
    BASHRC="$HOME/.bashrc"
    CONTENT='
    # Command-not-found support for pkgfile
    if [[ -f /usr/share/doc/pkgfile/command-not-found.bash ]]; then
        . /usr/share/doc/pkgfile/command-not-found.bash
    fi
    '
    if ! grep -q "/usr/share/doc/pkgfile/command-not-found.bash" "$BASHRC"; then
        echo "$CONTENT" >> "$BASHRC"
    fi
    ```

#### Install and Enable Optional Services

- **Enable SSH**: If SSH is needed, install `openssh` and enable the `sshd` service.
  - Command:
    ```bash
    sudo pacman -S --noconfirm openssh
    sudo systemctl enable sshd.service
    ```

- **Enable Bluetooth**: If Bluetooth support is needed, install `bluez` and related packages, and ensure proper configuration in the Bluetooth settings.
  - Command:
    ```bash
    sudo pacman -S --noconfirm bluez bluez-utils bluez-tools
    BLUETOOTH_CONF="/etc/bluetooth/main.conf"
    if grep -q "^#*ControllerMode = dual" "$BLUETOOTH_CONF"; then
        sudo sed -i 's/^#*ControllerMode = dual/ControllerMode = dual/' "$BLUETOOTH_CONF"
    else
        echo "ControllerMode = dual" | sudo tee -a "$BLUETOOTH_CONF"
    fi
    if grep -q "^\[General\]" "$BLUETOOTH_CONF"; then
        if grep -q "^#*Experimental = false" "$BLUETOOTH_CONF"; then
            sudo sed -i 's/^#*Experimental = false/Experimental = true/' "$BLUETOOTH_CONF"
        elif ! grep -q "^Experimental = true" "$BLUETOOTH_CONF"; then
            sudo sed -i '/^\[General\]/a Experimental = true' "$BLUETOOTH_CONF"
        fi
    else
        echo -e "\n[General]\nExperimental = true" | sudo tee -a "$BLUETOOTH_CONF"
    fi
    ```

> [!NOTE]
> Ensure that Bluetooth is configured correctly for dual mode (`ControllerMode = dual`) and that experimental features are enabled (`Experimental = true`).

- **Enable Printer Support**: If printer support is needed, install `cups` and enable the related services.
  - Command:
    ```bash
    sudo pacman -S --noconfirm cups cups-pdf bluez-cups
    sudo systemctl enable cups.service
    ```

> [!NOTE]
> Printer support through CUPS allows you to manage printers, including network printers and PDF printing.

---

### 13. GNOME Desktop Environment Configuration

In this section, we will install and configure the GNOME desktop environment (DE), set custom keybindings, and install additional packages and GNOME Shell extensions.

#### Install GNOME and Configure GDM

- **Install GNOME**: Install the full GNOME desktop environment, including the display manager GDM.
  - Command:
    ```bash
    sudo pacman -S --noconfirm gnome gnome-extra
    ```

- **Disable GDM rule**: Disable the `GDM` rule by linking it to `/dev/null`.
  - Command:
    ```bash
    sudo ln -sf /dev/null /etc/udev/rules.d/61-gdm.rules
    ```

- **Enable Wayland in GDM**: Edit the GDM configuration to enable Wayland as the display server protocol.
  - Command:
    ```bash
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=true/' /etc/gdm/custom.conf
    ```

> [!TIP]
> Enabling Wayland in GDM ensures compatibility with modern display protocols for smoother rendering and enhanced security.

#### Configure GNOME Keybindings

- **Reset conflicting shortcuts**: Remove the default application switching shortcuts to avoid conflicts.
  - Command:
    ```bash
    for i in {1..9}; do
        dconf write "/org/gnome/shell/keybindings/switch-to-application-${i}" "@as []"
    done
    ```

- **Set custom keybindings**: Customize GNOME keybindings for closing windows, launching applications, and workspace navigation.
  - Commands:
    - Close window: `dconf write /org/gnome/desktop/wm/keybindings/close "['<Super>q', '<Alt>F4']"`
    - Launch terminal: `dconf write /org/gnome/settings-daemon/plugins/media-keys/terminal "['<Super>t']"`
    - Launch web browser: `dconf write /org/gnome/settings-daemon/plugins/media-keys/www "['<Super>f']"`
    - Lock screen: `dconf write /org/gnome/settings-daemon/plugins/media-keys/screensaver "['<Super>Escape']"`

> [!TIP]
> These custom keybindings provide quicker access to common tasks and improve the overall user experience in GNOME.

#### Install GNOME Packages

- **Base GNOME packages**: Install essential GNOME utilities like `gnome-control-center`, `gnome-tweaks`, and `extension-manager`.
  - Command:
    ```bash
    sudo pacman -S --noconfirm gnome-control-center gnome-tweaks extension-manager
    ```

- **File manager and addons**: Install `nautilus` (the default GNOME file manager) and useful extensions like `nautilus-share` and `nautilus-open-any-terminal`.
  - Command:
    ```bash
    sudo pacman -S --noconfirm nautilus nautilus-share nautilus-open-any-terminal
    ```

- **GNOME applications**: Install additional GNOME applications such as `firefox`, `thunderbird`, `gnome-calculator`, and `gnome-text-editor`.
  - Command:
    ```bash
    sudo pacman -S --noconfirm firefox thunderbird gnome-calculator gnome-text-editor
    ```

#### Install GNOME Shell Extensions

- **GNOME Shell extensions**: Install popular extensions to customize the GNOME Shell experience.
  - Command:
    ```bash
    sudo pacman -S --noconfirm gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-arc-menu
    ```

> [!NOTE]
> Extensions like `blur-my-shell` and `dash-to-dock` enhance the visual appearance and usability of the GNOME desktop.

#### Enable GDM

- **Enable GDM service**: After installation, enable the GDM display manager to start GNOME on boot.
  - Command:
    ```bash
    sudo systemctl enable gdm.service
    ```
