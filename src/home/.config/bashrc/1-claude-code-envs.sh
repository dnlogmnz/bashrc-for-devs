#
# Script: ~/.config/bashrc/1-claude-code-envs.sh
# Valida variáveis de ambiente e configura aliases para uso do Claude Code.
# ==========================================================================================

# ---------------------------------------------------------------------------
# Alias de conveniência
# ---------------------------------------------------------------------------
alias c="claude"
alias cc="claude --continue"

# ---------------------------------------------------------------------------
# Configurar CLAUDE_CONFIG_DIR (obrigatório para padrão XDG)
#
# O Claude Code procura seu diretório de configuração na seguinte ordem:
#   1. Variável CLAUDE_CONFIG_DIR (se já definida antes de abrir o shell)
#   2. Padrão XDG: $XDG_CONFIG_HOME/claude  (ex: ~/.config/claude)
#   3. Padrão original: $HOME/.claude
## ---------------------------------------------------------------------------
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
_claude_validate_required_config() {

    # --- CLAUDE_CODE_GIT_BASH_PATH -------------------------------------------
    # Se a variável não estiver definida, emite aviso
    if [[ -z "$CLAUDE_CODE_GIT_BASH_PATH" ]]; then
        displayFailure "Claude Code" "CLAUDE_CODE_GIT_BASH_PATH não definida → configure em: Variáveis de ambiente para sua conta"
    fi

    # --- Autenticação -------------------------------------------------------
    # Pelo menos uma das formas de autenticação deve estar configurada:
    #   - ANTHROPIC_API_KEY     → API Key do Console da Anthropic
    #   - ANTHROPIC_AUTH_TOKEN  → Token de AI Gateway / LiteLLM
    #   - CLAUDE_CODE_USE_BEDROCK / CLAUDE_CODE_USE_VERTEX → provedores cloud
    #     (credenciais são geridas pelo AWS/GCP SDK, não por variáveis Anthropic)
    #
    # NOTA: Assinantes Pro/Max que fazem login OAuth não precisam de nenhuma
    #       dessas variáveis — o Claude Code usa o token OAuth salvo em disco.
    # -------------------------------------------------------------------------
    local has_auth=0
    [[ -n "$ANTHROPIC_API_KEY" ]]       && has_auth=1
    [[ -n "$ANTHROPIC_AUTH_TOKEN" ]]    && has_auth=1
    [[ -n "$CLAUDE_CODE_USE_BEDROCK" ]] && has_auth=1
    [[ -n "$CLAUDE_CODE_USE_VERTEX" ]]  && has_auth=1

    # Verifica também se há credenciais OAuth já salvas em disco
    local oauth_creds="$CLAUDE_CONFIG_DIR/.credentials.json"
    [[ -f "$oauth_creds" ]] && has_auth=1

    if [[ "$has_auth" -eq 0 ]]; then
        displayWarning "Claude Code" "Nenhuma autenticação configurada."
        displayInfo    "Opções"      "ANTHROPIC_API_KEY (Console), ANTHROPIC_AUTH_TOKEN (Gateway), CLAUDE_CODE_USE_BEDROCK/VERTEX, ou login OAuth (Claude AI)"
    fi

    # --- settings.json -------------------------------------------------------
    local global_settings="${CLAUDE_CONFIG_DIR}/settings.json"
    if [[ ! -f "$global_settings" ]]; then
        displayWarning "Claude Code" "settings.json não encontrado: $global_settings"
        displayInfo    "Criar com"   "touch \"$global_settings\""
    fi

}

# Permite suprimir a validação para testes ou automação
if [[ "${CLAUDE_SKIP_VALIDATION:-0}" != "1" ]]; then
    _claude_validate_required_config
fi

# Limpar função auxiliar do escopo global
unset -f _claude_validate_required_config

#-------------------------------------------------------------------------------------------
#--- Final do script 1-claude-code-envs.sh
#-------------------------------------------------------------------------------------------
