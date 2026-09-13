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
sha256sums=('c74b0a189eee344c8085cfd24d01c72425cc7400ba02e4f53471b1c4b6904b77'
            'c4475b9f8367f67904be094e42b666a1af13af4fb7a35ab155e00ea41f1a7b69'
            '02438e03bc29ccf9d8178a465d0981347e649bed8f0ef5ce38a3e872fa61ae60'
            'd29a0d4ac548ff10b4add8da243259b258961c502204e1633732dcd2f360e37d'
            '5ca3725946d47b668a4ca1958f6dafa5766973df87ff90c520fa7cb57575e994'
            '2cc0cad4242840c4b5aec0ced9338d832a53358c48f55bc8d76d40181d44c178'
            '89f4afb7bf6caf803d8c1970f4f57dd4676d3999e95d4f437b072045ee02700c'
            'de9ed97fe48c8fa1bb2bf6666c642585c60665d61ee15986a12299bdcc5b5831'
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
