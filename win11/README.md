# Windows 11

**TL;DR**: Resources used to create this guide:

### BIOS Tweak Resources

- [BIOS Settings for 7950x3D and 7800x3D on Asus Rog Strix B650E-F](https://www.youtube.com/watch?v=kqAsNB5xCVI)
- [Undervolting Ryzen 7 7800X3D for More FPS and Lower Temperatures](https://www.youtube.com/watch?v=BNAs3bl-yv0)
- [Fixing AMD Core-Parking Problems](https://www.youtube.com/watch?v=4wdQpVcL_a4)

### Base Optimization Resources

- [New Windows Tool and MicroWin 5-Minute Install](https://www.youtube.com/watch?v=92SM8Az5QVM)
- [AMD is getting SCREWED by Microsoft - Windows 10 vs 11](https://www.youtube.com/watch?v=mVpv-EpEoGM)

### Additional Topics

- Gaming Improvements
- Other Customizations

---

## Getting Started: BIOS Update

Start by updating your motherboard BIOS. Follow the manufacturer’s instructions carefully. Here are some resources for the **Asus B650E-F** motherboard:

- [BIOS Download](https://rog.asus.com/it/motherboards/rog-strix/rog-strix-b650e-f-gaming-wifi-model/helpdesk_bios/)
- [Ez Flash Guide](https://www.youtube.com/watch?v=Em7SRaG3L_0)
- [BIOS Flashback Guide](https://www.youtube.com/watch?v=FPyElZcsW6o)

---

## BIOS Tweaks

In this section, I will list all the BIOS parameters that have been changed from their default values.

> ⚠️ **Warning**: Some values might be universal across different manufacturers, but double-check each setting for your specific motherboard.

### AI Tweaker Settings

| **Setting**                     | **Value**                      |
|----------------------------------|---------------------------------|
| Ai Overlock Tuner                | DOCP II / EXPO II               |
| FCLK Frequency                   | 1/3 of max RAM speed (e.g., 2000 MHz) |
| Power Down Enable                | Disabled                       |
| Memory Context Restore           | Disabled                       |
| UCLK DIV1 Mode                   | UCLK = MEMCLK                   |

> 💡 **Tip**: Ensure your RAM speed is set to the maximum supported frequency.

### DRAM Timing Control

| **Setting**                     | **Value**                      |
|----------------------------------|---------------------------------|
| CPU Load-line Calibration        | Level 3 / Level 4 / Auto        |
| CPU Current Capability           | 120%                           |
| CPU Power Duty Control           | Extreme                        |
| CPU Power Phase Control          | Extreme                        |
| VDDSOC Current Capability        | 120%                           |

### Advanced Settings

| **Setting**                     | **Value**                      |
|----------------------------------|---------------------------------|
| Precision Boost Override         | Level 3 (80°C)                 |
| Curve Optimizer                  | All cores, Negative, -20        |
| SoC/Uncore OC Mode               | Enabled                        |
| PSS Support                      | Disabled                       |
| SVM Mode                         | Disabled                       |
| Resize BAR Support               | Enabled                        |

### AMD CBS Settings

| **Setting**                     | **Value**                      |
|----------------------------------|---------------------------------|
| Global C-State Control           | Disabled                       |
| IOMMU                            | Disabled                       |
| Power Supply Idle Control        | Typical Current Idle            |
| CPPC Dynamic Preferred Cores     | Drivers (fix for 3D CPUs)       |

> 💡 **Tip**: Disable any unnecessary apps in BIOS that may automatically download from Asus.

> 💾 **Save** the profile when you're done. The BIOS setup is complete!

---

## Base Optimization

To optimize your system, follow this [video guide](https://www.youtube.com/watch?v=92SM8Az5QVM) to create a clean and lightweight Windows ISO.

> 💡 **Tip**: I recommend performing a standard Windows 11 installation first, installing necessary drivers, and then creating a custom ISO. Include your installed drivers in the custom ISO for convenience.

### Steps Overview

1. Download the latest version of **Windows 11**.
2. Install Windows and configure it with the basic drivers.
3. Run **[Chris Titus Tech's Windows Utility](https://github.com/christitustech/winutil)** to optimize your system.

```powershell
irm "https://christitus.com/win" | iex
```

4. Create a **MicroWin ISO** with the following settings:
   - Default MicroWin configurations.
   - Include the current system drivers.
   - Set a system username and password.
5. Create a bootable USB drive with the newly generated ISO.

> 💡 **Tip**: When installing Windows 11, use the following locale settings:
>
> - **Language**: English (United States) / International
> - **Time and Currency Format**: English (United States)
> - **Keyboard**: US / International

---

## Windows 11 Default Tweaks

Here are a few Windows 11 settings that should be adjusted for better gaming performance:

### Windows Settings

- **Core Isolation**: OFF

### Chris Titus Tech's Windows Utility

- **Tweaks**: Use either the **Standard** or **Minimal** profile. Additionally, activate:
  - **Dark Theme for Windows**: ON
  - **Disable Microsoft Copilot**: ON

> 💡 **Tip**: You can apply more tweaks to strip down unnecessary services and features from Windows. Take your time to read through each option to understand its impact.