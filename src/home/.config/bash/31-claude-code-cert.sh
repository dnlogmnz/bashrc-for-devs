#
# Script: ~/.config/bash/31-claude-code-cert.sh
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
| openssl s_client -showcerts -connect google.com:443 2>/dev/null \
| awk '/BEGIN CERTIFICATE/{cert=""; inside=1} inside{cert=cert $0 "\n"} /END CERTIFICATE/{last_cert=cert; inside=0} END{printf "%s", last_cert}' \
> "$cert_tmp"

# Verifica se o arquivo temporário contém um certificado válido
if ! openssl x509 -in "$cert_tmp" -noout 2>/dev/null; then
    displayFailure "Certificado raiz" "Não foi possível obter certificado de google.com:443 — verifique a conectividade"
    rm -f "$cert_tmp"
    return 1 2>/dev/null || exit 1
fi

# Calcula fingerprint SHA256 do novo certificado
new_fp=$(openssl x509 -in "$cert_tmp" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//; s/://g')

# Calcula fingerprint do certificado existente (se houver)
old_fp=""
if [[ -f "$cert_file" ]]; then
    old_fp=$(openssl x509 -in "$cert_file" -noout -fingerprint -sha256 2>/dev/null | sed 's/.*=//; s/://g')
fi

# Atualiza o arquivo apenas se não existir ou se o fingerprint mudou
if [[ ! -f "$cert_file" ]] || [[ "$new_fp" != "$old_fp" ]]; then
    mv "$cert_tmp" "$cert_file"
    displaySuccess "Certificado raiz" "Atualizado: $cert_file"
else
    rm -f "$cert_tmp"
    # Sem mensagem quando o certificado está atualizado (evita ruído no terminal)
fi

# Avisa se o certificado está prestes a expirar (< 7 dias = 604800 segundos)
if ! openssl x509 -in "$cert_file" -checkend 604800 >/dev/null 2>&1; then
    exp_date=$(openssl x509 -in "$cert_file" -noout -enddate 2>/dev/null | sed 's/notAfter=//')
    displayWarning "Certificado raiz" "Irá expirar nos próximos 7 dias (data: $exp_date — será atualizado automaticamente na próxima sessão)"
fi

# Exporta para o Claude Code (apenas quando instalado via npm/Node.js)
# O instalador nativo usa a loja de certificados do Windows automaticamente.
export NODE_EXTRA_CA_CERTS="$cert_file"
export SSL_CERT_FILE="$cert_file"

#-------------------------------------------------------------------------------------------
#--- Final do script 31-claude-code-cert.sh
#-------------------------------------------------------------------------------------------
