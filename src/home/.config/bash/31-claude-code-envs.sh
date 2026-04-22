#
# Script: ~/.config/bash/31-claude-code-envs.sh
# Valida variáveis de ambiente e configura aliases para uso do Claude Code.
# Depende de funções definidas em 00-bash-functions.sh
# ==========================================================================================

# ---------------------------------------------------------------------------
# Alias de conveniência
# ---------------------------------------------------------------------------
alias c="claude"
alias cc="claude --continue"

# ---------------------------------------------------------------------------
# Configurar CLAUDE_CODE_DIR (obrigatório para padrão XDG)
#
# O Claude Code procura seu diretório de configuração na seguinte ordem:
#   1. Variável CLAUDE_CODE_DIR (se já definida antes de abrir o shell)
#   2. Padrão XDG: $XDG_CONFIG_HOME/claude  (ex: ~/.config/claude)
#   3. Padrão original: $HOME/.claude
#
# Como o Bash RC for Devs adota XDG, forçamos a opção 2 quando a variável
# não estiver previamente definida. Isso garante que tanto o CLI quanto a
# extensão do VS Code encontrem o mesmo settings.json.
# ---------------------------------------------------------------------------
if [[ -z "$CLAUDE_CODE_DIR" ]]; then
    if [[ -n "$XDG_CONFIG_HOME" ]]; then
        export CLAUDE_CODE_DIR="$XDG_CONFIG_HOME/claude"
    elif [[ -n "$HOME" ]]; then
        export CLAUDE_CODE_DIR="$HOME/.config/claude"
    fi
fi

# ---------------------------------------------------------------------------
# Validação das configurações obrigatórias e recomendadas
# ---------------------------------------------------------------------------
_claude_validate_required_config() {

    local warnings=0

    # --- CLAUDE_CODE_GIT_BASH_PATH -------------------------------------------
    # O Claude Code usa bash.exe para executar comandos no Windows.
    # Se não estiver definida, tenta auto-descobrir nas localizações conhecidas.
    if [[ -z "$CLAUDE_CODE_GIT_BASH_PATH" ]]; then
        local bash_candidates=(
            "/d/${USERNAME}/Apps/Git/bin/bash.exe"
            "/c/Users/${USERNAME}/AppData/Local/Programs/Git/bin/bash.exe"
            "/c/Program Files/Git/bin/bash.exe"
        )
        for candidate in "${bash_candidates[@]}"; do
            if [[ -f "$candidate" ]]; then
                export CLAUDE_CODE_GIT_BASH_PATH="$candidate"
                break
            fi
        done
        # Se ainda não encontrou, emite aviso
        if [[ -z "$CLAUDE_CODE_GIT_BASH_PATH" ]]; then
            displayFailure "Claude Code" "CLAUDE_CODE_GIT_BASH_PATH não definida → configure em: Variáveis de ambiente para sua conta (Windows)"
            (( warnings++ ))
        fi
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
    [[ -n "$ANTHROPIC_API_KEY" ]]     && has_auth=1
    [[ -n "$ANTHROPIC_AUTH_TOKEN" ]]  && has_auth=1
    [[ -n "$CLAUDE_CODE_USE_BEDROCK" ]] && has_auth=1
    [[ -n "$CLAUDE_CODE_USE_VERTEX" ]]  && has_auth=1

    # Verifica também se há credenciais OAuth já salvas em disco
    local oauth_creds="$CLAUDE_CODE_DIR/.credentials.json"
    [[ -f "$oauth_creds" ]] && has_auth=1

    if [[ "$has_auth" -eq 0 ]]; then
        displayWarning "Claude Code" "Nenhuma autenticação configurada."
        displayInfo    "Opções"      "ANTHROPIC_API_KEY (Console), ANTHROPIC_AUTH_TOKEN (Gateway), CLAUDE_CODE_USE_BEDROCK/VERTEX, ou login OAuth (execute: claude)"
        (( warnings++ ))
    fi

    # --- NODE_EXTRA_CA_CERTS -------------------------------------------------
    # Necessário apenas em ambientes corporativos com proxy de inspeção SSL
    # e quando o Claude Code foi instalado via npm (método legado).
    # O instalador nativo integra automaticamente a loja de certificados do SO.
    # Apenas informa se encontrar o arquivo mas a variável não estiver definida.
    local cert_file="${XDG_CONFIG_HOME:-$HOME/.config}/certs/ca_root.pem"
    if [[ -f "$cert_file" && -z "$NODE_EXTRA_CA_CERTS" ]]; then
        export NODE_EXTRA_CA_CERTS="$cert_file"
    fi

    # --- Diretório de configuração -------------------------------------------
    if [[ -n "$CLAUDE_CODE_DIR" && ! -d "$CLAUDE_CODE_DIR" ]]; then
        displayWarning "Claude Code" "Diretório de configuração não encontrado: $CLAUDE_CODE_DIR"
        displayInfo    "Criar com"   "mkdir -p \"$CLAUDE_CODE_DIR\""
        (( warnings++ ))
    fi

    # --- settings.json -------------------------------------------------------
    local global_settings="${CLAUDE_CODE_DIR}/settings.json"
    if [[ ! -f "$global_settings" ]]; then
        displayWarning "Claude Code" "settings.json não encontrado: $global_settings"
        displayInfo    "Criar com"   "touch \"$global_settings\""
        (( warnings++ ))
    fi

    # --- Resumo --------------------------------------------------------------
    if [[ "$warnings" -gt 0 ]]; then
        echo
        displayWarning "Claude Code" "📋 RESUMO: $warnings aviso(s) encontrado(s). Execute 'claude doctor' para diagnóstico completo."
    else
        displaySuccess "✓ INFO" "Claude Code: todas as configurações estão OK"
    fi
}

# Permite suprimir a validação para testes ou automação
if [[ "${CLAUDE_SKIP_VALIDATION:-0}" != "1" ]]; then
    _claude_validate_required_config
fi

# ---------------------------------------------------------------------------
# Limpar função auxiliar do escopo global (boa prática)
# ---------------------------------------------------------------------------
unset -f _claude_validate_required_config

#-------------------------------------------------------------------------------------------
#--- Final do script 31-claude-code-envs.sh
#-------------------------------------------------------------------------------------------
