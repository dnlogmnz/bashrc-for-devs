#!/bin/bash
# Projeto: bashrc-for-devs
#
# Script: ~/bin/helpers/uv-poc-envs.sh
# Descrição: Criar estrutura de ambientes em ./envs/ para Proof of Concept
# Uso: uv-poc-envs.sh
# Cria: envs/prod-a.sh, envs/prod-b.sh, envs/prod-c.sh
# ==========================================================================================

# Verificar se está em um projeto (verificar existência de pyproject.toml)
if [ ! -f "pyproject.toml" ]; then
    displayWarning "Erro" "Arquivo 'pyproject.toml' não encontrado. Você está em um diretório de projeto?"
    exit 1
fi

# Verificar se envs/ já existe
if [ -d "envs" ]; then
    displayWarning "Aviso" "Diretório envs/ já existe. Nenhuma ação foi realizada."
    exit 0
fi

displayAction "Criando estrutura de ambientes em ./envs/"
displayInfo "Ambientes" "prod-a, prod-b, prod-c"

TEMPLATE_FILE="${XDG_DATA_HOME:-$HOME/.local/share}/bash/templates/poc-env.example"
if [ ! -f "$TEMPLATE_FILE" ]; then
    displayFailure "Erro" "Template não encontrado: $TEMPLATE_FILE"
    exit 1
fi

mkdir -p envs
for product in prod-a prod-b prod-c; do
    sed "s/{{PRODUCT_NAME}}/${product}/g" "$TEMPLATE_FILE" > "./envs/${product}.sh"
done

displayAction "Estrutura de ambientes criada com sucesso!"

#-------------------------------------------------------------------------------------------
#--- Final do script uv-poc-envs.sh
#-------------------------------------------------------------------------------------------
