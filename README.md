# limine-vfio

Dynamic PCI Device Passthrough Manager and Bootloader Hook for **Limine** on Arch Linux & CachyOS.

`limine-vfio` (formerly `cachyos-vfio`) provides an automated, device-agnostic utility to manage PCI passthrough and hardware isolation. It automates hardware discovery, device classification, IOMMU isolation validation, dynamic Limine boot entry generation, and driver exclusion.

It supports passing through **GPUs**, **Network Adapters (NICs)**, **USB Controllers**, **Storage Controllers (NVMe/SATA)**, **Audio Cards**, **Capture Cards**, and **Hardware Accelerators**.

---

## Key Features & Safeguards

- **Device Agnostic Classification:** Scans the PCI bus and classifies devices (`GPU`, `NETWORK`, `USB`, `STORAGE`, `CAPTURE`, `ACCELERATOR`, `AUDIO`, `SYSTEM`).
- **Pre-Flight Environment Safeguards:**
  - **UEFI Mode Check:** Verifies the system is booted in UEFI mode (`/sys/firmware/efi`).
  - **Limine Bootloader Validation:** Verifies Limine bootloader configuration and entry tools are present.
  - **CPU Virtualization Validation:** Detects AMD-V (`svm`) or Intel VT-x (`vmx`) extensions.
  - **IOMMU Group Isolation Guard:** Checks for sibling devices sharing the same IOMMU group and warns if isolation could cause host instability.
- **Dynamic Bootloader Entries:** Seamless post-hook (`95-vfio-entries`) integrates with `limine-entry-tool` and `limine-update` to generate kernel-specific passthrough boot options without touching default boots.
- **Arch / AUR Ready:** Full `PKGBUILD`, `limine-vfio.install`, and `.SRCINFO` packaging.
- **Backward Compatible:** Symlinked `cachyos-vfio` alias is maintained for existing setups.

---

## Hardware Classification Reference

| Classification | Typical Devices | Companion & Isolation Logic |
| :--- | :--- | :--- |
| **`GPU`** | NVIDIA RTX / GTX, AMD Radeon, Intel Arc | Automatically pairs companion HDMI/DP audio controllers; prompts for host driver exclusion only if secondary NVIDIA. |
| **`NETWORK`** | 10GbE / 2.5GbE NICs, Wi-Fi 7 adapters | Groups multi-port companion interfaces on the same PCIe card. |
| **`USB`** | Dedicated PCIe USB 3.x / Thunderbolt controllers | Isolates external host controllers for guest hotplugging. |
| **`STORAGE`** | NVMe SSD controllers, dedicated SATA controllers | Isolates raw storage controllers for bare-metal guest I/O performance. |
| **`CAPTURE`** | Video capture cards (Elgato, Blackmagic, AverMedia) | Isolates streaming and capture hardware for dedicated guest ingestion. |
| **`ACCELERATOR`** | NPUs, TPUs, crypto accelerators, FPGAs | Dedicated compute and machine learning acceleration passthrough. |

---

## Installation

> [!NOTE]
> **AUR Status & Interim Installation:**
> New maintainer account registrations on the Arch User Repository (`aur.archlinux.org`) are temporarily suspended by Arch Linux infrastructure. Until account registrations re-open and `limine-vfio` is submitted to the AUR index, install using **Method 1 (Local `makepkg`)** or **Method 2 (Prebuilt Package)** below. Both methods natively register the package into your system's `pacman` database with full dependency management, pre-flight safety hooks, and clean uninstallation support (`pacman -R limine-vfio`).

### Method 1: Build & Install with `makepkg` (Recommended)
Clone the repository and build the package natively using Arch's standard package builder:
```bash
git clone https://github.com/weignerg/limine-vfio.git
cd limine-vfio
makepkg -si
```
*The `-s` flag automatically installs any missing dependencies (`pciutils`, `limine`, `limine-entry-tool`), and `-i` registers the package directly with `pacman`.*

### Method 2: Install from Prebuilt Package Archive
If you have built or downloaded a release package (`.pkg.tar.zst`):
```bash
sudo pacman -U limine-vfio-1.0.0-1-any.pkg.tar.zst
```
*(Or directly from a GitHub Release URL once published)*

### Method 3: Direct Script Setup (Standalone / Non-Pacman)
If you prefer running standalone without the package manager:
```bash
git clone https://github.com/weignerg/limine-vfio.git
cd limine-vfio
sudo ./limine-vfio install
```

### Method 4: Via AUR Helper (Pending AUR Re-Opening)
As soon as AUR maintainer signups resume and the package is pushed to the AUR:
```bash
# Using paru
paru -S limine-vfio

# Using yay
yay -S limine-vfio
```

---

## CLI Usage

Both `limine-vfio` and `cachyos-vfio` can be used interchangeably.

### 1. Pre-Flight Check
Verifies CPU virtualization, IOMMU status, initramfs modules, and Limine hook:
```bash
limine-vfio check
```

### 2. Discover Devices & IOMMU Groups
Lists all PCI devices, their classifications, PCI IDs, and IOMMU group isolation:
```bash
limine-vfio list-devices
```

### 3. Check Current Status
Displays active `vfio-pci` bindings, active kernel command line, and configured profiles:
```bash
limine-vfio status
```

### 4. Interactive Configuration Wizard
Guided wizard to discover devices, verify IOMMU group isolation, create profile drop-in, configure `/etc/default/limine`, and trigger `limine-update`:
```bash
sudo limine-vfio add
```

### 5. Remove a Passthrough Profile
Interactively removes a profile, cleans up `/etc/default/limine`, and refreshes boot entries:
```bash
sudo limine-vfio remove
```

---

## Configuration Architecture

### Drop-in Profiles: `/etc/vfio-passthrough.d/`
Each isolated device profile is stored as a `.conf` file. Example (`/etc/vfio-passthrough.d/1060.conf`):
```ini
PROFILE="1060"
DEVICE_TYPE="GPU"
DESCRIPTION="GPU Passthrough GTX 1060"
PCI_IDS="10de:1c03,10de:10f1"
ENABLED="yes"
```

### Global Configuration: `/etc/vfio-passthrough.conf`
Defines system-wide IOMMU settings. If unspecified, `limine-vfio` auto-detects CPU vendor (AMD-V vs Intel VT-d):
```ini
# Auto-detected if commented out
# IOMMU_PARAMS="amd_iommu=on iommu=pt"
```

### Dynamic Limine Post-Hook: `/etc/boot/hooks/post.d/95-vfio-entries`
Runs automatically during kernel installations and updates (`limine-update` / `pacman`):
- Reads all enabled profiles in `/etc/vfio-passthrough.d/`.
- Dynamically creates boot entries for all installed kernels (e.g. `linux-cachyos-lts-vfio-1060`).
- Compatible with `limine-mkinitcpio-hook` 1.37.1+ modern filenames (`initramfs` and `vmlinuz`) with legacy fallback support.

---

## Repository Files

- [`limine-vfio`](./limine-vfio): Main management CLI executable.
- [`cachyos-vfio`](./cachyos-vfio): Backward compatibility symlink.
- [`95-vfio-entries`](./95-vfio-entries): Dynamic Limine post-hook script.
- [`PKGBUILD`](./PKGBUILD): Arch Linux / AUR package build specification.
- [`.SRCINFO`](./.SRCINFO): Generated Arch package metadata.
- [`limine-vfio.install`](./limine-vfio.install): Pacman pre/post-install hooks and safety checks.
- [`vfio-passthrough.conf.example`](./vfio-passthrough.conf.example): Global configuration template.
- [`example-profile.conf`](./example-profile.conf): Template profile drop-in.
- [`LICENSE`](./LICENSE): MIT License.
- [`README.md`](./README.md): System documentation.
- [`GEMINI.md`](./GEMINI.md): Project architecture and memory.
- [`TODO.md`](./TODO.md): Session logs and task history.
