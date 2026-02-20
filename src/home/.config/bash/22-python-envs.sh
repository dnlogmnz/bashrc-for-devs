#
# Script: ~/.config/bash/python-envs.sh
# Variáveis de ambiente para o Python
# ==========================================================================================

# Histórico de comandos digitados no intepretador python
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/python"  # Garante que o diretório do histórico existe
export PYTHONHISTORY="${XDG_DATA_HOME:-$HOME/.local/share}/python/history"

# Configurações do interpretador Python
export PYTHONUNBUFFERED="1"  # Envia outputs (print, logs) diretamente para o terminal, sem uso de buffer
export PYTHONIOENCODING="utf-8"  # Logs podem conter caracteres especiais sem quebrar o coletor de logs 
export PYTHONDONTWRITEBYTECODE="1"  # Acelera import de módulos ao não criar arquivos .pyc (bytecode)

#-------------------------------------------------------------------------------------------
#--- Final do script ~/.config/python-envs.sh
#-------------------------------------------------------------------------------------------