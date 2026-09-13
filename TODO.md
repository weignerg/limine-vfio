# GPU Passthrough Recovery & Automation Tool Task List

## Session 1: Post-Update Passthrough Failure Investigation & Fix
- [x] **Task 1: System & Boot Investigation** (6.18.50-lts booted without VFIO IDs; GTX 1060 claimed by nouveau)
- [x] **Task 2: Root Cause Analysis** (limine-mkinitcpio-hook 1.37.1 changed filenames to `initramfs` and `vmlinuz`)
- [x] **Task 3: Apply Fixes** (Created updated hook script with modern + fallback detection; ran `limine-update`)
- [x] **Task 4: Verification & Documentation** (Verified `/etc` hook; updated `GEMINI.md`)
- [x] **Task 5: Git Repository & GitHub Remote Setup** (Initialized repo, committed, created and pushed to `weignerg/cachyos-dual-gpu-vfio`)

## Session 2: Generalizing into an Interactive CLI Tool (`cachyos-vfio`)
- [x] **Task 6: Configuration Specification & Generic Hook**
  - [x] Designed modular `/etc/vfio-passthrough.d/` architecture and global `/etc/vfio-passthrough.conf`
  - [x] Created `profiles.d/1060.conf.example` and `profiles.d/5090.conf.example`
  - [x] Refactored `95-vfio-entries` to dynamically parse profiles from `/etc/vfio-passthrough.d/`
- [x] **Task 7: Build `cachyos-vfio` Management CLI**
  - [x] Implemented `check` (CPU virtualization, IOMMU state, Limine, mkinitcpio)
  - [x] Implemented `list-devices` (PCI scanning, IOMMU group mapping, audio pairing detection)
  - [x] Implemented `status` (active driver bindings, configured profiles, bootloader entries)
  - [x] Implemented `add` (interactive wizard with IOMMU group validation, profile generation, Limine config)
  - [x] Implemented `remove` (profile deletion and cleanup)
  - [x] Implemented `install` (automating deployment, directory setup, profile seeding, and `/usr/local/bin` symlink)
- [x] **Task 8: Verification & Deployment**
  - [x] Tested `cachyos-vfio check`, `list-devices`, and `status`
  - [x] Deployed dynamic hook and seeded `/etc/vfio-passthrough.d/` via `cachyos-vfio install`
  - [x] Verified `/usr/local/bin/cachyos-vfio` command is directly accessible in system PATH
  - [x] Updated documentation in `README.md` and `GEMINI.md`
  - [x] Committed and pushed changes to GitHub
