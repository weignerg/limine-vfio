# Project: limine-vfio

## Overview
`limine-vfio` is an automated, device-agnostic VFIO passthrough and hardware isolation management utility designed for Arch Linux and CachyOS systems using the **Limine** bootloader. It supports GPUs, Network adapters, USB controllers, Storage devices, Audio controllers, and Hardware Accelerators.

The project includes the **`limine-vfio`** CLI utility, a dynamic post-hook script for `limine-entry-tool`, and Arch / AUR packaging files (`PKGBUILD`, `limine-vfio.install`, `.SRCINFO`).

## Hardware Configuration (Workstation Setup)
- **Reversible Dual-GPU Multi-Boot Passthrough:**
  - **Option 1 (Standard Boot):** Dual-GPU host desktop. RTX 5090 runs on `nvidia` (primary display & CUDA); GTX 1060 runs on `nouveau` (auxiliary displays).
  - **Option 2 (`vfio-1060` Boot):** GTX 1060 (`0000:82:00.0` + audio `82:00.1`) isolated for guest VM (e.g. `win11-1060`); RTX 5090 drives host desktop and CUDA compute.
  - **Option 3 (`vfio-5090` Boot):** RTX 5090 (`0000:81:00.0` + audio `81:00.1`) isolated for guest VM (e.g. `win11-5090`); GTX 1060 drives host desktop via `nouveau`.
- **Driver Rules:**
  - GTX 1060 excluded from proprietary driver via `/etc/modprobe.d/nvidia-utils.conf` (`NVreg_ExcludedGpus=0000:82:00.0`).
  - Nouveau enabled via `/etc/modprobe.d/nouveau.conf`.

## Architecture & Configuration Files
- **CLI Utility:** `/usr/bin/limine-vfio` (or `/usr/local/bin/limine-vfio`).
- **Profiles Directory:** `/etc/vfio-passthrough.d/` (drop-in `.conf` files for each passthrough device).
- **Global Config:** `/etc/vfio-passthrough.conf`.
- **Limine Post-Hook:** `/etc/boot/hooks/post.d/95-vfio-entries` (scans `/etc/vfio-passthrough.d/` and registers boot entries for all kernels).
- **Limine Settings:** `/etc/default/limine` (stores `KERNEL_CMDLINE` definitions).
- **Initramfs:** `/etc/mkinitcpio.conf` (`MODULES=(vfio_pci vfio vfio_iommu_type1)`).
- **Packaging:** `PKGBUILD`, `limine-vfio.install`, `.SRCINFO`, `LICENSE`.
- **Documentation:** `README.md`, `HISTORY.md` (milestones & changelog), `TODO.md` (actionable roadmap).

## CLI Commands
- `limine-vfio check`: Pre-flight diagnostics (CPU virtualization, IOMMU, Limine, modules).
- `limine-vfio list-devices`: Scans PCI devices, classifies device types, maps IOMMU groups, checks group isolation.
- `limine-vfio status`: Displays active driver bindings, cmdline, and configured profiles.
- `limine-vfio add`: Interactive wizard to select device, verify IOMMU group, configure profile & Limine.
- `limine-vfio remove`: Removes a profile and cleans up Limine entries.
- `limine-vfio generate-xml`: Outputs libvirt hostdev XML for virt-manager/virsh.
- `limine-vfio doctor`: Detects and interactively resolves boot menu & configuration conflicts.
- `limine-vfio install`: Deploys hook, initializes directories, and symlinks binary.
