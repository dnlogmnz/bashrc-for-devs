#!/bin/bash
# Projeto: bashrc-for-devs
#
# Script: ~/bin/helpers/node-junction.sh
# Descrição: Funções para gerenciamento de junctions do Node.js no Windows
# ==========================================================================================

# Source do helper de versão corrente
if [ -f "${HOME}/bin/helpers/node-current.sh" ]; then
    source "${HOME}/bin/helpers/node-current.sh"
fi

#-------------------------------------------------------------------------------------------
# HELPER: Cria ou recria a junction $NODE_CURRENT → $node_dir via cmd.exe
# Equivalente nvm: nvm alias default <versão>
# Dependência externa: cygpath — converte caminhos Unix para Windows
#-------------------------------------------------------------------------------------------
_node_set_junction() {
    local new_current_dir="$1"

    # Converter caminhos para formato Windows (necessário para mklink /J)
    local win_current win_target
    win_current=$(command cygpath -w -- "$NODE_CURRENT")
    win_target=$(command cygpath -w -- "$new_current_dir")

    # Remover junction existente
    if [ -e "$NODE_CURRENT" ] || [ -L "$NODE_CURRENT" ]; then
        displayInfo "Remover configuração atual" "$NODE_CURRENT"
        rm "$NODE_CURRENT" || exit 1
    fi

    # Criar nova junction
    displayInfo "Configurar nova versão padrão" "$new_current_dir"
    cmd.exe //c "mklink /J $win_current $win_target" 1>/dev/null 2>&1
    exit_code=$?

    echo ""
    if [ $exit_code -eq 0 ]; then
        displaySuccess "Sucesso" "Junction criada: $NODE_CURRENT → $new_current_dir"
        return 0
    else
        displayFailure "Erro" "mklink falhou"
        displayWarning "Dica" "Verifique se o terminal tem acesso ao cmd.exe e se os caminhos existem"
        return 1
    fi
}

#-------------------------------------------------------------------------------------------
#--- Final do script node-junction.sh
#-------------------------------------------------------------------------------------------
