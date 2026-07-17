#!/bin/bash
# Projeto: bashrc-for-devs
# Script: ~/.local/share/bashrc/utils/xdg-migrate.sh
# Migrar arquivos de configuração e históricos para os diretórios XDG
# =============================================================================

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Função para mover arquivos
display_move() {
    local src="$1"
    local dst="$2"

    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        if [ ! -f "$dst" ]; then
            mv "$src" "$dst"
            echo "[OK] Movido: $src -> $dst"
        else
            echo "[AVISO] Destino já existe, não movido: $dst"
        fi
    fi
}

# Exibir mensagem de migração de arquivos
echo "Iniciando migração de arquivos..."

# Git
display_move "$HOME/.gitconfig" "$XDG_CONFIG_HOME/git/config"

# Vim
display_move "$HOME/.vimrc" "$XDG_CONFIG_HOME/vim/vimrc"
line='set viminfo+=n~/.local/state/vim/viminfo'
file="$XDG_CONFIG_HOME/vim/vimrc"
if [ -f "$file" ]; then
    grep -Fxq "$line" "$file" || echo -e "\n$line" >> "$file"
fi

# Históricos e estados
if [ -f "$HOME/.node_repl_history" ]; then
    display_move "$HOME/.node_repl_history" "$XDG_STATE_HOME/node/repl_history"
fi
display_move "$HOME/.lesshst" "$XDG_STATE_HOME/less/history"
display_move "$HOME/.python_history" "$XDG_STATE_HOME/python/history"
display_move "$HOME/.bash_history" "$XDG_STATE_HOME/bash/history"

# npm / node / uv / python
if [ -f "$HOME/.npmrc" ]; then
    display_move "$HOME/.npmrc" "$XDG_CONFIG_HOME/npm/npmrc"
fi
if [ -f "$HOME/.uv/uv.toml" ]; then
    mkdir -p "$XDG_CONFIG_HOME/uv"
    display_move "$HOME/.uv/uv.toml" "$XDG_CONFIG_HOME/uv/uv.toml"
fi
if [ -d "$HOME/.npm" ]; then
    mkdir -p "$XDG_DATA_HOME/npm"
    if [ ! -d "$XDG_DATA_HOME/npm" ]; then
        mkdir -p "$XDG_DATA_HOME/npm"
    fi
fi

# Remover diretórios vazios antigos, se existirem
rmdir "$HOME/.uv" 2>/dev/null || true
rmdir "$HOME/.npm" 2>/dev/null || true

echo "---------------------------------------------------"
echo "Migração concluída. Certifique-se de ter adicionado"
echo "os 'exports' ao seu arquivo de inicialização."
