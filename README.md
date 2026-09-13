# limine-vfio

Dynamic PCI Device Passthrough Manager and Bootloader Hook for **Limine** on Arch Linux & CachyOS.

`limine-vfio` is an automated, device-agnostic utility to manage PCI passthrough and hardware isolation. It automates hardware discovery, device classification, IOMMU isolation validation, dynamic Limine boot entry generation, and driver exclusion.

It supports passing through **GPUs**, **Network Adapters (NICs)**, **USB Controllers**, **Storage Controllers (NVMe/SATA)**, **Audio Cards**, **Capture Cards**, and **Hardware Accelerators**.

---

## Key Features & Safeguards

- **Universal Device Classification:** Scans the PCI bus and classifies devices (`GPU`, `NETWORK`, `USB`, `STORAGE`, `CAPTURE`, `ACCELERATOR`, `AUDIO`, `SYSTEM`).
- **Pre-Flight Environment Safeguards:**
  - **UEFI Mode Check:** Verifies the system is booted in UEFI mode (`/sys/firmware/efi`).
  - **Limine Bootloader Validation:** Verifies Limine bootloader configuration and entry tools are present.
  - **CPU Virtualization Validation:** Detects AMD-V (`svm`) or Intel VT-x (`vmx`) extensions.
  - **IOMMU Group Isolation Guard:** Checks for sibling devices sharing the same IOMMU group and warns if isolation could cause host instability.
- **Dynamic Bootloader Entries:** Seamless post-hook (`95-vfio-entries`) integrates with `limine-entry-tool` and `limine-update` to generate kernel-specific passthrough boot options without modifying standard host boot entries.
- **Bootloader Conflict Resolution Engine:** Includes `limine-vfio doctor` and built-in diagnostic guards in `limine-vfio check` to identify orphan boot parameters, missing kernel entries, or accidental host primary GPU isolation before rebooting.
- **Libvirt XML Generation:** Generates valid `<hostdev>` blocks for VM domain XML (`virt-manager` / `virsh edit`).
- **Shell Completions & Man Page:** Full tab autocompletion for Bash, Zsh, and Fish, plus comprehensive manual page (`man limine-vfio`).
- **Arch / AUR Packaging:** Complete package build specification (`PKGBUILD`), install hooks (`limine-vfio.install`), and package metadata (`.SRCINFO`).

---

## Hardware Classification Reference

| Classification | Typical Devices | Companion & Isolation Logic |
| :--- | :--- | :--- |
| **`GPU`** | NVIDIA RTX / GTX, AMD Radeon, Intel Arc | Automatically pairs companion HDMI/DP audio controllers; prompts for host driver exclusion only if secondary NVIDIA GPU. |
| **`NETWORK`** | 10GbE / 2.5GbE NICs, Wi-Fi 7 adapters | Groups multi-port companion interfaces on the same PCIe card. |
| **`USB`** | Dedicated PCIe USB 3.x / Thunderbolt controllers | Isolates external host controllers for guest hotplugging. |
| **`STORAGE`** | NVMe SSD controllers, dedicated SATA controllers | Isolates raw storage controllers for bare-metal guest I/O performance. |
| **`CAPTURE`** | Video capture cards (Elgato, Blackmagic, AverMedia) | Isolates streaming and capture hardware for dedicated guest ingestion. |
| **`ACCELERATOR`** | NPUs, TPUs, crypto accelerators, FPGAs | Dedicated compute and machine learning acceleration passthrough. |

---

## Real-World Passthrough Examples

`limine-vfio` includes real-world profile templates based on tested workstation configurations:

### 1. Reversible Dual-GPU Multi-Boot Passthrough (Host Display & Dedicated VM Options)
In an advanced dual-GPU workstation (such as an **RTX 5090** primary and a **GTX 1060** secondary driving multiple physical monitors):
- **Boot Choice 1 — Standard Host Desktop (Dual-GPU Host):**
  - No `vfio-pci` parameters applied.
  - Primary GPU (RTX 5090) runs the proprietary `nvidia` driver for host desktop and CUDA compute.
  - Secondary GPU (GTX 1060) runs open-source `nouveau` driving auxiliary host monitors.
  - All displays are active simultaneously across both GPUs in KDE Plasma / Wayland.
- **Boot Choice 2 — Secondary GPU Passthrough (`win11-1060` VM):**
  - Kernel command line boots with `vfio-pci.ids=10de:1c03,10de:10f1`.
  - GTX 1060 + audio are isolated into `vfio-pci` at early boot with zero host driver contention.
  - Primary RTX 5090 remains fully attached to the host for desktop display and compute.
  - The guest VM (e.g. `win11-1060`) claims the card immediately without driver conflicts.
- **Boot Choice 3 — Primary GPU Passthrough (`win11-5090` VM):**
  - Kernel command line boots with `vfio-pci.ids=10de:2b85,10de:22e8`.
  - RTX 5090 + audio are isolated into `vfio-pci` for high-performance guest workloads (e.g. Windows gaming or AI/ML).
  - Secondary GTX 1060 automatically provides host desktop display via `nouveau` on its connected monitors.
  - The guest VM (e.g. `win11-5090`) claims the RTX 5090 with bare-metal speed.

> [!TIP]
> **Zero VM Reconfiguration Required:**
> If you already have existing virtual machines configured in Virtual Machine Manager (`virt-manager`) or `virsh` (e.g. `win11-1060` or `win11-5090`), **no VM modifications are needed**. Libvirt `<hostdev>` blocks target the fixed physical PCI addresses (`0000:82:00.0` or `0000:81:00.0`), which do not change. `limine-vfio` handles the host-side early binding so the device is already pre-isolated and waiting for the VM when the system boots.

#### Profile Configurations:
```ini
# /etc/vfio-passthrough.d/1060.conf
PROFILE="1060"
DEVICE_TYPE="GPU"
DESCRIPTION="GPU Passthrough GTX 1060"
PCI_IDS="10de:1c03,10de:10f1"
ENABLED="yes"
```

```ini
# /etc/vfio-passthrough.d/5090.conf
PROFILE="5090"
DEVICE_TYPE="GPU"
DESCRIPTION="GPU Passthrough RTX 5090"
PCI_IDS="10de:2b85,10de:22e8"
ENABLED="yes"
```

### 2. High-Speed Network Card Passthrough (10GbE NIC)
Isolates a dedicated PCIe Ethernet or Wi-Fi controller for high-throughput VM routing (e.g. pfSense, OPNsense, or high-bandwidth lab VMs):

```ini
# /etc/vfio-passthrough.d/10g-nic.conf
PROFILE="10g-nic"
DEVICE_TYPE="NETWORK"
DESCRIPTION="Network Passthrough 10GbE"
PCI_IDS="1d6a:14c0"
ENABLED="yes"
```

### 3. Dedicated PCIe USB Controller Passthrough
Directly passes through a discrete PCIe USB controller into a guest VM, enabling latency-free physical hotplugging of VR headsets, flash drives, and external audio gear:

```ini
# /etc/vfio-passthrough.d/usb-controller.conf
PROFILE="usb-ctrl"
DEVICE_TYPE="USB"
DESCRIPTION="USB Controller Passthrough"
PCI_IDS="8086:1138"
ENABLED="yes"
```

### 4. Direct NVMe Storage Controller Passthrough
Passes through an entire PCIe NVMe solid-state controller directly to the guest VM, achieving native bare-metal read and write performance without hypervisor storage virtualization overhead:

```ini
# /etc/vfio-passthrough.d/nvme-drive.conf
PROFILE="nvme-drive"
DEVICE_TYPE="STORAGE"
DESCRIPTION="NVMe Storage Controller Passthrough"
PCI_IDS="144d:a808"
ENABLED="yes"
```

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

### 6. Generate Libvirt XML (<hostdev>) Snippets
Automatically generates formatted libvirt XML blocks for any configured profile or PCI address, ready to paste directly into `virt-manager` (XML tab) or `virsh edit <vm>`:
```bash
# Generate XML from a configured profile
limine-vfio generate-xml 1060

# Or generate XML directly for any PCI address
limine-vfio generate-xml 82:00.0
```

### 7. Configuration Conflict Detection & Auto-Repair ("Doctor")
Scans `/etc/default/limine` and active profiles for potential bootloader conflicts:
- Detects if an enabled profile mistakenly isolates the **primary display GPU** (`boot_vga == 1`), preventing host desktop lockout.
- Detects orphan `KERNEL_CMDLINE[*-vfio-*]` parameters for deleted or renamed profiles.
- Detects missing command line entries for newly enabled profiles across all installed kernels.
- Detects dangerous `vfio-pci.ids` parameters in `KERNEL_CMDLINE[default]` that would isolate hardware on standard host boots.
- Interactively assists with automatic conflict resolution, profile disabling, parameter cleanup, and boot menu rebuilding.
```bash
# Run conflict diagnostics and guided resolution
sudo limine-vfio doctor
```

---

## Configuration Architecture

### Drop-in Profiles: `/etc/vfio-passthrough.d/`
Each isolated device profile is stored as a `.conf` file in `/etc/vfio-passthrough.d/`.

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
- [`95-vfio-entries`](./95-vfio-entries): Dynamic Limine post-hook script.
- [`PKGBUILD`](./PKGBUILD): Arch Linux / AUR package build specification.
- [`.SRCINFO`](./.SRCINFO): Generated Arch package metadata.
- [`limine-vfio.install`](./limine-vfio.install): Pacman pre/post-install hooks and safety checks.
- [`vfio-passthrough.conf.example`](./vfio-passthrough.conf.example): Global configuration template.
- [`example-profile.conf`](./example-profile.conf): Generic template profile drop-in.
- [`profiles.d/`](./profiles.d/): Real-world profile examples (`1060`, `5090`, `nic`, `usb`, `nvme`).
- [`LICENSE`](./LICENSE): MIT License.
- [`README.md`](./README.md): Complete system documentation and guides.
- [`GEMINI.md`](./GEMINI.md): Project architecture and memory.
- [`HISTORY.md`](./HISTORY.md): Project history and development milestones.
- [`TODO.md`](./TODO.md): Project roadmap and remaining tasks.
