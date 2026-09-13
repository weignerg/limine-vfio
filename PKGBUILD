# Maintainer: Gregory Allen Weigner <29870826+weignerg@users.noreply.github.com>
pkgname=limine-vfio
pkgver=1.0.0
pkgrel=1
pkgdesc="Dynamic, device-agnostic PCI passthrough manager and hook for Limine bootloader"
arch=('any')
url="https://github.com/weignerg/limine-vfio"
license=('MIT')
depends=('bash' 'coreutils' 'pciutils' 'limine' 'limine-entry-tool')
optdepends=(
    'mkinitcpio: for creating early initramfs with vfio modules'
    'limine-mkinitcpio-hook: for automatic hook execution on kernel upgrades'
    'qemu-desktop: for KVM virtual machine execution'
    'libvirt: for virtualization stack management'
    'zenity: for optional GUI privilege escalation prompts'
)
backup=('etc/vfio-passthrough.conf')
install=limine-vfio.install
source=("limine-vfio"
        "95-vfio-entries"
        "vfio-passthrough.conf.example"
        "example-profile.conf"
        "LICENSE")
sha256sums=('3e40a330a710e59a9c88f4e42e7557aa2a0549c1ff214b7046f0a0066488f39b'
            '00a42b5a1ae5e9966424333986a7b54cc33408ca7566a72d8ee88a626ed2c2bd'
            '02438e03bc29ccf9d8178a465d0981347e649bed8f0ef5ce38a3e872fa61ae60'
            'd29a0d4ac548ff10b4add8da243259b258961c502204e1633732dcd2f360e37d'
            '7f902bcc9bc916d46f0c46d642e2f37e878a464a89f7bc37b8eaa13e0830ae57')

package() {
    cd "$srcdir"

    # 1. Install CLI executable and backward-compatibility symlink
    install -Dm755 limine-vfio "${pkgdir}/usr/bin/limine-vfio"
    ln -sf limine-vfio "${pkgdir}/usr/bin/cachyos-vfio"

    # 2. Install Limine post-hook
    install -Dm755 95-vfio-entries "${pkgdir}/etc/boot/hooks/post.d/95-vfio-entries"

    # 3. Create config directory and default global config
    install -d "${pkgdir}/etc/vfio-passthrough.d"
    install -Dm644 vfio-passthrough.conf.example "${pkgdir}/etc/vfio-passthrough.conf"

    # 4. Install example profile into documentation
    install -Dm644 example-profile.conf "${pkgdir}/usr/share/doc/${pkgname}/examples/example-profile.conf"

    # 5. Install license
    install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
