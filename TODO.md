# GPU & Device Passthrough Automation Tool Task List

## Session 1: Post-Update Passthrough Failure Investigation & Fix
- [x] **Task 1: System & Boot Investigation** (6.18.50-lts booted without VFIO IDs; GTX 1060 claimed by nouveau)
- [x] **Task 2: Root Cause Analysis** (limine-mkinitcpio-hook 1.37.1 changed filenames to `initramfs` and `vmlinuz`)
- [x] **Task 3: Apply Fixes** (Created updated hook script with modern + fallback detection; ran `limine-update`)
- [x] **Task 4: Verification & Documentation** (Verified `/etc` hook; updated `GEMINI.md`)
- [x] **Task 5: Git Repository & GitHub Remote Setup** (Initialized repo, committed, created and pushed to `weignerg/cachyos-dual-gpu-vfio`)

## Session 2: Generalizing into an Interactive CLI Tool (`cachyos-vfio`)
- [x] **Task 6: Configuration Specification & Generic Hook** (Created `/etc/vfio-passthrough.d/` architecture and dynamic hook)
- [x] **Task 7: Build `cachyos-vfio` Management CLI** (Implemented `check`, `list-devices`, `status`, `add`, `remove`, `install`)
- [x] **Task 8: Verification & Deployment** (Deployed hook, seeded profiles, tested `/usr/local/bin/cachyos-vfio`)

## Session 3: Universal Device Classification & Repo Generalization
- [x] **Task 9: GitHub Repository Renaming**
  - [x] Renamed GitHub repository from `weignerg/cachyos-dual-gpu-vfio` to `weignerg/cachyos-vfio`
  - [x] Updated local git remote tracking URL
- [x] **Task 10: Device Classification & Removing GPU-Specific Assumptions**
  - [x] Added automated PCI device classification (`GPU`, `NETWORK`, `USB`, `STORAGE`, `AUDIO`, `CAPTURE`, `ACCELERATOR`, `SYSTEM`)
  - [x] Updated `list-devices` to badge each device with its classification type
  - [x] Generalized `cmd_add` to detect all passthrough-eligible hardware
  - [x] Scoped NVIDIA driver exclusion prompts exclusively to NVIDIA GPU devices
  - [x] Updated `95-vfio-entries` to support `DEVICE_TYPE` in profiles
  - [x] Added `nic.conf.example` and `usb.conf.example`
- [x] **Task 11: Verification & Documentation**
  - [x] Updated `README.md` and `GEMINI.md`
  - [x] Verified `cachyos-vfio list-devices` and `cachyos-vfio status`
  - [x] Committed and pushed to GitHub
