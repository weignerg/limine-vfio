# Fish shell completions for limine-vfio

function __limine_vfio_profiles
    find /etc/vfio-passthrough.d/ -maxdepth 1 -name "*.conf" 2>/dev/null | sed -E 's|.*/(.*)\.conf|\1|'
end

complete -c limine-vfio -f

# Subcommands
complete -c limine-vfio -n "__fish_use_subcommand" -a check -d "Run pre-flight diagnostics (CPU, IOMMU, Limine, modules)"
complete -c limine-vfio -n "__fish_use_subcommand" -a list-devices -d "Display PCI devices, classifications, and IOMMU groups"
complete -c limine-vfio -n "__fish_use_subcommand" -a status -d "Display active driver bindings and configured profiles"
complete -c limine-vfio -n "__fish_use_subcommand" -a add -d "Interactive wizard to configure a new passthrough profile"
complete -c limine-vfio -n "__fish_use_subcommand" -a remove -d "Remove an existing passthrough profile"
complete -c limine-vfio -n "__fish_use_subcommand" -a generate-xml -d "Generate libvirt <hostdev> XML block for virt-manager/virsh"
complete -c limine-vfio -n "__fish_use_subcommand" -a install -d "Deploy Limine hook, initialize directories, and link binary"
complete -c limine-vfio -n "__fish_use_subcommand" -a help -d "Show help information"

# Subcommand arguments: remove and generate-xml complete configured profiles
complete -c limine-vfio -n "__fish_seen_subcommand_from remove generate-xml xml virt-xml" -a "(__limine_vfio_profiles)" -d "Passthrough Profile"
