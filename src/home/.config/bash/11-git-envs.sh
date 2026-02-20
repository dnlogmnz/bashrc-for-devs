#
# Script: ~/.config/bash/git-envs.sh
# Variaveis de ambiente para o Git CLI
# Ver: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
# ==========================================================================================

# Garantir que existe o diretório compatível com XDG / FHS para armazenar o "gitconfig"
[ -d "$XDG_CONFIG_HOME" ] && mkdir -p "$XDG_CONFIG_HOME"/git

# Configuração do Git
export GIT_HOME="${APPS_BASE}/Git"
# export GIT_EDITOR=code
# export GIT_PAGER=less

 Adicionar Git ao PATH
if [ -d "$GIT_HOME/cmd" ]; then
    if [[ ":$PATH:" != *":${GIT_HOME}/cmd:"* ]]; then
        displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(path2win "$GIT_HOME/cmd")\" ao PATH"
        export PATH="$GIT_HOME/bin:$PATH"
    fi
fi

# Auto-completar para Git se disponível
if [ -f "$GIT_HOME/etc/bash_completion.d/git-completion.bash" ]; then
    source "$GIT_HOME/etc/bash_completion.d/git-completion.bash"
fi

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/'git-envs.sh'
#-------------------------------------------------------------------------------------------