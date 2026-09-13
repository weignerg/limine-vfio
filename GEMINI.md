# Project: nvidia-gpus

## Overview
This project is dedicated to managing, monitoring, and utilizing NVIDIA GPUs on this system. The system features a dual-GPU setup with an RTX 5090 and a GTX 1060.

## Hardware & Driver Configuration
The GPUs are configured with a hybrid driver setup to allow for different use cases (e.g., host graphics vs. guest passthrough or secondary compute).

### 1. NVIDIA GeForce RTX 5090 (Primary)
- **Bus ID:** `0000:81:00.0`
- **Driver:** Proprietary `nvidia` (Version 595.71.05)
- **Role:** Primary GPU for the host system, running KDE Plasma (Wayland) and CUDA-accelerated applications (e.g., ComfyUI, Steam).

### 2. NVIDIA GeForce GTX 1060 6GB (Secondary)
- **Bus ID:** `0000:82:00.0`
- **Driver:** Open-source `nouveau`
- **Configuration:**
  - Explicitly excluded from the proprietary `nvidia` driver via `/etc/modprobe.d/nvidia-utils.conf`:
    ```conf
    options nvidia NVreg_ExcludedGpus=0000:82:00.0
    ```
  - `nouveau` is permitted to load via `/etc/modprobe.d/nouveau.conf`.

## Boot & Kernel Configuration
- **Kernel Modules (Initramfs):** `vfio_pci`, `vfio`, and `vfio_iommu_type1` are loaded early via `/etc/mkinitcpio.conf`.
- **Automated VFIO Entries:** A post-hook script at `/etc/boot/hooks/post.d/95-vfio-entries` automatically generates passthrough-specific boot entries for all installed kernels.
- **Custom Boot Options:**
  - `linux-cachyos-vfio-1060`: Passes through the GTX 1060 (`10de:1c03,10de:10f1`).
  - `linux-cachyos-vfio-5090`: Passes through the RTX 5090 (`10de:2b85,10de:22e8`).
  - Corresponding `-lts` variants are also available.
- **Command Line Parameters:** These entries include `amd_iommu=on iommu=pt` and the respective `vfio-pci.ids`.
- **Environment:** CachyOS (Linux kernel 6.12.65-2-cachyos-lts).

## Key Files
- `/etc/default/limine`: Contains the custom `KERNEL_CMDLINE` definitions for VFIO entries.
- `/etc/boot/hooks/post.d/95-vfio-entries`: Automation script for `limine-entry-tool`.
- `/boot/limine.conf`: The generated bootloader configuration.
- `/etc/modprobe.d/nvidia-utils.conf`: GPU exclusion rules.
- `/etc/modprobe.d/nouveau.conf`: Nouveau driver settings.
- `/etc/mkinitcpio.conf`: Early-boot module loading.

## Replication Guide (Step-by-Step)
To replicate this automated dual-GPU VFIO setup on another CachyOS/Arch system using Limine:

### 1. Identify PCI IDs
Find the IDs for your target GPUs:
```bash
lspci -nn | grep -i "nvidia"
```
*(Example: 10de:1c03 for a 1060)*

### 2. Configure Command Lines
Add custom kernel parameters to `/etc/default/limine`. Use specific keys that match the kernel names plus your desired suffixes.
```bash
# Example for /etc/default/limine
KERNEL_CMDLINE[linux-cachyos-vfio-1060]=<base_params> amd_iommu=on iommu=pt vfio-pci.ids=10de:1c03,10de:10f1
```

### 3. Create the Automation Hook
Create `/etc/boot/hooks/post.d/95-vfio-entries` (chmod +x) to detect kernels and add entries:
```bash
#!/usr/bin/env bash
readonly LIMINE_FUNCTIONS_PATH=/usr/lib/limine/limine-common-functions
source "${LIMINE_FUNCTIONS_PATH}" || exit 1
initialize_header || exit 1

for kDir in "${ESP_PATH}/${MACHINE_ID}"/*; do
    [[ -d "$kDir" ]] || continue
    kName=$(basename "$kDir")
    [[ "$kName" == *-vfio-* || "$kName" == *-fallback* ]] && continue
    
    # In limine-mkinitcpio-hook >= 1.37.1, kernel name suffixes were removed
    initramfs_path="${kDir}/initramfs"
    vmlinuz_path="${kDir}/vmlinuz"
    
    # Fallback for older limine-mkinitcpio-hook (< 1.37.1)
    if [[ ! -f "$initramfs_path" || ! -f "$vmlinuz_path" ]]; then
        initramfs_path="${kDir}/initramfs-${kName}"
        vmlinuz_path="${kDir}/vmlinuz-${kName}"
    fi
    
    [[ -f "$initramfs_path" && -f "$vmlinuz_path" ]] || continue
    
    # Add entries via limine-entry-tool
    limine-entry-tool --add-kernel "${kName}" "${initramfs_path}" "${vmlinuz_path}" "-vfio-1060" --comment "GPU Passthrough 1060" --no-mutex --no-hooks --quiet
    limine-entry-tool --add-kernel "${kName}" "${initramfs_path}" "${vmlinuz_path}" "-vfio-5090" --comment "GPU Passthrough 5090" --no-mutex --no-hooks --quiet
done
```

### 4. Apply Changes
Trigger the update process:
```bash
sudo limine-update
```

## Usage & Development
- **Monitoring:** Use `nvidia-smi` for the RTX 5090. `nouveau` devices do not appear in `nvidia-smi`.
- **Future Goals:** Potential for GPU passthrough to VMs or isolating the GTX 1060 for specific workloads using `vfio-pci`.
