# Windows 11

**TL;DR**: Resources used to create this guide:

**Base Optimization Resources**:

- [New Windows Tool and MicroWin 5-Minute Install](https://www.youtube.com/watch?v=92SM8Az5QVM)
- [AMD is getting SCREWED by Microsoft - Windows 10 vs 11](https://www.youtube.com/watch?v=mVpv-EpEoGM)

**Additional Topics**:

- [Guide for Amit's Timer Resolution (Better FPS Lows)](https://www.youtube.com/watch?v=AcCFZ8hhXi8)
- [BEST Nvidia Control Panel Settings 2024 Explained](https://www.youtube.com/watch?v=6-62fFTcA1Y)
- [Win32 Priority Separation Benchmarks](https://www.youtube.com/watch?v=wTdeyFk8Xv0)
- [General PC optimization](https://www.youtube.com/watch?v=iBiNfa32AnE)

---

## Base Optimization

To optimize your system, follow this [video guide](https://www.youtube.com/watch?v=92SM8Az5QVM) to create a clean and lightweight Windows ISO.

> [!TIP]
> I recommend performing a standard Windows 11 installation first, installing necessary drivers, and then creating a custom ISO. Include your installed drivers in the custom ISO for convenience.

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

> [!TIP]
> When installing Windows 11, use the following locale settings:
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

> [!NOTE]
> You can apply more tweaks to strip down unnecessary services and features from Windows. Take your time to read through each option to understand its impact.
