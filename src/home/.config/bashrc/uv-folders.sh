#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/uv-folders.sh
# Objetivo: validar diretórios e PATH para o UV (Python Package Manager)
# ==========================================================================================

# Criar Diretórios para python
if [ -d "${APPS_BASE}" ]; then
    if [ ! -d "$UV_PYTHON_INSTALL_DIR" ] || [ ! -d "$UV_PYTHON_BIN_DIR" ]; then
        mkdir -p "$UV_PYTHON_INSTALL_DIR" "$UV_PYTHON_BIN_DIR"
    fi
else
    displayFailure "ERRO" "Diretório '$APPS_BASE' (\$APPS_BASE) não existe"
fi

# Criar Diretórios para uv
if [ -d "${UV_PYTHON_INSTALL_DIR}" ]; then
    if [ ! -d "$UV_HOME" ] || [ ! -d "$UV_INSTALL_DIR" ] || \
       [ ! -d "$UV_CACHE_DIR" ] || [ ! -d "$UV_TOOL_DIR" ]; then
        mkdir -p "$UV_HOME" "$UV_INSTALL_DIR" "$UV_CACHE_DIR" "$UV_TOOL_DIR"
    fi
else
    displayFailure "ERRO" "Diretório '$UV_PYTHON_INSTALL_DIR' (\$UV_PYTHON_INSTALL_DIR) não existe"
fi

#  Adicionar diretório dos binários UV ao PATH
if [[ ":$PATH:" != *":${UV_INSTALL_DIR}:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(cygpath -w "$UV_INSTALL_DIR")\" ao PATH"
    export PATH="${UV_INSTALL_DIR}:$PATH"
fi

#  Adicionar diretório dos binários do Python gerenciado pelo UV ao PATH
if [ -d "${UV_PYTHON_BIN_DIR}" ]; then
    if [[ ":${PATH}:" != *":${UV_PYTHON_BIN_DIR}:"* ]]; then
        displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(cygpath -w "$UV_PYTHON_BIN_DIR")\" ao PATH"
        export PATH="${UV_PYTHON_BIN_DIR}:$PATH"
    fi
fi

# Obtém o diretório do Windows Store
_store_dir="$(cygpath -u "$LOCALAPPDATA/Microsoft/WindowsApps")"

# Validar que instaladores do python (Windows Store) estão desabilitados: vamos usar python gerenciado pelo 'uv'
for _py_exe in python python3; do
    # type -P é built-in do bash (sem fork), substitui o 'which' externo
    if [[ "$(type -P "$_py_exe")" == "$_store_dir/$_py_exe" ]]; then
        displayFailure "Windows" "Config > Aliases de execução: desabilitar '$_py_exe'"
    fi
done

# Limpa variáveis do escopo global
unset _store_dir _py_exe

#-------------------------------------------------------------------------------------------
#--- Final do script uv-folders.sh
#-------------------------------------------------------------------------------------------