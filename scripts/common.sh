#!/bin/bash
# Projeto: bashrc-for-devs
#
# Script: scripts/common.sh
# Objetivo: variáveis e funções compartilhadas entre install.sh e backup.sh
# ==========================================================================================

lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$lib_dir/.." && pwd)"
payload_root="$repo_root/src/home"
manifest="$repo_root/scripts/install-manifest.txt"

# Mesmo fallback usado em src/home/.bashrc: install.sh/backup.sh podem rodar antes de
# qualquer sessão com o bashrc-for-devs carregado, então não dá pra assumir que já está exportado.
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Carregar displaySuccess/displayFailure/displayWarning direto do payload: em uma primeira
# instalação, bash-functions.sh ainda não existe em $HOME.
source "$payload_root/.config/bashrc/bash-functions.sh"

if [ ! -f "$manifest" ]; then
  displayFailure "Erro" "manifesto não encontrado: $manifest"
  exit 1
fi

# Mapear uma entrada do manifesto para o caminho absoluto real (destino em install.sh,
# origem em backup.sh): entradas .local/share/bashrc/* vão para $XDG_DATA_HOME/bash/*
# (rename bashrc -> bash, decisão de nomenclatura XDG); as demais vão direto para $HOME/*.
resolve_entry() {
  local path="$1" rel
  if [[ "$path" == .local/share/* ]]; then
    rel="${path#.local/share/}"
    [[ "$rel" == bashrc/* ]] && rel="bash/${rel#bashrc/}"
    entry_path="$XDG_DATA_HOME/$rel"
  else
    entry_path="$HOME/$path"
  fi
}

unset lib_dir

#-------------------------------------------------------------------------------------------
#--- Final do script common.sh
#-------------------------------------------------------------------------------------------
