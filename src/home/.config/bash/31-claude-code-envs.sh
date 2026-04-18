#
# Script: ~/.config/bash/node-folders.sh
# Valida variáveis de ambiente para uso do Claude Code.
# A gestão do certificado raiz é feita em um script separado: claude-code-cert.sh.
# ==========================================================================================

#-------------------------------------------------------------------------------------------
#--- VALIDAÇÃO DE CONFIGURAÇÃO
#-------------------------------------------------------------------------------------------

# Valida variáveis de ambiente e arquivo de configuração global
_claude_validate_required_config() {
  local required_vars=("ANTHROPIC_API_KEY" "CLAUDE_CODE_GIT_BASH_PATH" "CLAUDE_CONFIG_DIR" "NODE_EXTRA_CA_CERTS")
  
  # Verificar variáveis obrigatórias
  for var_name in "${required_vars[@]}"; do
    if [[ -z "${!var_name}" ]]; then
      displayFailure "Windows" "Variáveis de ambiente para sua conta: definir a variável $var_name"
    fi
  done
  
  # Verificar arquivo de configuração global
  local config_dir
  if [[ -n "$CLAUDE_CONFIG_DIR" ]]; then
    config_dir="$CLAUDE_CONFIG_DIR"
  elif [[ -n "$HOME" ]]; then
    config_dir="$HOME/.config/claude"
  else
    config_dir="$USERPROFILE/.claude"
  fi
  
  # Se o diretório não existir, tentar USERPROFILE
  if [[ ! -d "$config_dir" ]]; then
    displayWarning "Claude Config" "Diretório de configuração não encontrado em $config_dir"
  fi
  
  local global_settings="$config_dir/settings.json"
  
  if [[ ! -f "$global_settings" ]]; then
    displayFailure "Claude Config" "Arquivo settings.json não encontrado em $global_settings"
  fi
}

#-------------------------------------------------------------------------------------------
#--- EXECUTAR VALIDAÇÃO
#-------------------------------------------------------------------------------------------

# Executa validação de configuração obrigatória
_claude_validate_required_config

#-------------------------------------------------------------------------------------------
#--- Final do script claude-code-envs.sh
#-------------------------------------------------------------------------------------------