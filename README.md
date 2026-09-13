# cachyos-dual-gpu-vfio

Dynamic VFIO Passthrough Manager and Limine Bootloader Hook for CachyOS / Arch Linux.

This project automates hardware discovery, IOMMU isolation validation, dynamic boot entry generation, and driver exclusion for multi-GPU setups running the **Limine** bootloader.

---

## Hardware Reference (Workstation Setup)

| Component | GPU 1 (Primary / Host) | GPU 2 (Secondary / Guest) |
| :--- | :--- | :--- |
| **Model** | NVIDIA GeForce RTX 5090 (GB202) | NVIDIA GeForce GTX 1060 6GB (GP106) |
| **PCI Bus ID** | `0000:81:00.0` (VGA), `0000:81:00.1` (Audio) | `0000:82:00.0` (VGA), `0000:82:00.1` (Audio) |
| **PCI Vendor/Device IDs**| `10de:2b85` (VGA), `10de:22e8` (Audio) | `10de:1c03` (VGA), `10de:10f1` (Audio) |
| **Host Driver** | Proprietary `nvidia` (open-kernel module) | Open-source `nouveau` |
| **Primary Role** | KDE Plasma Wayland, CUDA (ComfyUI, Ollama, Steam) | Secondary display / VM passthrough via `vfio-pci` |

---

## Features

- **`cachyos-vfio` CLI Utility:**
  - `check`: Runs pre-flight diagnostics (CPU virtualization VT-x/AMD-V, active IOMMU groups, Limine tools, `mkinitcpio.conf` module ordering).
  - `list-devices`: Scans all PCI devices, maps their IOMMU groups, highlights GPUs and companion audio devices, and checks group isolation.
  - `status`: Displays current booted kernel, active driver bindings, configured passthrough profiles, and Limine commandlines.
  - `add`: Interactive wizard to select a GPU/device, verify IOMMU group isolation, generate profile configs, configure `/etc/default/limine`, handle NVIDIA driver exclusion, and trigger `limine-update`.
  - `remove`: Interactive wizard to remove existing profiles and clean up Limine entries.
  - `install`: Deploys the dynamic hook, creates `/etc/vfio-passthrough.d/`, seeds initial profiles, and installs `/usr/local/bin/cachyos-vfio`.
- **Dynamic Limine Post-Hook (`95-vfio-entries`):**
  - Runs automatically on kernel updates via `/etc/boot/hooks/post.d/95-vfio-entries`.
  - Parses profiles from `/etc/vfio-passthrough.d/*.conf`.
  - Supports modern (`limine-mkinitcpio-hook >= 1.37.1`) filename conventions (`initramfs` and `vmlinuz`) with automatic fallback to legacy suffixed names.
  - Automatically registers boot entries for every installed kernel.

---

## Quick Start & CLI Usage

### 1. Installation
Deploy the post-hook and link the CLI to your PATH:
```bash
sudo ./cachyos-vfio install
```

### 2. Pre-Flight Diagnostics
Ensure CPU virtualization and IOMMU are active:
```bash
cachyos-vfio check
```

### 3. List Devices and IOMMU Groups
Inspect all PCI devices and their IOMMU groupings:
```bash
cachyos-vfio list-devices
```

### 4. Current Status
Check active GPU driver bindings and configured profiles:
```bash
cachyos-vfio status
```

### 5. Adding a Device / GPU for Passthrough
Run the interactive wizard:
```bash
sudo cachyos-vfio add
```
The wizard will:
1. Scan and display all detected GPUs.
2. Verify IOMMU group isolation and detect companion audio devices on the same slot.
3. Prompt for profile name and description.
4. Create `/etc/vfio-passthrough.d/<profile>.conf`.
5. Update `/etc/default/limine` with `KERNEL_CMDLINE[<kernel>-vfio-<profile>]` for all installed kernels.
6. Check if secondary NVIDIA exclusion is needed in `/etc/modprobe.d/nvidia-utils.conf`.
7. Rebuild the Limine bootloader configuration via `limine-update`.

---

## Configuration Architecture

### 1. Central Profile Directory: `/etc/vfio-passthrough.d/`
Each device or GPU has its own modular `.conf` file. For example, `/etc/vfio-passthrough.d/1060.conf`:
```ini
PROFILE="1060"
DESCRIPTION="GPU Passthrough GTX 1060"
PCI_IDS="10de:1c03,10de:10f1"
ENABLED="yes"
```

### 2. Global Configuration: `/etc/vfio-passthrough.conf`
```ini
# Global settings
IOMMU_PARAMS="amd_iommu=on iommu=pt"
```

### 3. Early Kernel Module Loading: `/etc/mkinitcpio.conf`
```bash
MODULES=(vfio_pci vfio vfio_iommu_type1)
```

### 4. Limine Automation Post-Hook: `/etc/boot/hooks/post.d/95-vfio-entries`
When kernels are updated, this script iterates through enabled profiles and registers boot options with `limine-entry-tool`.

---

## Repository Files

- [`cachyos-vfio`](./cachyos-vfio): Main management CLI executable.
- [`95-vfio-entries`](./95-vfio-entries): Dynamic Limine post-hook script.
- [`profiles.d/`](./profiles.d/): Example profile drop-ins for GTX 1060 and RTX 5090.
- [`vfio-passthrough.conf.example`](./vfio-passthrough.conf.example): Example global configuration.
- [`README.md`](./README.md): Documentation and quick start guide.
- [`GEMINI.md`](./GEMINI.md): Project architecture and memory.
- [`TODO.md`](./TODO.md): Session logs and task history.
