# GPU Passthrough Recovery Task List

## Session: Post-Update Passthrough Failure Investigation & Fix

- [x] **Task 1: System & Boot Investigation**
  - [x] Check current booted kernel and kernel commandline (`6.18.50-1-cachyos-lts`, standard cmdline without `vfio-pci.ids`)
  - [x] Check GPU PCI IDs, current driver bindings (`GTX 1060` claimed by `nouveau` and `snd_hda_intel`, `RTX 5090` by `nvidia`)
  - [x] Inspect pacman log for recent updates (`limine-mkinitcpio-hook` updated `1.36.0-1` -> `1.37.1-1`, kernels updated to `6.18.50-lts` & `7.2.5`)
  - [x] Inspect `/boot/limine.conf`, `/etc/default/limine`, and `/etc/boot/hooks/post.d/95-vfio-entries`
  - [x] Check `/etc/mkinitcpio.conf` and `/etc/modprobe.d/` configs (all intact)
- [x] **Task 2: Root Cause Analysis**
  - [x] Identified root cause: `limine-mkinitcpio-hook` v1.37.1 simplified non-UKI initramfs and vmlinuz filenames from `initramfs-${kernel}` / `vmlinuz-${kernel}` to `initramfs` and `vmlinuz`.
  - [x] Post-hook `/etc/boot/hooks/post.d/95-vfio-entries` was checking `[[ -f "$initramfs_path" && -f "$vmlinuz_path" ]]` with the old filename pattern, causing it to silently skip all kernels and omit the VFIO boot entries during `limine-update`.
- [x] **Task 3: Apply Fixes**
  - [x] Created updated hook script [95-vfio-entries](file:///home/weignerg/nvidia-gpus/95-vfio-entries) supporting both new and legacy naming conventions.
  - [x] Deployed updated hook to `/etc/boot/hooks/post.d/95-vfio-entries`.
  - [x] Successfully ran `limine-update` to rebuild initramfs and regenerate Limine entries.
- [x] **Task 4: Verification & Documentation**
  - [x] Verified `/etc/boot/hooks/post.d/95-vfio-entries` deployed and verified hook execution completed without error.
  - [x] Updated [GEMINI.md](file:///home/weignerg/nvidia-gpus/GEMINI.md) with the new hook script definition and changelog details.
