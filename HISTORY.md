# Project History & Changelog: limine-vfio

## Development Milestones

### Session 1: Post-Update Passthrough Failure Investigation & Fix
- **System & Boot Investigation:** Diagnosed passthrough failure following a kernel upgrade where the secondary GPU (GTX 1060) was claimed by `nouveau` and `vfio-pci.ids` boot entries were absent.
- **Root Cause Analysis:** Traced root cause to `limine-mkinitcpio-hook` 1.37.1 updating non-UKI kernel/initramfs file naming schemes to `vmlinuz` and `initramfs`, breaking legacy hook pattern matching.
- **Hook Restoration:** Implemented an updated post-hook supporting modern Limine paths with backwards-compatible fallback detection; regenerated boot entries via `limine-update`.
- **Repository Setup:** Initialized private Git repository and configured GitHub remote (`weignerg/limine-vfio`).

### Session 2: Modular Architecture & CLI Utility
- **Modular Drop-in Profiles:** Designed `/etc/vfio-passthrough.d/` architecture where each passthrough device is configured in an independent `.conf` drop-in.
- **Limine Post-Hook Automation:** Created `/etc/boot/hooks/post.d/95-vfio-entries` to dynamically parse drop-ins and register kernel-specific VFIO entries on every kernel update.
- **CLI Development:** Implemented core management subcommands (`check`, `list-devices`, `status`, `add`, `remove`, `install`).
- **Deployment:** Deployed hook and verified CLI commands in active workstation environment.

### Session 3: Universal Device Classification & Generalization
- **Universal Device Classification:** Generalized the tool beyond GPUs to support all PCI hardware types (`GPU`, `NETWORK`, `USB`, `STORAGE`, `AUDIO`, `CAPTURE`, `ACCELERATOR`, `SYSTEM`).
- **IOMMU Isolation Verification:** Built automatic IOMMU grouping checks that detect companion devices (e.g. GPU audio) and warn against un-isolated hardware sharing groups with host devices.
- **Targeted Driver Exclusions:** Scoped NVIDIA host driver exclusion prompts (`NVreg_ExcludedGpus`) strictly to secondary NVIDIA GPUs.
- **Profile Reference Library:** Added concrete reference templates for GPUs, 10GbE network interfaces, USB controllers, and NVMe drives.

### Session 4: Arch / AUR Packaging & Safeguards
- **Packaging Specifications:** Built compliant [`PKGBUILD`](file:///home/weignerg/nvidia-gpus/PKGBUILD) with explicit dependencies (`limine`, `limine-entry-tool`, `pciutils`, `bash`, `coreutils`) and optional virtualization packages.
- **Pre-Flight Safety Script (`limine-vfio.install`):** Added pre-install verification for UEFI boot environment, active Limine installation, and CPU virtualization extensions (AMD-V / Intel VT-x) to prevent system misconfiguration.
- **Checksums & Metadata:** Validated build process with `updpkgsums`, tested clean packaging via `makepkg -cf --nodeps`, and generated `.SRCINFO`.
- **Interim Installation Documentation:** Documented native `makepkg -si` installation guidance in `README.md` while AUR maintainer registrations are temporarily suspended.

### Session 5: Documentation & Nomenclature Polish
- **Legacy Cleanup:** Scrubbed all historical project names and legacy aliases across codebase, packaging, and documentation.
- **Real-World Case Studies:** Documented tested hardware profiles in `README.md` (Dual-GPU RTX 5090 / GTX 1060, 10GbE NIC, PCIe USB, NVMe).
- **Separation of History & Backlog:** Moved historical development logs from `TODO.md` into `HISTORY.md` and restructured `TODO.md` as an actionable forward-looking roadmap.

### Session 6: Advanced Tooling, Shell Integrations & Automation
- **Libvirt XML Generation (`generate-xml`):** Implemented subcommand to dynamically generate `<hostdev>` PCI XML blocks directly from configured profiles or PCI addresses for virt-manager and virsh.
- **Shell Autocompletion:** Authored tab completion suites for Fish (`limine-vfio.fish`), Bash (`limine-vfio.bash`), and Zsh (`limine-vfio.zsh`), supporting dynamic profile name completion. Installed Fish completion to host environment.
- **Manual Page:** Authored standard Unix manual page (`man/limine-vfio.1`) detailing syntax, commands, configuration files, and examples.
- **CI/CD Pipeline:** Added GitHub Actions workflow (`.github/workflows/ci.yml`) for containerized Arch Linux package builds and `.SRCINFO` consistency verification.
### Session 7: Edge-Case Hardening, Sibling Discovery & Sanitization
- **Removed Hardcoded Fallbacks:** Stripped legacy hardcoded GTX 1060 / RTX 5090 fallback bindings from `95-vfio-entries` so clean third-party systems without configured profiles exit cleanly rather than registering foreign hardware.
- **IOMMU Sibling Auto-Discovery in XML:** Enhanced `limine-vfio generate-xml` to inspect sysfs IOMMU groups when given raw PCI addresses, automatically pulling in companion functions (e.g. GPU audio) to prevent KVM "group is not viable" VM boot errors.
- **Kernel Cmdline Sanitization:** Updated `cmd_add` to prioritize `/etc/kernel/cmdline` if present and rigorously de-duplicate existing IOMMU parameters (`amd_iommu=on`, `iommu=pt`) prior to generating Limine boot entries.
- **Direct Argument Removal:** Updated `cmd_remove` to accept profile name arguments directly (`limine-vfio remove <profile>`).


