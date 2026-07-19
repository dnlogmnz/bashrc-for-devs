#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/bash-envs.sh
# Objetivo: definir aliases e variáveis de ambiente para o Git Bash
# ==========================================================================================
cd $HOME

# Diretório base para aplicações e ferramentas
# cygpath só é chamado se o valor vier em formato Windows (evita fork no caso comum)
_apps_base="${APPS_BASE:-/d/${USERNAME}/Apps}"
[[ "$_apps_base" == [A-Za-z]:* ]] && _apps_base="$(cygpath -u -- "$_apps_base")"
export APPS_BASE="$_apps_base"
unset _apps_base

# Configurações de locale
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Configurações de histórico de comandos no bash
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTFILE="$XDG_STATE_HOME/bash/history"

# Configurações para aplicativos GNU com Suporte Nativo ao XDG
export LESSCHARSET=utf-8
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
[ -d "$XDG_CONFIG_HOME/vim" ] || mkdir -p "$XDG_CONFIG_HOME/vim"

# Variáveis "LINHA" e "TRACO" — construídas via printf built-in (sem forks)
printf -v LINHA '%*s' "${COLUMNS:-80}" ''; LINHA="${LINHA// /=}"
printf -v TRACO '%*s' "${COLUMNS:-80}" ''; TRACO="${TRACO// /-}"
export LINHA TRACO

# Aliases para facilitar o uso do Git Bash
alias ll="/usr/bin/ls -l --color=auto --show-control-chars"
alias la="/usr/bin/ls -lA --color=auto --show-control-chars"
alias grep="/usr/bin/grep --color=auto"
alias npp='/usr/bin/start $APPS_BASE/Notepad++/notepad++.exe "$@"'

#-------------------------------------------------------------------------------------------
#--- Final do script bash-envs.sh
#-------------------------------------------------------------------------------------------