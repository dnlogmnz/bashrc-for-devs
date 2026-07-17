#
# Projeto: bashrc-for-devs
#
# Script: ~/.config/bashrc/node-extra-certs.sh
# Gerencia o certificado raiz CA para uso de ferramentas baseadas em Node.js
# (incluindo Claude Code instalado via npm) em ambientes corporativos.
#
# QUANDO ESTE SCRIPT É NECESSÁRIO:
#   - Você está em rede corporativa com proxy de inspeção SSL (ex.: Zscaler, CrowdStrike)
#   - E está recebendo erros "Self-signed certificate" ou "SSL certificate problem"
#
# QUANDO NÃO É NECESSÁRIO:
#   - Instalação nativa do Claude Code (recomendada): integra automaticamente
#     a loja de certificados do Windows — sem configuração extra.
#   - Assinantes Pro/Max em rede doméstica ou corporativa sem inspeção SSL.
#
# ==========================================================================================

cert_dir="${XDG_CONFIG_HOME:-$HOME/.config}/certs"
cert_file="$cert_dir/ca_root.pem"
cert_stamp="$cert_dir/ca_root.stamp"

# Cache: só renovar o certificado se ele não existe ou tem mais de 7 dias.
# Evita chamada de rede (openssl s_client) em todo shell novo.
# Comparação via stamp de epoch (builtins, sem fork) — substitui "find -mtime" (fork em todo shell).
printf -v _cert_now '%(%s)T' -1
_cert_stamp=0
[ -f "$cert_stamp" ] && _cert_stamp="$(< "$cert_stamp")"
if [ ! -f "$cert_file" ] || (( _cert_now - _cert_stamp > 7*86400 )); then
    cert_tmp="$cert_file.new"
    [ -d "$cert_dir" ] || mkdir -p "$cert_dir"

    # Baixa o certificado raiz negociado com google.com:443
    # A lógica extrai apenas o ÚLTIMO certificado da cadeia (o certificado raiz CA)
    printf "Q" \
    | openssl s_client -showcerts -timeout -connect google.com:443 2>/dev/null \
    | awk '/BEGIN CERTIFICATE/{cert=""; inside=1} inside{cert=cert $0 "\n"} /END CERTIFICATE/{last_cert=cert; inside=0} END{printf "%s", last_cert}' \
    > "$cert_tmp"

    # Atualiza o arquivo de certificado se o download foi bem-sucedido;
    # caso contrário, descarta o tmp e mantém o cert anterior (se existir).
    if openssl x509 -in "$cert_tmp" -noout 2>/dev/null; then
        mv "$cert_tmp" "$cert_file"
        printf '%s' "$_cert_now" > "$cert_stamp"
    else
        displayFailure "Certificado raiz" "Não foi possível obter certificado - verifique a conectividade"
        rm -f "$cert_tmp"
    fi
fi
unset _cert_now _cert_stamp cert_stamp

# Exporta para o Claude Code (apenas quando instalado via npm/Node.js)
# O instalador nativo usa a loja de certificados do Windows automaticamente.
if [ -f "$cert_file" ]; then
    export NODE_EXTRA_CA_CERTS="$cert_file"
    export SSL_CERT_FILE="$cert_file"
fi

#-------------------------------------------------------------------------------------------
#--- Final do script node-extra-certs.sh
#-------------------------------------------------------------------------------------------
