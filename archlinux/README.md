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

Per rendere più distinti i titoli di livello 4 dai testi in grassetto, puoi aggiungere maggiore enfasi visiva, ad esempio con l'uso di sottolineature o introducendo stili per separare i titoli dal testo normale. Ecco una versione migliorata con titoli di livello 4 più distinti:

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

### 2. Disk formatting
