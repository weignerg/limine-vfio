# limine-vfio: Remaining Tasks & Roadmap

## 1. System Integration & Verification (Local Host)
- [x] **Install via native `pacman`:** Installed `limine-vfio` via `pacman -U` with full system package tracking (`pacman -Q limine-vfio`).
- [ ] **End-to-End VM Passthrough Test:** Boot existing KVM/QEMU virtual machines (`win11-1060` or `win11-5090`) attaching either card to confirm zero host-driver contention and clean guest initialization.
- [x] **Multi-Kernel Boot Verification:** Verified boot entries appear and synchronize properly across all installed kernels (`linux-cachyos-lts` and `linux-cachyos`).

## 2. AUR & Upstream Distribution
- [ ] **Monitor AUR Registrations:** Check [aur.archlinux.org](https://aur.archlinux.org/) for the reopening of new maintainer account registrations.
- [ ] **Register AUR Maintainer Account:** Upload public SSH key (`~/.ssh/id_ed25519.pub`) upon registration opening.
- [ ] **Publish Package to AUR:**
  ```bash
  git clone ssh://aur@aur.archlinux.org/limine-vfio.git /tmp/limine-vfio-aur
  cp PKGBUILD .SRCINFO limine-vfio.install limine-vfio 95-vfio-entries vfio-passthrough.conf.example example-profile.conf limine-vfio.bash limine-vfio.zsh limine-vfio.fish limine-vfio.1 LICENSE /tmp/limine-vfio-aur/
  cd /tmp/limine-vfio-aur && git add . && git commit -m "Initial release of limine-vfio 1.0.0" && git push origin master
  ```
- [ ] **Verify AUR Helper Installation:** Confirm installation via `paru -S limine-vfio` and `yay -S limine-vfio`.

## 3. GitHub & Release Infrastructure
- [ ] **GitHub Release Tagging:** Tag `v1.0.0` and publish prebuilt `.pkg.tar.zst` artifact on GitHub Releases for direct URL installs (`pacman -U https://...`).
- [x] **CI/CD Build Automation:** Add a GitHub Actions workflow (`.github/workflows/ci.yml`) to automatically validate `PKGBUILD`, verify sha256 checksums, and check `.SRCINFO` formatting on every commit.
- [ ] **Repository Visibility:** Evaluate making the GitHub repository public when ready for broader community adoption.

## 4. Completed Feature Enhancements
- [x] **Boot Configuration Conflict Resolution Engine (`doctor`):** Built automated diagnostics and resolution in `limine-vfio doctor` and `limine-vfio check` for orphan parameters, missing kernel entries, and primary GPU lockout.
- [x] **Libvirt XML Generation:** Implemented `limine-vfio generate-xml <profile>` subcommand to automatically output formatted `<hostdev>` XML blocks ready to paste into `virt-manager` or `virsh edit`.
- [x] **Shell Autocompletion:** Authored autocompletion scripts for Bash, Zsh, and Fish shells (`limine-vfio.bash`, `limine-vfio.zsh`, `limine-vfio.fish`), installed to system package directories and host Fish environment.
- [x] **Manual Page:** Authored standard Unix manual page (`man/limine-vfio.1`) and added installation to `/usr/share/man/man1/` in PKGBUILD.

## 5. Future Feature Enhancements (Backlog)
- [ ] **Interactive ACS Override Advisor:** Add interactive check and advisory notice in `limine-vfio check` and `limine-vfio add` if devices share IOMMU groups without hardware ACS isolation.
- [ ] **QEMU Command-Line Generator:** Add flag (`limine-vfio generate-xml --qemu`) to output direct `-device vfio-pci,host=...` syntax for raw QEMU scripts.
