#
# Script: ~/.bashrc
# Executado por shells interativos.
# Define variáveis e carrega os scripts rc.
# =============================================================================

# Configurações de locale
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Mapeia variáveis de ambiente com diretórios XDG normalizadas com "cygpath -u" para array "_xdg"
mapfile -t _xdg < <(cygpath -u \
    "${XDG_CACHE_HOME:-$HOME/.cache}" \
    "${XDG_CONFIG_HOME:-$HOME/.config}" \
    "${XDG_DATA_HOME:-$HOME/.local/share}" \
    "${XDG_STATE_HOME:-$HOME/.local/state}"
    )

# Define as variáveis de diretórios padrão XDG (X Desktop Group)
export \
    XDG_CACHE_HOME="${_xdg[0]}" \
    XDG_CONFIG_HOME="${_xdg[1]}"\
    XDG_DATA_HOME="${_xdg[2]}" \
    XDG_STATE_HOME="${_xdg[3]}"

# Carrega (source) dos scripts de inicialização do shell (run command files)
for rc in $XDG_CONFIG_HOME/bashrc/*.sh; do
    source "$rc"
done

# Limpa variáveis do escopo global
unset rc _xdg

#--------------------------------------------------------------------------------
#--- Final do script ~/.bashrc
#--------------------------------------------------------------------------------