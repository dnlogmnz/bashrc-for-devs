#
# Projeto: bashrc-for-devs
#
# Script: ~/.bashrc
# Descrição: Define variáveis XDG e carrega os scripts rc.
# Nota: Executado por shells interativos.
# =============================================================================

# Resolve os defaults XDG (já em formato Unix na maioria dos casos)
_xdg_cache="${XDG_CACHE_HOME:-$HOME/.cache}"
_xdg_config="${XDG_CONFIG_HOME:-$HOME/.config}"
_xdg_data="${XDG_DATA_HOME:-$HOME/.local/share}"
_xdg_state="${XDG_STATE_HOME:-$HOME/.local/state}"

# cygpath só é chamado se algum valor vier em formato Windows (evita fork no caso comum)
if [[ "$_xdg_cache" == [A-Za-z]:* || "$_xdg_config" == [A-Za-z]:* || \
      "$_xdg_data"  == [A-Za-z]:* || "$_xdg_state"  == [A-Za-z]:* ]]; then
    mapfile -t _xdg < <(cygpath -u "$_xdg_cache" "$_xdg_config" "$_xdg_data" "$_xdg_state")
    _xdg_cache="${_xdg[0]}"; _xdg_config="${_xdg[1]}"; _xdg_data="${_xdg[2]}"; _xdg_state="${_xdg[3]}"
fi

# Define as variáveis de diretórios padrão XDG (X Desktop Group)
export \
    XDG_CACHE_HOME="$_xdg_cache" \
    XDG_CONFIG_HOME="$_xdg_config" \
    XDG_DATA_HOME="$_xdg_data" \
    XDG_STATE_HOME="$_xdg_state"

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
unset rc _xdg _xdg_cache _xdg_config _xdg_data _xdg_state

#--------------------------------------------------------------------------------
#--- Final do script ~/.bashrc
#--------------------------------------------------------------------------------