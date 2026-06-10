#
# Script: ~/.config/bashrc/claude-code-cert.sh
# Gerencia o certificado raiz CA para uso do Claude Code em ambientes corporativos.
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
# Depende de funções definidas em 00-bash-functions.sh
# ==========================================================================================

cert_dir="${XDG_CONFIG_HOME:-$HOME/.config}/certs"
cert_file="$cert_dir/ca_root.pem"
cert_tmp="$cert_dir/ca_root.pem.new"

mkdir -p "$cert_dir"

# Baixa o certificado raiz negociado com google.com:443
# A lógica extrai apenas o ÚLTIMO certificado da cadeia (o certificado raiz CA)
printf "Q" \
| openssl s_client -showcerts -connect google.com:443 -timeout 10 2>/dev/null \
| awk '/BEGIN CERTIFICATE/{cert=""; inside=1} inside{cert=cert $0 "\n"} /END CERTIFICATE/{last_cert=cert; inside=0} END{printf "%s", last_cert}' \
> "$cert_tmp"

# Verifica se o arquivo temporário contém um certificado válido
if ! openssl x509 -in "$cert_tmp" -noout 2>/dev/null; then
    displayFailure "Certificado raiz" "Não foi possível obter certificado - verifique a conectividade"
    rm -f "$cert_tmp"
    return 1 2>/dev/null || exit 1
fi

# Atualiza o arquivo de certificado
mv "$cert_tmp" "$cert_file"

# Exporta para o Claude Code (apenas quando instalado via npm/Node.js)
# O instalador nativo usa a loja de certificados do Windows automaticamente.
export NODE_EXTRA_CA_CERTS="$cert_file"
export SSL_CERT_FILE="$cert_file"

#-------------------------------------------------------------------------------------------
#--- Final do script 31-claude-code-cert.sh
#-------------------------------------------------------------------------------------------
