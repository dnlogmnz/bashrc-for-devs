#!/bin/bash
# Projeto: bashrc-for-devs
#
# Script: ~/bin/helpers/uv-dot-env.sh
# Objetivo: Criar arquivo .env no diretório corrente com template de variáveis de ambiente
# Nota: Detecta automaticamente se está em um projeto (busca por pyproject.toml)
# ==========================================================================================

# Validar se está em um projeto (verificar existência de pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    displayWarning "Erro" "Arquivo 'pyproject.toml' não encontrado. Você está em um diretório de projeto?"
    exit 1
fi

# Verificar se .env já existe
if [ -f ".env" ]; then
    displayWarning "Aviso" "Arquivo .env já existe. Nenhuma ação foi realizada."
    exit 0
fi

# Criar .env com template
displayAction "Criando arquivo .env com template de variáveis de ambiente"

TEMPLATE_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/bash/templates/dot-env.example"
if [ ! -f "$TEMPLATE_FILE" ]; then
    displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
    exit 1
fi

cat "$TEMPLATE_FILE" > .env

displayAction "Arquivo .env criado com sucesso!"

#-------------------------------------------------------------------------------------------
#--- Final do script uv-dot-env.sh
#-------------------------------------------------------------------------------------------
