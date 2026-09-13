# Project: nvidia-gpus (cachyos-dual-gpu-vfio)

## Overview
This project manages, monitors, and automates dual-GPU configuration and VFIO passthrough on CachyOS (Arch Linux) using the Limine bootloader. The system runs an RTX 5090 (host) and a GTX 1060 (guest / secondary).

The project includes the **`cachyos-vfio`** CLI utility and a dynamic post-hook script for `limine-entry-tool`.

## Hardware Configuration
- **RTX 5090 (`0000:81:00.0`):** Host primary GPU via proprietary `nvidia` driver (open-kernel).
- **GTX 1060 (`0000:82:00.0`):** Secondary / passthrough GPU via `nouveau` (host) or `vfio-pci` (guest).
  - Excluded from proprietary driver via `/etc/modprobe.d/nvidia-utils.conf` (`NVreg_ExcludedGpus=0000:82:00.0`).
  - Nouveau enabled via `/etc/modprobe.d/nouveau.conf`.

## Architecture & Configuration Files
- **CLI Utility:** `/usr/local/bin/cachyos-vfio` (symlinked from `./cachyos-vfio`).
- **Profiles Directory:** `/etc/vfio-passthrough.d/` (drop-in `.conf` files for each passthrough device).
- **Global Config:** `/etc/vfio-passthrough.conf`.
- **Limine Post-Hook:** `/etc/boot/hooks/post.d/95-vfio-entries` (scans `/etc/vfio-passthrough.d/` and registers boot entries for all kernels).
- **Limine Settings:** `/etc/default/limine` (stores `KERNEL_CMDLINE` definitions).
- **Initramfs:** `/etc/mkinitcpio.conf` (`MODULES=(vfio_pci vfio vfio_iommu_type1)`).

## CLI Commands
- `cachyos-vfio check`: Pre-flight diagnostics (CPU virtualization, IOMMU, Limine, modules).
- `cachyos-vfio list-devices`: Scans PCI devices, maps IOMMU groups, checks group isolation.
- `cachyos-vfio status`: Displays active driver bindings, cmdline, and configured profiles.
- `cachyos-vfio add`: Interactive wizard to select device, verify IOMMU group, configure profile & Limine.
- `cachyos-vfio remove`: Removes a profile and cleans up Limine entries.
- `cachyos-vfio install`: Deploys hook, initializes directories, seeds profiles, and symlinks binary.
