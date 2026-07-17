#!/bin/bash
# Projeto: bashrc-for-devs
# Script: src/home/install.sh
# Descrição: Instala ou atualiza os arquivos do bashrc-for-devs em $HOME usando install-manifest.txt

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
manifest="$script_dir/install-manifest.txt"

if [ ! -f "$manifest" ]; then
  printf 'Erro: manifesto não encontrado: %s\n' "$manifest" >&2
  exit 1
fi

repo_root="$script_dir"
cd "$repo_root"

# Install each manifest entry. For paths under .local/share, install to XDG_DATA_HOME if set.
while IFS= read -r path || [ -n "$path" ]; do
  # skip empty lines
  [ -z "$path" ] && continue

  if [[ "$path" == .local/share/* ]]; then
    rel_path="${path#./}"
    # strip leading .local/share/
    rel_after="${rel_path#.local/share/}"
    # Map repo's 'bashrc/docs' source to user's 'bash/docs' destination per XDG decision
    if [[ "$rel_after" == bashrc/* ]]; then
      rel_after="bash/${rel_after#bashrc/}"
    fi
    target_base="${XDG_DATA_HOME:-$HOME/.local/share}"
    target_dir="$target_base/$(dirname "$rel_after")"
    mkdir -p "$target_dir"
    cp -a "$path" "$target_base/$rel_after"
  else
    mkdir -p "$HOME/$(dirname "$path")"
    cp -a "$path" "$HOME/$path"
  fi
done < "$manifest"

printf 'Instalação concluída em %s\n' "$HOME"
