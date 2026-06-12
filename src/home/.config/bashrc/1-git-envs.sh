#
# Script: ~/.config/bashrc/git-envs.sh
# Aliases e Variaveis de ambiente para o Git CLI
# Ver: https://git-scm.com/book/en/v2/Git-Internals-Environment-Variables
# ==========================================================================================

# Define que o "gitconfig" será armazenado em diretório compatível com XDG / FHS
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"
[ -d "${GIT_CONFIG_GLOBAL%/*}" ] || mkdir -p "${GIT_CONFIG_GLOBAL%/*}"

# Aliases para facilitar o uso do Git CLI
alias git-log="git log --oneline --graph --all"
alias git-last="git log -1 HEAD"
alias git-unstage="git reset HEAD --"

#-------------------------------------------------------------------------------------------
#--- Final do script git-envs.sh
#-------------------------------------------------------------------------------------------