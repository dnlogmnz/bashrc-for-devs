#!/bin/bash

# 1. Criar estrutura de diretórios XDG
mkdir -p "$HOME/.config/git"
mkdir -p "$HOME/.config/zsh"
mkdir -p "$HOME/.config/vim"
mkdir -p "$HOME/.local/share"
mkdir -p "$HOME/.local/state/less"
mkdir -p "$HOME/.local/state/vim"

display_move() {
    if [ -f "$1" ]; then
        if [ ! -f "$2" ]; then
            mv "$1" "$2"
            echo "[OK] Movido: $1 -> $2"
        else
            echo "[AVISO] Destino já existe, não movido: $2"
        fi
    fi
}

# 2. Migrar arquivos
echo "Iniciando migração de arquivos..."

# Git
display_move "$HOME/.gitconfig" "$HOME/.config/git/config"

# Vim
display_move "$HOME/.vimrc" "$HOME/.config/vim/vimrc"
line='set viminfo+=n~/.local/state/vim/viminfo'
file="$HOME/.config/vim/vimrc"
grep -Fxq "$line" "$file" || echo -e "\n$line" >> "$file"

# Zsh
display_move "$HOME/.zshrc" "$HOME/.config/zsh/.zshrc"

# Históricos (opcional, você pode apenas deletar os antigos)
display_move "$HOME/.node_repl_history" "$HOME/.local/share/node_repl_history"
display_move "$HOME/.lesshst" "$HOME/.local/state/less/history"

echo "---------------------------------------------------"
echo "Migração concluída. Certifique-se de ter adicionado"
echo "os 'exports' ao seu arquivo de inicialização."
