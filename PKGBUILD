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
        "limine-vfio.bash"
        "limine-vfio.zsh"
        "limine-vfio.fish"
        "limine-vfio.1"
        "LICENSE")
sha256sums=('f82f817dcd0085c501d95ae6a8c2eea26d4390899a59f9f3b9017f69ff4f6145'
            '5c5580d514fc6dbd03b1b3d9769564d798ca222958ec117cd8ae57090ec4eeaa'
            '02438e03bc29ccf9d8178a465d0981347e649bed8f0ef5ce38a3e872fa61ae60'
            'd29a0d4ac548ff10b4add8da243259b258961c502204e1633732dcd2f360e37d'
            '0ddc1cd319dc945918c946ebd16d966f39ca96e8d8dbc9cb2c1cfc9956dcc81f'
            '110dbfe7bc81db157347a6b05df6e4be06ab97f72f7469699e9f4233ce178832'
            '6acbc86139527ca4d54eed7873579a019d74959ad2601c9b5300759795e977be'
            '19b0794b854101fe21aaf182e9cc0ef93024702f9b4be526f2f5e8c6e702bba0'
            '7f902bcc9bc916d46f0c46d642e2f37e878a464a89f7bc37b8eaa13e0830ae57')

package() {
    cd "$srcdir"

    # 1. Install CLI executable
    install -Dm755 limine-vfio "${pkgdir}/usr/bin/limine-vfio"

    # 2. Install Limine post-hook
    install -Dm755 95-vfio-entries "${pkgdir}/etc/boot/hooks/post.d/95-vfio-entries"

    # 3. Create config directory and default global config
    install -d "${pkgdir}/etc/vfio-passthrough.d"
    install -Dm644 vfio-passthrough.conf.example "${pkgdir}/etc/vfio-passthrough.conf"

    # 4. Install example profile into documentation
    install -Dm644 example-profile.conf "${pkgdir}/usr/share/doc/${pkgname}/examples/example-profile.conf"

    # 5. Install shell completions
    install -Dm644 limine-vfio.bash "${pkgdir}/usr/share/bash-completion/completions/limine-vfio"
    install -Dm644 limine-vfio.zsh "${pkgdir}/usr/share/zsh/site-functions/_limine-vfio"
    install -Dm644 limine-vfio.fish "${pkgdir}/usr/share/fish/vendor_completions.d/limine-vfio.fish"

    # 6. Install manual page
    install -Dm644 limine-vfio.1 "${pkgdir}/usr/share/man/man1/limine-vfio.1"

    # 7. Install license
    install -Dm644 LICENSE "${pkgdir}/usr/share/licenses/${pkgname}/LICENSE"
}
