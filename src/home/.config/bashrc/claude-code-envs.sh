#
# Script: ~/.config/bashrc/claude-code-envs.sh
# Valida variáveis de ambiente e configura aliases para uso do Claude Code.
# ==========================================================================================

# ---------------------------------------------------------------------------
# CLAUDE_CONFIG_DIR
# O Claude Code procura seu diretório de configuração na seguinte ordem:
#   1. Variável CLAUDE_CONFIG_DIR (se já definida antes de abrir o shell)
#   2. Instalação padrão: $HOME/.claude
#
# Se você adota o padrão XDG de diretórios em seu computador, a variável deve
# apontar para $XDG_CONFIG_HOME/claude (geralmente $HOME/.config/claude).
# ---------------------------------------------------------------------------
if [[ -z "$CLAUDE_CONFIG_DIR" ]]; then
    if [[ -n "$XDG_CONFIG_HOME" ]]; then
        export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
    elif [[ -n "$HOME" ]]; then
        export CLAUDE_CONFIG_DIR="$HOME/.config/claude"
    fi
fi

# ---------------------------------------------------------------------------
# Validação das configurações obrigatórias e recomendadas
# ---------------------------------------------------------------------------

# Verdadeiro se a chave está definida no ambiente OU presente no settings.json.
# Lê 'settings_content' do escopo do chamador (escopo dinâmico do bash).
_claude_is_set() {
    local key="$1"
    [[ -n "${!key}" ]]                          && return 0   # variável de ambiente
    [[ "$settings_content" == *"\"$key\""* ]]   && return 0   # bloco "env" do settings.json
    return 1
}

_claude_validate_required_config() {

    # Lê o settings.json global uma única vez via redireção builtin (sem fork).
    # Reutilizado pelas validações abaixo para inspecionar o bloco "env".
    local global_settings="${CLAUDE_CONFIG_DIR}/settings.json"
    local settings_content=""
    [[ -f "$global_settings" ]] && settings_content="$(< "$global_settings")"

    # --- CLAUDE_CODE_GIT_BASH_PATH -------------------------------------------
    # Validação em ordem de prioridade (linha de comando é ignorada aqui):
    #   1. Variável de ambiente → se definida, foi escolha consciente do dev → OK
    #   2. settings.json        → local esperado pelo projeto (bloco "env")  → OK
    # Não estando em nenhum nível, falha apontando para o settings.json.
    if ! _claude_is_set CLAUDE_CODE_GIT_BASH_PATH; then
        displayFailure "Claude Code" "CLAUDE_CODE_GIT_BASH_PATH não definida → adicione no bloco \"env\" de $global_settings"
    fi

    # --- Autenticação -------------------------------------------------------
    # Métodos explícitos, mutuamente exclusivos (apenas UM deve estar definido):
    #   - ANTHROPIC_API_KEY        → API Key do Console da Anthropic
    #   - ANTHROPIC_AUTH_TOKEN     → Token de AI Gateway / LiteLLM
    #   - CLAUDE_CODE_USE_BEDROCK  → AWS Bedrock   (credenciais geridas pelo AWS SDK)
    #   - CLAUDE_CODE_USE_VERTEX   → GCP Vertex AI (credenciais geridas pelo GCP SDK)
    #   - CLAUDE_CODE_USE_FOUNDRY  → Azure Foundry (API Key / Entra ID, geridas pelo Azure SDK)
    # Cada método é checado no ambiente OU no settings.json (via _claude_is_set).
    #
    # OAuth (login Claude AI) é o fallback padrão e NÃO entra na contagem de
    # conflito: o token salvo em disco coexiste de forma dormente com um método
    # explícito (a API Key/provider vence). Só importa quando nenhum método
    # explícito foi definido.
    # -------------------------------------------------------------------------
    local auth_methods=()
    _claude_is_set ANTHROPIC_API_KEY       && auth_methods+=("ANTHROPIC_API_KEY")
    _claude_is_set ANTHROPIC_AUTH_TOKEN    && auth_methods+=("ANTHROPIC_AUTH_TOKEN")
    _claude_is_set CLAUDE_CODE_USE_BEDROCK && auth_methods+=("CLAUDE_CODE_USE_BEDROCK")
    _claude_is_set CLAUDE_CODE_USE_VERTEX  && auth_methods+=("CLAUDE_CODE_USE_VERTEX")
    _claude_is_set CLAUDE_CODE_USE_FOUNDRY && auth_methods+=("CLAUDE_CODE_USE_FOUNDRY")

    local oauth_creds="$CLAUDE_CONFIG_DIR/.credentials.json"
    local n=${#auth_methods[@]}

    if (( n > 1 )); then
        # Conflito: mais de um provedor/credencial explícito definido.
        displayFailure "Claude Code" "Múltiplos métodos de autenticação definidos — use apenas um: ${auth_methods[*]}"
    elif (( n == 0 )) && [[ ! -f "$oauth_creds" ]]; then
        # Nenhum método explícito e sem login OAuth em disco.
        displayWarning "Claude Code"      "Nenhuma autenticação configurada. Opções:"
        displayInfo    "Claude AI (web)"  "login em Claude AI (padrão) - requer assinatura Anthropic Pro/Max"
        displayInfo    "Anthropic API"    "ANTHROPIC_API_KEY"
        displayInfo    "AI Gateway"       "ANTHROPIC_AUTH_TOKEN"
        displayInfo    "Azure Foundry"    "CLAUDE_CODE_USE_FOUNDRY"
        displayInfo    "AWS Bedrock"      "CLAUDE_CODE_USE_BEDROCK"
        displayInfo    "Google Vertex AI" "CLAUDE_CODE_USE_VERTEX"
    fi

    # --- settings.json -------------------------------------------------------
    if [[ ! -f "$global_settings" ]]; then
        displayWarning "Claude Code" "settings.json não encontrado: $global_settings"
        displayInfo    "Criar com"   "touch \"$global_settings\""
    fi

}

_claude_validate_required_config

# Limpar funções auxiliares do escopo global
unset -f _claude_validate_required_config _claude_is_set

#-------------------------------------------------------------------------------------------
#--- Final do script claude-code-envs.sh
#-------------------------------------------------------------------------------------------
