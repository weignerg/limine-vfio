# Bash completion for limine-vfio

_limine_vfio() {
    local cur prev words cword
    _init_completion || return

    local commands="check list-devices status add remove generate-xml doctor install help"

    if [[ $cword -eq 1 ]]; then
        COMPREPLY=( $(compgen -W "${commands}" -- "${cur}") )
        return 0
    fi

    case "${words[1]}" in
        remove|generate-xml|xml|virt-xml)
            local profiles=""
            if [[ -d /etc/vfio-passthrough.d ]]; then
                profiles=$(find /etc/vfio-passthrough.d/ -maxdepth 1 -name "*.conf" -exec basename {} .conf \; 2>/dev/null)
            fi
            COMPREPLY=( $(compgen -W "${profiles}" -- "${cur}") )
            return 0
            ;;
        *)
            ;;
    esac
}

complete -F _limine_vfio limine-vfio
