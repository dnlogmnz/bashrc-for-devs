#!/bin/bash
# Projeto: bashrc-for-devs
#
# Script: scripts/backup.sh
# Objetivo: backup dos arquivos do "bashrc-for-devs" em $HOME usando install-manifest.txt
# ==========================================================================================

# abortar em erro/variável não definida: evita backup parcial silencioso
set -euo pipefail

# funções display + resolve_entry + manifesto validado
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"  

# único consumidor: onde salvar o .tar.gz
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" 

# caminhos absolutos reais que existem e entrarão no backup
entries=()

echo
displayAction "Backup dos arquivos do \"bashrc-for-devs\" em \$HOME usando \"install-manifest.txt\" ..."

# Cada entrada do manifesto que já existe em $HOME/$XDG_DATA_HOME entra no backup; é normal ter entradas
# ausentes (ex. primeira instalação) e só geram aviso, não é erro.
while IFS= read -r path || [ -n "$path" ]; do
  [ -z "$path" ] && continue

  resolve_entry "$path"
  if [ -e "$entry_path" ]; then
    displaySuccess "OK" "$path"
    entries+=("$entry_path")
  else
    displayWarning "Pulado" "$path (não existe em $HOME)"
  fi
done < "$manifest"

if [ "${#entries[@]}" -eq 0 ]; then
  displayWarning "Nada a fazer" "nenhum arquivo do manifesto existe em $HOME ou $XDG_DATA_HOME"
  exit 0
fi

backup_dir="$XDG_STATE_HOME/bashrc/backups"
mkdir -p "$backup_dir"
backup_file="$backup_dir/backup-$(date +%Y%m%d-%H%M%S).tar.gz"

# -P preserva os caminhos absolutos originais dentro do arquivo: não precisa copiar nada
# para uma pasta temporária antes, nem recompor $HOME/$XDG_DATA_HOME na hora de restaurar.
tar -czf "$backup_file" -P "${entries[@]}"

displaySuccess "Backup criado" "$backup_file"

echo
displayAction "Para restaurar, execute:"
displayInfo "tar -xzf \"$backup_file\" -P"

#-------------------------------------------------------------------------------------------
#--- Final do script backup.sh
#-------------------------------------------------------------------------------------------
