#
# Script: ~/.bashrc
# Executado por shells interativos.
# Define variáveis e carrega os scripts rc.
# =============================================================================

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

# Garante que a estrutura de pastas existe (evitar erro "File not found")
if [ ! -d "$XDG_CACHE_HOME" ] || [ ! -d "$XDG_CONFIG_HOME" ] || \
   [ ! -d "$XDG_DATA_HOME" ]  || [ ! -d "$XDG_STATE_HOME" ]; then
    mkdir -p "$XDG_CACHE_HOME" "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
fi

# Carrega primeiro os scripts com definições usadas pelos demais scripts rc
source "$XDG_CONFIG_HOME/bashrc/bash-envs.sh"
source "$XDG_CONFIG_HOME/bashrc/bash-functions.sh"

# Carrega os demais scripts rc *ordem alfabética), pulando os que são carregados explicitamente
for rc in "$XDG_CONFIG_HOME"/bashrc/*.sh; do
    case "$rc" in
        */bash-envs.sh | */bash-functions.sh | */bash-junctions.sh) continue ;;
    esac
    source "$rc"
done

# Carrega por último o que depender de definições feitas pelos scripts anteriores
source "$XDG_CONFIG_HOME/bashrc/bash-junctions.sh"

# Limpa variáveis do escopo global
unset rc _xdg

#--------------------------------------------------------------------------------
#--- Final do script ~/.bashrc
#--------------------------------------------------------------------------------