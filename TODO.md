# limine-vfio: Remaining Tasks & Roadmap

## 1. System Integration & Verification (Local Host)
- [ ] **Install via native `pacman`:** Run `makepkg -si` locally to transition the system from loose file symlinks to full pacman database tracking (`pacman -Q limine-vfio`).
- [ ] **End-to-End VM Passthrough Test:** Boot a test KVM/QEMU virtual machine attaching the GTX 1060 (`82:00.0` and `82:00.1`) to confirm zero host-driver contention and clean guest initialization.
- [ ] **Multi-Kernel Boot Verification:** Verify boot entries appear and load properly across all installed kernels (e.g. `linux-cachyos-lts` and standard kernels).

## 2. AUR & Upstream Distribution
- [ ] **Monitor AUR Registrations:** Check [aur.archlinux.org](https://aur.archlinux.org/) for the reopening of new maintainer account registrations.
- [ ] **Register AUR Maintainer Account:** Upload public SSH key (`~/.ssh/id_ed25519.pub`) upon registration opening.
- [ ] **Publish Package to AUR:**
  ```bash
  git clone ssh://aur@aur.archlinux.org/limine-vfio.git /tmp/limine-vfio-aur
  cp PKGBUILD .SRCINFO limine-vfio.install limine-vfio 95-vfio-entries vfio-passthrough.conf.example example-profile.conf LICENSE /tmp/limine-vfio-aur/
  cd /tmp/limine-vfio-aur && git add . && git commit -m "Initial release of limine-vfio 1.0.0" && git push origin master
  ```
- [ ] **Verify AUR Helper Installation:** Confirm installation via `paru -S limine-vfio` and `yay -S limine-vfio`.

## 3. GitHub & Release Infrastructure
- [ ] **GitHub Release Tagging:** Tag `v1.0.0` and publish prebuilt `.pkg.tar.zst` artifact on GitHub Releases for direct URL installs (`pacman -U https://...`).
- [ ] **CI/CD Build Automation:** Add a GitHub Actions workflow (`.github/workflows/makepkg.yml`) to automatically validate `PKGBUILD`, verify sha256 checksums, and check `.SRCINFO` formatting on every commit.
- [ ] **Repository Visibility:** Evaluate making the GitHub repository public when ready for broader community adoption.

## 4. Feature Enhancements (Backlog)
- [ ] **Libvirt XML Generation:** Implement a `limine-vfio generate-xml <profile>` subcommand to automatically output formatted `<hostdev>` XML blocks ready to paste into `virt-manager` or `virsh edit`.
- [ ] **Shell Autocompletion:** Provide autocompletion scripts for Bash, Zsh, and Fish shells (`/usr/share/bash-completion/completions/limine-vfio`, `/usr/share/zsh/site-functions/_limine-vfio`, `/usr/share/fish/vendor_completions.d/limine-vfio.fish`).
- [ ] **Interactive ACS Override Warning:** Add check and advisory notice if a user attempts passthrough on devices in shared IOMMU groups on motherboards lacking native PCIe slot isolation.
- [ ] **Manual Page:** Generate a standard man page (`man/limine-vfio.1`) and install to `/usr/share/man/man1/`.
