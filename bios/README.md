# BIOS Tweaking

## Asus B650E-F

> [!NOTE]
> TL;DR: Resources used to create this guide:

**BIOS Tweak Resources**:

- [BIOS Settings for 7950x3D and 7800x3D on Asus Rog Strix B650E-F](https://www.youtube.com/watch?v=kqAsNB5xCVI)
- [Undervolting Ryzen 7 7800X3D for More FPS and Lower Temperatures](https://www.youtube.com/watch?v=BNAs3bl-yv0)
- [Fixing AMD Core-Parking Problems](https://www.youtube.com/watch?v=4wdQpVcL_a4)

---

### Getting Started: BIOS Update

Start by updating your motherboard BIOS. Follow the manufacturer’s instructions carefully:

- [BIOS Download](https://rog.asus.com/it/motherboards/rog-strix/rog-strix-b650e-f-gaming-wifi-model/helpdesk_bios/)
- [Ez Flash Guide](https://www.youtube.com/watch?v=Em7SRaG3L_0)
- [BIOS Flashback Guide](https://www.youtube.com/watch?v=FPyElZcsW6o)

### BIOS Tweaks

In this section, I will list all the BIOS parameters that have been changed from their default values.

> [!WARNING]
> Some values might be universal across different manufacturers, but double-check each setting for your specific motherboard.

#### AI Tweaker Settings

| **Setting**                      | **Value**                             |
|----------------------------------|---------------------------------------|
| Ai Overlock Tuner                | DOCP II / EXPO II                     |
| FCLK Frequency                   | 1/3 of max RAM speed (e.g., 2000 MHz) |
| Power Down Enable                | Disabled                              |
| Memory Context Restore           | Disabled                              |
| UCLK DIV1 Mode                   | UCLK = MEMCLK                         |

> [!TIP]
> Ensure your RAM speed is set to the maximum supported frequency.

#### DRAM Timing Control

| **Setting**                      | **Value**                       |
|----------------------------------|---------------------------------|
| CPU Load-line Calibration        | Level 3 / Level 4 / Auto        |
| CPU Current Capability           | 120%                            |
| CPU Power Duty Control           | Extreme                         |
| CPU Power Phase Control          | Extreme                         |
| VDDSOC Current Capability        | 120%                            |

#### Advanced Settings

| **Setting**                      | **Value**                       |
|----------------------------------|---------------------------------|
| Precision Boost Override         | Level 3 (80°C)                  |
| Curve Optimizer                  | All cores, Negative, 20         |
| SoC/Uncore OC Mode               | Enabled                         |
| PSS Support                      | Disabled                        |
| SVM Mode                         | Disabled                        |
| Resize BAR Support               | Enabled                         |

#### AMD CBS Settings

| **Setting**                      | **Value**                       |
|----------------------------------|---------------------------------|
| Global C-State Control           | Disabled                        |
| IOMMU                            | Disabled                        |
| Power Supply Idle Control        | Typical Current Idle            |
| CPPC Dynamic Preferred Cores     | Drivers (fix for 3D CPUs)       |

> [!TIP]
> Disable any unnecessary apps in BIOS that may automatically download from Asus.

💾 **Save** the profile when you're done. The BIOS setup is complete!

---
