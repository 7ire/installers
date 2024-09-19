# Windows 11

**TLTR** Resources used to create this guide:

- BIOS Tweak
  - [Bios Settings 7950x3D 7800x3D [Asus Rog Strix B650E-F]](https://www.youtube.com/watch?v=kqAsNB5xCVI)
  - [Undervolt your Ryzen 7 7800X3D for more FPS and Lower Temperature!](https://www.youtube.com/watch?v=BNAs3bl-yv0)
- Base optimization
- Gaming improvements
- Other

Start by updating motherboard BIOS, you can follow the manufacture instructions.

For my reference I have a Asus B650E-F:

- [BIOS Download](https://rog.asus.com/it/motherboards/rog-strix/rog-strix-b650e-f-gaming-wifi-model/helpdesk_bios/)
- [Ez Flash](https://www.youtube.com/watch?v=Em7SRaG3L_0)
- [BIOS Flashback](https://www.youtube.com/watch?v=FPyElZcsW6o)

## BIOS Tweak

In this section it is gonna be listed all the BIOS parameters that are changed from their respective default values.

> [!WARNING]
> Some values should be universal for each manufacture and models, but double check to be 100% sure for each settings.

**AI Tweaker**:

- Ai Overlock Tuner => **DOCP II / EXPO II**

> [!NOTE]
> Make sure the RAM speed is the highest you can get.

- FLCK freq => **1/3 of you MAX speed**, in my case 2000Mhz
- DRAM Timing control:
  - Power Down Enable => **Disable**
  - Memory Context Restore => **Disable**
  - UCLK DIV1 Mode => **UCLK = MEMCLK**
- DIGI + VRM:
  - CPU Load-time Calibration => **Level 3 / Level 4 / Auto**
  - CPU Current Capability => **120%**
  - CPU Power Duty Control => **Extreme**
  - CPU Power Phase Control => **Extreme**
  - VDDSOC Current Capability => **120%**
  - 

**Advance**:

- AMD Overclocking:
  - Precision Boost Override:
    - Enhancement (or Advance, based on which give you the Level) => **Level 3 (80°)**
    - Curve Optimizer (not GFX, is the integrated GPU) => **All cores**, **Negative**, **20**
  - SoC/Uncore OC Mode => **Enable**
- CPU Configuration:
  - PSS Support => **Disable**
  - SVM Mode => **Disable**
- PCI Subsystem Setting/Resize BAR Support => **Enable**
- AMD CBS:
  - Global C-State control => **Disable**
  - IOMMU => **Disable**
  - CPU Common Option:
    - Power Supply Common Control => **Typical Current Idle**

> [!NOTE]
> Disable some useless app in the BIOS that Asus will try to download automatically.

Finally remember to save the profile and the BIOS section is done :D

## Base optimization
