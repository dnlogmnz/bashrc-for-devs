#
# Script: ~/.config/bashrc/bash-envs.sh
# Aliases e variáveis de ambiente para o Git Bash
# ==========================================================================================

# Garantir que a estrutura de pastas existe (evitar erro "File not found")
mkdir -p $XDG_CACHE_HOME
mkdir -p $XDG_CONFIG_HOME/vim
mkdir -p $XDG_DATA_HOME
mkdir -p $XDG_STATE_HOME/{bash,less,vim}

# Diretório base para aplicações e ferramentas.
export APPS_BASE="/d/${USERNAME}/Apps"

# Configurações de histórico de comandos no bash
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoredups:erasedups
export HISTFILE="$XDG_STATE_HOME/bash/history"

# Configurações para aplicativos GNU com Suporte Nativo ao XDG
export LESSCHARSET=utf-8
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'

# Variáveis "LINHA" e "TRACO"
export LINHA="$(for i in `seq 1 $COLUMNS`; do echo -n "="; done)"
export TRACO="$(for i in `seq 1 $COLUMNS`; do echo -n "-"; done)"

# Aliases para facilitar o uso do Git Bash
alias ll="/usr/bin/ls -l --color=auto --show-control-chars"
alias la="/usr/bin/ls -lA --color=auto --show-control-chars"
alias grep="/usr/bin/grep --color=auto"
alias npp='/usr/bin/start $APPS_BASE/Notepad++/notepad++.exe "$@"'

#-------------------------------------------------------------------------------------------
#--- Final do script bash-envs.sh
#-------------------------------------------------------------------------------------------