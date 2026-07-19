#!/bin/bash
# Projeto: bashrc-for-devs
#
# Script: scripts/install.sh
# Objetivo: Instala ou atualiza os arquivos do bashrc-for-devs em $HOME usando install-manifest.txt
# ==========================================================================================

# abortar em erro/variável não definida: evita instalação parcial silenciosa
set -euo pipefail

# funções display + resolve_entry + manifesto validado
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

# contador de cópias que falharam, usado no exit code final
failures=0

displayAction "Instalando bashrc-for-devs em \$HOME..."

# Copiar cada entrada do manifesto do payload do repo para o destino real resolvido
while IFS= read -r path || [ -n "$path" ]; do
  [ -z "$path" ] && continue

  resolve_entry "$path"
  dest="$entry_path"
  src="$payload_root/$path"

  # Manifesto desatualizado em relação a src/home: avisar em vez de deixar o cp falhar
  if [ ! -e "$src" ]; then
    displayWarning "Pulado" "$path (ausente em src/home)"
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  if cp -a "$src" "$dest"; then
    displaySuccess "OK" "$path"
  else
    displayFailure "Falha" "$path -> $dest"
    failures=$((failures + 1))
  fi
done < "$manifest"

if [ "$failures" -gt 0 ]; then
  displayFailure "Instalação concluída com erros" "$failures arquivo(s) não copiado(s)"
  exit 1
fi

displaySuccess "Instalação concluída" "$HOME"

#-------------------------------------------------------------------------------------------
#--- Final do script install.sh
#-------------------------------------------------------------------------------------------
