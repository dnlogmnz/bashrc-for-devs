#
# Script: ~/.config/bash/uv-envs.sh
# Variaveis de ambiente para o UV (Python Package Manager)
# ==========================================================================================

# Diretórios e arquivos do Python grenciado pelo UV
export UV_PYTHON_INSTALL_DIR="${APPS_BASE}/Python"       # diretóro contendo as diferentes versões do Python
export UV_PYTHON_BIN_DIR="${UV_PYTHON_INSTALL_DIR}/bin"  # shims do Python: links para os executáveis do Python

# Diretórios e arquivos do UV
export UV_HOME="${UV_PYTHON_INSTALL_DIR}/uv"   # diretório base do uv
export UV_INSTALL_DIR="${UV_HOME}/bin"         # binários: uv.exe, uvw.exe, uvx.exe
export UV_CACHE_DIR="${UV_HOME}/cache"         # cache das packages python
export UV_TOOL_DIR="${UV_HOME}/tools"          # ferramentas do uv: ruff, black, etc

# Configurações do UV
# export UV_PYTHON="3.14"                        # versão padrão do Python para todos os projetos
export UV_LINK_MODE="copy"                     # define como o UV deve tratar links simbólicos
export UV_PYTHON_INSTALL_REGISTRY="1"          # registrar as instalações do Python no Windows Registry
export UV_PYTHON_DOWNLOADS="manual"            # desabilitar os downloads automáticos do Python pelo uv
export UV_NATIVE_TLS="1"                       # usar os certificados do Windows (SChannel)

# Criar Diretórios para python
if [ -d "${APPS_BASE}" ]
    then mkdir -p $UV_PYTHON_INSTALL_DIR $UV_PYTHON_BIN_DIR
    else displayFailure "ERRO" "Diretório '$APPS_BASE' (\$APPS_BASE) não existe"
fi

# Criar Diretórios para uv
if [ -d "${UV_PYTHON_INSTALL_DIR}" ]
    then mkdir -p $UV_HOME $UV_INSTALL_DIR $UV_CACHE_DIR $UV_TOOL_DIR
    else displayFailure "ERRO" "Diretório '$UV_PYTHON_INSTALL_DIR' (\$UV_PYTHON_INSTALL_DIR) não existe"
fi

#  Adicionar diretório dos binários UV ao PATH
if [[ ":$PATH:" != ":${UV_INSTALL_DIR}:" ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(path2win "$UV_INSTALL_DIR")\" ao PATH"
    export PATH="${UV_INSTALL_DIR}:$PATH"
fi

#  Adicionar diretório dos binários do Python gerenciado pelo UV ao PATH
if [ -d "${UV_PYTHON_BIN_DIR}" ]; then
    if [[ ":$PATH:" != ":${UV_PYTHON_BIN_DIR}:" ]]; then
        displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(path2win "$UV_PYTHON_BIN_DIR")\" ao PATH"
        export PATH="${UV_PYTHON_BIN_DIR}:$PATH"
    fi
fi



# Adicionar Python atual ao PATH
if [ -d "$PYTHON_BASE/current" ]; then
    if [[ ":$PATH:" != *":${PYTHON_BASE}/current:"* ]]; then
        displayWarning "Aviso" "Recomendável adicionar \"$PYTHON_BASE/current\" ao PATH do Windows"
        export PATH="$PYTHON_BASE/current:$PATH"
    fi
fi





# Habilitar o autocompletion para comandos uv e uvx
if [ -r "${UV_INSTALL_DIR}/uv" ]; then
    echo 'eval "$(uv generate-shell-completion bash)"' 1> /tmp/uv-autocompletion.sh 2>/dev/null
    echo 'eval "$(uvx --generate-shell-completion bash)"' 1>> /tmp/uv-autocompletion.sh 2>/dev/null
    source /tmp/uv-autocompletion.sh
    rm -f /tmp/uv-autocompletion.sh
fi

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/uv-envs.sh
#-------------------------------------------------------------------------------------------