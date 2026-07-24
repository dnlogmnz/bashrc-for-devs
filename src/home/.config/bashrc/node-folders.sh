#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/node-folders.sh
# Objetivo: definir variáveis de ambiente para o Node.js
# =============================================================================================


# Cria os diretórios para evitar erros de permissão ou inexistência
if [ ! -d "$NODE_HOME" ]              || [ ! -d "$NPM_CONFIG_CACHE" ]    || \
   [ ! -d "$NPM_CONFIG_TMP" ]         || [ ! -d "$NPM_CONFIG_LOGS_DIR" ] || \
   [ ! -d "${NODE_REPL_HISTORY%/*}" ] || [ ! -d "${NPM_CONFIG_USERCONFIG%/*}" ]; then
    mkdir -p "$NODE_HOME" \
             "$NPM_CONFIG_CACHE" \
             "$NPM_CONFIG_TMP" \
             "$NPM_CONFIG_LOGS_DIR" \
             "${NODE_REPL_HISTORY%/*}" \
             "${NPM_CONFIG_USERCONFIG%/*}"
fi

# Adicionar Node.js ao PATH
if [[ ":$PATH:" != *":$NODE_CURRENT:"* ]]; then
    displayFailure \
        "Windows" \
        "Variáveis de ambiente para sua conta: adicionar \"$(cygpath -w "$NODE_CURRENT")\" ao PATH"
    export PATH="$NODE_CURRENT:$PATH"
fi

#----------------------------------------------------------------------------------------------
#--- Final do script node-folders.sh
#----------------------------------------------------------------------------------------------