#compdef limine-vfio

_limine_vfio() {
    local -a commands
    commands=(
        'check:Run pre-flight diagnostics (CPU, IOMMU, Limine, modules)'
        'list-devices:Display all PCI devices, classifications, and IOMMU groups'
        'status:Display current driver bindings, active cmdline, and configured profiles'
        'add:Interactive wizard to discover, classify, and configure a new passthrough profile'
        'remove:Interactive removal of an existing passthrough profile'
        'generate-xml:Generate libvirt <hostdev> XML block for virt-manager/virsh'
        'install:Deploy Limine hook, initialize /etc/vfio-passthrough.d, and link binary'
        'help:Show help message'
    )

    _arguments -C \
        '1: :->command' \
        '2: :->argument'

    case $state in
        command)
            _describe -t commands 'limine-vfio command' commands
            ;;
        argument)
            case $words[1] in
                remove|generate-xml|xml|virt-xml)
                    local -a profiles
                    if [[ -d /etc/vfio-passthrough.d ]]; then
                        profiles=($(find /etc/vfio-passthrough.d/ -maxdepth 1 -name "*.conf" -exec basename {} .conf \; 2>/dev/null))
                    fi
                    _describe -t profiles 'configured profile' profiles
                    ;;
            esac
            ;;
    esac
}

_limine_vfio "$@"
