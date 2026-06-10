#
# Script: ~/.config/bashrc/00-bash-junctions.sh
# Cria junctions em %USERPROFILE% apontando para pastas dotfile reais em $HOME.
# =============================================================================

# Normalizar o caminho do USERPROFILE para notação Linux/Unix
_usr_profile="$(cygpath -u "$USERPROFILE")"

# TBD: mover a definição de CLAUDE_CONFIG_DIR para 31-claude-code-envs.sh, mas garantir que seja definida antes de criar a junction .claude
: "${CLAUDE_CONFIG_DIR:=$HOME/.local/claude}"

# Definir $HOME: mantém se diferente do USERPROFILE padrão, senão tenta D:\%USERNAME%\home
_resolve_home() {
    if   [ "$HOME" != "$_usr_profile" ];  then echo "$HOME"
    elif [ -d "/d/$USERNAME/home" ];      then echo "/d/$USERNAME/home"
    else                                  echo "$_usr_profile"
    fi
}
export HOME="$(_resolve_home)"

# Garantir $USERPROFILE/.local/bin no PATH
mkdir -p "$_usr_profile/.local/bin"
if [[ ":$PATH:" != *":$_usr_profile/.local/bin:"* ]]; then
    displayFailure "Windows" "Variáveis de ambiente para sua conta: adicionar \"$(cygpath -w "$_usr_profile/.local/bin")\" ao PATH"
    export PATH="$_usr_profile/.local/bin:$PATH"
fi

# Criar junctions em subshell
ensure_junction() {
    local src="$_usr_profile/$1" tgt="$2"
    mkdir -p "$tgt"
    [ -L "$src" ] && return 0 # Já é uma junction, presumivelmente correta

    # Se a origem existe mas não é uma junction, exibir mensagem de falha e instruções para o usuário
    if [ -e "$src" ]; then
        displayFailure "Windows"      "Remover diretório ou arquivo '$(cygpath -w "$src")'"
        displayInfo    "Por que?"     "Em USERPROFILE, esse path deve ser uma JUNCTION no Windows"
        displayInfo    "O que é?"     "$(stat -c '%F' "$src" 2>/dev/null || echo 'desconhecido')"
        displayInfo    "O que fazer?" "Após remover manualmente, reinicie a sessão"
        displayInfo    "Sugestão"     "Combine o conteúdo com '$(cygpath -w "$tgt")' antes de remover"
        echo
    else
        local src_w tgt_w
        src_w="$(cygpath -w "$src")"
        tgt_w="$(cygpath -w "$tgt")"
        
        # Tentar criar a junction; se falhar, capturar e exibir o erro
        cmd //c mklink //J "$src_w" "$tgt_w" >NUL: 2>&1
        if [ $? -eq 0 ]; then
            displaySuccess "Windows" "Junção criada: $src_w <<===>> $tgt_w"
        else
            local err
            err="$(MSYS_NO_PATHCONV=1 cmd //c "mklink /J \"$src_w\" \"$tgt_w\"" 2>&1 | sed 's/\r$//' | grep -av '^$' | head -1)"
            displayFailure "Windows" "Erro ao criar junção para '$src_w': ${err:-comando falhou}"
        fi
    fi
}

# Pastas dotfile mantidas como diretórios reais em $HOME; junctions em %USERPROFILE%
ensure_junction ".aws"    "$HOME/.aws"
ensure_junction ".cache"  "$XDG_CACHE_HOME"
ensure_junction ".certs"  "$XDG_CONFIG_HOME/certs"
ensure_junction ".claude" "$CLAUDE_CONFIG_DIR"
ensure_junction ".config" "$XDG_CONFIG_HOME"
ensure_junction ".local"  "$HOME/.local"
ensure_junction ".ssh"    "$HOME/.ssh"

# Limpa variáveis do escopo global
unset _usr_profile
unset -f _resolve_home
unset -f ensure_junction

#-------------------------------------------------------------------------------------------
#--- Final do script 00-bash-junctions.sh
#-------------------------------------------------------------------------------------------