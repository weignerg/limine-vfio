# cachyos-vfio

Dynamic PCI Device Passthrough Manager and Limine Bootloader Hook for CachyOS / Arch Linux.

`cachyos-vfio` automates hardware discovery, automatic device classification, IOMMU isolation verification, dynamic Limine boot entry registration, and driver exclusion. It is fully device-agnostic and supports passing through **GPUs**, **Network Controllers (NICs)**, **USB Controllers**, **Storage Controllers (NVMe/SATA)**, **Audio Cards**, **Capture Cards**, and **Hardware Accelerators**.

---

## Hardware Classification & Reference

`cachyos-vfio` scans the PCI bus and automatically classifies devices into structured categories:

| Classification | Device Examples | Isolation & Pairing Logic |
| :--- | :--- | :--- |
| **`GPU`** | NVIDIA RTX 5090, GTX 1060, AMD Radeon, Intel Arc | Automatically pairs companion HDMI/DP audio and Type-C controllers; prompts for host driver exclusion if secondary NVIDIA. |
| **`NETWORK`** | 10GbE Aquantia, Intel NICs, Wi-Fi 7 adapters | Detects multi-port companion functions on the same PCIe card. |
| **`USB`** | Dedicated PCIe USB 3.x / Thunderbolt 4 controllers | Isolates external host controllers for guest hotplugging. |
| **`STORAGE`** | NVMe SSD controllers, dedicated SATA controllers | Isolates raw storage controllers for bare-metal guest I/O performance. |
| **`CAPTURE`** | Video capture cards (Elgato, Blackmagic, AverMedia) | Isolates streaming and capture hardware for dedicated guest ingestion. |
| **`ACCELERATOR`** | NPUs, TPUs, crypto accelerators, FPGAs | Dedicated compute and machine learning acceleration passthrough. |

---

## CLI Features & Subcommands

### 1. Pre-Flight Diagnostics (`cachyos-vfio check`)
Ensures your hardware and kernel environment are fully prepared for passthrough:
- CPU virtualization status (AMD-V / Intel VT-x).
- IOMMU kernel status and group count.
- Active boot command line verification.
- Initramfs module ordering (`vfio_pci vfio vfio_iommu_type1` in `/etc/mkinitcpio.conf`).
- Limine tools and post-hook presence.

```bash
cachyos-vfio check
```

### 2. Device & IOMMU Group Discovery (`cachyos-vfio list-devices`)
Displays a colorized table of all PCI devices, their IOMMU groups, classification badges, PCI IDs, and active drivers:

```bash
cachyos-vfio list-devices
```

### 3. Real-Time Status (`cachyos-vfio status`)
Inspects active `vfio-pci` driver bindings in the current boot session, configured profiles in `/etc/vfio-passthrough.d/`, and generated Limine command lines:

```bash
cachyos-vfio status
```

### 4. Interactive Configuration Wizard (`cachyos-vfio add`)
A guided step-by-step setup that:
1. Discovers and classifies all passthrough-eligible devices on your system.
2. Prompts you to select the target device.
3. Automatically scans for companion functions (e.g. GPU audio controllers or multi-port NICs).
4. Verifies IOMMU group isolation and warns if non-related devices share the group.
5. Generates a modular profile in `/etc/vfio-passthrough.d/<profile>.conf`.
6. Dynamically updates `/etc/default/limine` with `KERNEL_CMDLINE[<kernel>-vfio-<profile>]` for all installed kernels.
7. Only prompts for secondary GPU driver exclusion if the selected device is an NVIDIA GPU.
8. Rebuilds Limine boot entries via `limine-update`.

```bash
sudo cachyos-vfio add
```

### 5. Profile Removal (`cachyos-vfio remove`)
Interactively removes an existing profile, cleans up `/etc/default/limine` entries, and triggers `limine-update`:

```bash
sudo cachyos-vfio remove
```

### 6. System Installation (`cachyos-vfio install`)
Deploys the automation hook, initializes configuration directories, seeds example profiles, and creates `/usr/local/bin/cachyos-vfio`:

```bash
sudo ./cachyos-vfio install
```

---

## Configuration Architecture

### Modular Profiles: `/etc/vfio-passthrough.d/`
Each device has its own drop-in configuration file. For example:

**GPU Profile (`/etc/vfio-passthrough.d/1060.conf`):**
```ini
PROFILE="1060"
DEVICE_TYPE="GPU"
DESCRIPTION="GPU Passthrough GTX 1060"
PCI_IDS="10de:1c03,10de:10f1"
ENABLED="yes"
```

**Network Profile (`/etc/vfio-passthrough.d/10g-nic.conf`):**
```ini
PROFILE="10g-nic"
DEVICE_TYPE="NETWORK"
DESCRIPTION="Network Passthrough 10GbE"
PCI_IDS="1d6a:14c0"
ENABLED="yes"
```

### Global Configuration: `/etc/vfio-passthrough.conf`
```ini
# Global IOMMU options
IOMMU_PARAMS="amd_iommu=on iommu=pt"
```

### Dynamic Limine Post-Hook: `/etc/boot/hooks/post.d/95-vfio-entries`
Runs automatically during kernel installations and updates (`limine-update` / `pacman`):
- Reads all enabled profiles in `/etc/vfio-passthrough.d/`.
- Dynamically creates boot entries for all installed kernels.
- Compatible with `limine-mkinitcpio-hook` 1.37.1+ modern filenames (`initramfs` and `vmlinuz`) with legacy fallback support.

---

## Repository Files

- [`cachyos-vfio`](./cachyos-vfio): Main management CLI executable.
- [`95-vfio-entries`](./95-vfio-entries): Dynamic Limine post-hook script.
- [`profiles.d/`](./profiles.d/): Example profile drop-ins (`1060.conf.example`, `5090.conf.example`, `nic.conf.example`, `usb.conf.example`).
- [`vfio-passthrough.conf.example`](./vfio-passthrough.conf.example): Example global configuration.
- [`README.md`](./README.md): System documentation and user manual.
- [`GEMINI.md`](./GEMINI.md): Project architecture and memory.
- [`TODO.md`](./TODO.md): Session logs and task history.
