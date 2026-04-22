# ![Claude Code](./claude-code.ico) **Claude Code** no Bash RC for Devs
## Configuração, Instalação e Referência de Variáveis de Ambiente

> **Última atualização:** abril/2026  
> **Público:** Desenvolvedores Windows 11 com Git Bash configurado no padrão XDG

---

## Introdução

O **Claude Code** é uma ferramenta de linha de comando (CLI) da Anthropic que age como agente autônomo diretamente no seu projeto: lê a estrutura de diretórios, analisa arquivos de código, cria e edita código, executa comandos de shell, realiza testes e gerencia fluxos de git. A extensão para VS Code é uma interface gráfica que invoca internamente o mesmo binário CLI — não o substitui.

O **Claude Code** pode ser usado com diferentes provedores de LLM:

- **Anthropic (direta):** requer assinatura de um plano pago (Pro, Max, Team ou Enterprise) ou uma API Key do Console da Anthropic.
- **Amazon Bedrock:** autenticação via credenciais AWS (não usa `ANTHROPIC_API_KEY`).
- **Google Cloud Vertex AI:** autenticação via credenciais GCP (não usa `ANTHROPIC_API_KEY`).
- **AI Gateway (ex.: LiteLLM):** autenticação via token do Gateway (variável `ANTHROPIC_AUTH_TOKEN`).

> **Sobre modelos de outros provedores:** O **Claude Code** foi projetado especificamente para trabalhar com modelos Claude. Embora tecnicamente seja possível apontar um gateway (como LiteLLM) para modelos de outros fabricantes (ex.: `gemini-2.5-pro`), isso **não é suportado oficialmente** pela Anthropic. Funcionalidades como ferramentas agênticas, prompt caching e alguns comandos internos dependem de comportamentos específicos dos modelos Claude e podem apresentar erros imprevisíveis com outros modelos. Recomenda-se fortemente usar apenas modelos Claude.

Este documento descreve em sequência todo o processo de configuração e instalação para o ambiente **Windows 11 com Git Bash**.

---

## Parte 1 — Entender antes de configurar

### 1.1 Hierarquia de precedência das configurações

O **Claude Code** busca configurações em camadas. Quando a mesma variável está definida em duas camadas, a de **menor número** (mais específica) vence:

| Nível | Escopo | Onde fica |
|:---:|---|---|
| **1** | Linha de comando | `claude --model claude-sonnet-4-6` |
| **2** | Shell (sessão) | `export` / `31-claude-code-envs.sh` |
| **3** | Projeto — pessoal | `PROJETO/.claude/settings.local.json` |
| **4** | Projeto — equipe | `PROJETO/.claude/settings.json` |
| **5** | Usuário (global) | `$HOME/.config/claude/settings.json` *(padrão XDG)* |
| **6** | Sistema (Windows) | "Editar variáveis de ambiente para sua conta" |

> **Nota XDG:** O **Bash RC for Devs** adota o padrão XDG, portanto o diretório global do Claude Code é `$HOME/.config/claude` (em vez do padrão `%USERPROFILE%\.claude` usado pela maioria das instalações sem XDG). Para isso, a variável `CLAUDE_CODE_DIR` **deve** ser definida apontando para esse diretório, conforme explicado na seção 2.1.

### 1.2 Autenticação: `ANTHROPIC_API_KEY` vs. `ANTHROPIC_AUTH_TOKEN`

Estas duas variáveis têm comportamentos **diferentes** e são mutuamente exclusivas na prática:

| Variável | Quando usar | Como é enviada |
|---|---|---|
| `ANTHROPIC_API_KEY` | Acesso direto à API da Anthropic (Console) | Header `X-Api-Key` |
| `ANTHROPIC_AUTH_TOKEN` | AI Gateway / LiteLLM (qualquer provedor não-Anthropic) | Header `Authorization: Bearer <valor>` |

**Regra importante:** Quando `ANTHROPIC_API_KEY` está definida, o Claude Code **desabilita** o fluxo OAuth (login via browser com sua conta claude.ai). Se você assina o plano Pro/Max e quer usar a sua assinatura (sem API Key separada), **não defina** `ANTHROPIC_API_KEY` — deixe o Claude Code fazer o login OAuth normalmente.

| Provedor | Variável de autenticação recomendada |
|---|---|
| **Anthropic (assinatura Pro/Max/Team)** | Nenhuma — use o login OAuth (`claude` → browser) |
| **Anthropic (API Key do Console)** | `ANTHROPIC_API_KEY` |
| **AI Gateway / LiteLLM** | `ANTHROPIC_AUTH_TOKEN` |
| **Amazon Bedrock** | Credenciais AWS (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, etc.) |
| **Google Vertex AI** | Credenciais GCP (`GOOGLE_APPLICATION_CREDENTIALS`, etc.) |

### 1.3 Sobre certificados SSL corporativos

O binário nativo do **Claude Code** integra automaticamente a loja de certificados do sistema operacional. Na maioria dos ambientes corporativos com proxy SSL, isso é suficiente — **sem necessidade de configuração adicional**.

A variável `NODE_EXTRA_CA_CERTS` é necessária apenas quando o Claude Code foi instalado via `npm` (método legado) **ou** quando o proxy corporativo usa uma CA raiz não presente na loja do Windows. O script `31-claude-code-cert.sh` do **Bash RC for Devs** automatiza esse processo para quem precisar.

> **Para assinantes Claude Pro sem proxy corporativo:** você provavelmente não precisa configurar `NODE_EXTRA_CA_CERTS`.

---

## Parte 2 — Configurações antes da instalação

Execute os passos desta seção **na ordem indicada**, antes de instalar o Claude Code.

### 2.1 Definir `CLAUDE_CODE_DIR` (obrigatório para padrão XDG)

O **Bash RC for Devs** usa XDG, então o diretório de configuração global do Claude Code **não** é o padrão `%USERPROFILE%\.claude`. É necessário informar ao Claude Code onde procurar suas configurações.

Abra **"Editar as variáveis de ambiente para sua conta"** e adicione:

| Nome | Valor |
|---|---|
| `CLAUDE_CODE_DIR` | `C:\Users\%USERNAME%\.config\claude` |

> **Por que variável de ambiente do Windows e não `settings.json`?** O Claude Code lê `CLAUDE_CODE_DIR` **antes** de abrir qualquer arquivo de configuração, então ela precisa estar disponível no nível do sistema operacional.

### 2.2 Definir `CLAUDE_CODE_GIT_BASH_PATH` (obrigatório)

O Claude Code usa `bash.exe` internamente para executar comandos. Você deve informar a localização exata.

Abra um Git Bash e execute:
```bash
where bash
```

O resultado será o caminho do `bash.exe`. No seu caso (instalação em `D:\%USERNAME%\Apps\Git`):
```
D:\%USERNAME%\Apps\Git\bin\bash.exe
```

Abra **"Editar as variáveis de ambiente para sua conta"** e adicione:

| Nome | Valor |
|---|---|
| `CLAUDE_CODE_GIT_BASH_PATH` | `D:\%USERNAME%\Apps\Git\bin\bash.exe` |

> **Atenção:** use o caminho real retornado pelo `where bash`, que pode diferir dependendo de como o Git for Windows foi instalado.

### 2.3 Criar o diretório e o `settings.json` global (Nível 5)

Abra um Git Bash e execute:
```bash
mkdir -p "$HOME/.config/claude"
touch "$HOME/.config/claude/settings.json"
```

Edite o arquivo `$HOME/.config/claude/settings.json` com o conteúdo adequado ao seu caso de uso. Veja os templates na seção 2.4.

### 2.4 Templates do `settings.json` global por caso de uso

#### Template A — Anthropic direto (assinatura Pro/Max)

Para quem usa a **própria assinatura** do claude.ai. Sem API Key, sem token.

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

> Após instalar, execute `claude` e faça login via browser com sua conta claude.ai.

#### Template B — Anthropic via API Key (Console da Anthropic)

Para quem tem uma API Key gerada em [platform.claude.com](https://platform.claude.com/settings/keys):

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_API_KEY": "sk-ant-xxxxxxxxxxxxxxxx",
    "CLAUDE_CODE_DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  }
}
```

#### Template C — AI Gateway / LiteLLM

Para quem acessa modelos Claude via um proxy como LiteLLM (ou qualquer gateway compatível com a API da Anthropic):

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "ANTHROPIC_AUTH_TOKEN": "sk-litellm-xxxxxxxxxx",
    "ANTHROPIC_BASE_URL": "https://seu-gateway.empresa.com",
    "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet-4-6",
    "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku-4-5",
    "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-sonnet-4-6",
    "CLAUDE_CODE_DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  }
}
```

> **Sobre `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS`:** O Claude Code envia automaticamente headers `anthropic-beta` com funcionalidades experimentais. Gateways e provedores terceiros frequentemente rejeitam esses headers com erro `"Unexpected value(s) for the anthropic-beta header"`. Definir `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS=1` resolve esse problema.

#### Template D — Amazon Bedrock

Para quem acessa Claude via AWS Bedrock. A autenticação é feita via credenciais AWS padrão:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_USE_BEDROCK": "1",
    "AWS_REGION": "us-east-1",
    "AWS_PROFILE": "seu-perfil-aws",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  }
}
```

> **Nota:** O login interativo via `claude` também funciona — selecione "3rd-party platform" → "Amazon Bedrock" e o assistente de configuração guia o restante. Consulte [docs.claude.com/en/docs/claude-code/amazon-bedrock](https://code.claude.com/docs/en/amazon-bedrock) para configuração completa de IAM e modelos.

#### Template E — Google Cloud Vertex AI

Para quem acessa Claude via GCP Vertex AI:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "env": {
    "CLAUDE_CODE_USE_VERTEX": "1",
    "CLOUD_ML_REGION": "us-east5",
    "ANTHROPIC_VERTEX_PROJECT_ID": "seu-projeto-gcp",
    "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"
  }
}
```

> **Nota:** O login interativo via `claude` também funciona (requer Claude Code v2.1.98+) — selecione "3rd-party platform" → "Google Vertex AI". Consulte [code.claude.com/docs/en/google-vertex-ai](https://code.claude.com/docs/en/google-vertex-ai) para configuração completa de IAM e modelos.

### 2.5 Confirmar instalação do Node.js (apenas para método npm legado)

> **Se você vai usar o instalador nativo (recomendado pela Anthropic desde 2026), o Node.js não é necessário.** Esta etapa é obrigatória apenas se optar pelo método `npm install -g`.

Abra um Git Bash e execute:
```bash
node -v
```

O resultado deve ser `v18.0.0` ou superior (ex.: `v22.13.0`).

### 2.6 Certificado SSL corporativo — apenas se necessário

Se você trabalha em ambiente corporativo com **proxy de inspeção SSL** e está recebendo erros de SSL ao usar o Claude Code, siga estas etapas:

Abra um Git Bash. O script `31-claude-code-cert.sh` do **Bash RC for Devs** baixa automaticamente o certificado raiz. Para verificar se o arquivo foi criado:
```bash
ls -la "$HOME/.config/certs/ca_root.pem"
openssl x509 -in "$HOME/.config/certs/ca_root.pem" -noout -subject -issuer
```

Em seguida, adicione ao `settings.json` global:
```json
"NODE_EXTRA_CA_CERTS": "C:\\Users\\%USERNAME%\\.config\\certs\\ca_root.pem"
```

Ou defina nas variáveis de ambiente do Windows:

| Nome | Valor |
|---|---|
| `NODE_EXTRA_CA_CERTS` | `C:\Users\%USERNAME%\.config\certs\ca_root.pem` |

---

## Parte 3 — Instalação

### 3.1 Instalar o Claude Code CLI (método nativo recomendado)

Abra um **PowerShell** (não precisa de Administrador) e execute:

```powershell
irm https://claude.ai/install.ps1 | iex
```

O instalador baixa o binário nativo, o coloca em `%USERPROFILE%\.local\bin\claude.exe` e configura atualização automática em segundo plano.

> **Por que não usar `npm install -g`?** O método npm é considerado legado pela Anthropic desde o início de 2026. O instalador nativo não depende do Node.js, é mais rápido, se atualiza automaticamente e é o método primário testado e suportado pela Anthropic.

Feche o PowerShell e abra um novo **Git Bash** para que o PATH seja atualizado.

Verifique a instalação:
```bash
claude --version
claude doctor
```

### 3.2 Realizar o primeiro login

O próximo passo depende do seu provedor:

**Anthropic (assinatura Pro/Max):** execute `claude` — o browser abre automaticamente para login OAuth com sua conta claude.ai.

**Anthropic (API Key):** se `ANTHROPIC_API_KEY` está definida no `settings.json`, o login OAuth é ignorado. O CLI conecta diretamente.

**AI Gateway / LiteLLM:** se `ANTHROPIC_AUTH_TOKEN` e `ANTHROPIC_BASE_URL` estão definidos, nenhum login interativo é necessário.

**Bedrock / Vertex AI:** execute `claude`, selecione "3rd-party platform" e siga o assistente, **ou** configure as variáveis de ambiente conforme os templates D e E.

### 3.3 Validar a configuração

Após o login, execute:
```bash
claude /status
```

Confirme que:
- O campo **"API Provider"** mostra o endpoint correto (gateway, Bedrock ou `api.anthropic.com`).
- O modelo exibido é o esperado.

Para um teste rápido de funcionamento:
```bash
claude ping
```

### 3.4 Instalar a extensão para VS Code

No VS Code, abra a aba de Extensões (`Ctrl+Shift+X`) e pesquise:
```
publisher:Anthropic "Claude Code"
```

Instale a extensão. Ela usa automaticamente o binário CLI já instalado e as configurações já definidas.

**Configurações opcionais do VS Code** (`Ctrl+Shift+P` → "User Settings (JSON)"):
```json
{
  "claudeCode.preferredLocation": "panel",
  "claudeCode.disableLoginPrompt": true
}
```

> Para usuários de AI Gateway ou Bedrock que precisam forçar variáveis de ambiente específicas na extensão (que não herda todas as variáveis do shell), adicione:
> ```json
> "claudeCode.environmentVariables": [
>   { "name": "ANTHROPIC_AUTH_TOKEN", "value": "sk-litellm-xxxxxxxxxx" },
>   { "name": "ANTHROPIC_BASE_URL", "value": "https://seu-gateway.empresa.com" },
>   { "name": "CLAUDE_CODE_GIT_BASH_PATH", "value": "D:\\%USERNAME%\\Apps\\Git\\bin\\bash.exe" }
> ]
> ```

---

## Parte 4 — Configuração de projeto (opcional)

Para controlar permissões e comportamento do Claude Code em projetos de equipe, crie o arquivo `.claude/settings.json` na raiz do repositório:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "deny": [
      "Edit(.env)",
      "Read(.git/**)",
      "Read(**/node_modules/**)",
      "Read(./build/**)",
      "Read(./dist/**)",
      "Read(**/*.pem)",
      "Read(**/*.key)"
    ]
  }
}
```

> **Versionar no git:** este arquivo deve ser commitado. Para preferências pessoais que não devem ser compartilhadas, use `.claude/settings.local.json` e adicione-o ao `.gitignore`.

---

## Parte 5 — Desinstalação

### CLI
```bash
rm "$USERPROFILE/.local/bin/claude.exe"
rm -rf "$USERPROFILE/.claude"
rm -f "$USERPROFILE/.claude.json"
```

### Extensão VS Code
Vá à aba Extensões, selecione "Claude Code" e clique em "Uninstall". Em seguida, remova as entradas do `settings.json` do VS Code.

### Variáveis de ambiente do Windows
Abra "Editar as variáveis de ambiente para sua conta" e remova:
- `CLAUDE_CODE_DIR`
- `CLAUDE_CODE_GIT_BASH_PATH`
- `NODE_EXTRA_CA_CERTS` (se não for usada por outras ferramentas)

---

## Parte 6 — Referência rápida

### 6.1 Caminhos no Windows (instalação nativa)

| Item | Caminho |
|---|---|
| Binário | `%USERPROFILE%\.local\bin\claude.exe` |
| Settings global (XDG) | `%USERPROFILE%\.config\claude\settings.json` |
| Credenciais OAuth | `%USERPROFILE%\.claude\.credentials.json` |
| Preferências da UI | `%USERPROFILE%\.claude.json` |

### 6.2 Variáveis de ambiente essenciais

| Variável | Finalidade |
|---|---|
| `CLAUDE_CODE_DIR` | Diretório de configuração global (obrigatório no padrão XDG) |
| `CLAUDE_CODE_GIT_BASH_PATH` | Localização do `bash.exe` no Windows |
| `ANTHROPIC_API_KEY` | Chave de API do Console da Anthropic |
| `ANTHROPIC_AUTH_TOKEN` | Token de autenticação para AI Gateway / LiteLLM |
| `ANTHROPIC_BASE_URL` | URL do gateway ou proxy (quando não for a Anthropic direto) |
| `CLAUDE_CODE_USE_BEDROCK` | Habilitar integração com AWS Bedrock (`1`) |
| `CLAUDE_CODE_USE_VERTEX` | Habilitar integração com GCP Vertex AI (`1`) |
| `ANTHROPIC_VERTEX_PROJECT_ID` | ID do projeto GCP para Vertex AI |
| `CLOUD_ML_REGION` | Região GCP para Vertex AI |
| `AWS_REGION` | Região AWS para Bedrock |
| `ANTHROPIC_DEFAULT_SONNET_MODEL` | Sobrescrever o modelo Sonnet padrão |
| `ANTHROPIC_DEFAULT_HAIKU_MODEL` | Sobrescrever o modelo Haiku padrão |
| `ANTHROPIC_DEFAULT_OPUS_MODEL` | Sobrescrever o modelo Opus padrão (útil para redirecionar para Sonnet) |
| `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` | Desabilitar headers beta (essencial para gateways/Bedrock/Vertex) |
| `CLAUDE_CODE_DISABLE_TELEMETRY` | Desabilitar telemetria |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | Desabilitar tráfego não-essencial |
| `NODE_EXTRA_CA_CERTS` | Certificado CA raiz para ambientes corporativos com proxy SSL |

> Referência completa: [code.claude.com/docs/en/env-vars](https://code.claude.com/docs/en/env-vars)

### 6.3 Comandos úteis

```bash
claude --version          # verificar versão instalada
claude doctor             # diagnóstico completo do ambiente
claude /status            # mostrar provedor e modelo em uso
claude ping               # testar conectividade com o LLM
claude update             # atualizar para a versão mais recente
claude /model             # selecionar modelo interativamente
```

### 6.4 Troubleshooting

**Suprimir validações do script Bash RC for Devs (para testes):**
```bash
CLAUDE_SKIP_VALIDATION=1 bash
```

**Ver diagnóstico detalhado:**
```bash
CLAUDE_DEBUG=1 bash
```

**Verificar variáveis carregadas:**
```bash
env | grep -E "CLAUDE|ANTHROPIC|NODE_EXTRA"
```

**Erro "Unexpected value(s) for the anthropic-beta header":**
Adicione ao `settings.json`: `"CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1"`

**Erro de SSL em ambiente corporativo:**
Configure `NODE_EXTRA_CA_CERTS` apontando para o arquivo `.pem` do certificado raiz da empresa.

**Claude Code não encontra o Git Bash:**
Verifique se `CLAUDE_CODE_GIT_BASH_PATH` aponta para o `bash.exe` correto com `where bash` no Git Bash.

---

## Anexo — Fontes

- [Claude Code Docs — Quickstart](https://code.claude.com/docs/en/quickstart)
- [Claude Code Docs — Advanced Setup](https://code.claude.com/docs/en/setup)
- [Claude Code Docs — Environment Variables](https://code.claude.com/docs/en/env-vars)
- [Claude Code Docs — Settings](https://code.claude.com/docs/en/settings)
- [Claude Code Docs — Authentication](https://code.claude.com/docs/en/authentication)
- [Claude Code Docs — Amazon Bedrock](https://code.claude.com/docs/en/amazon-bedrock)
- [Claude Code Docs — Google Vertex AI](https://code.claude.com/docs/en/google-vertex-ai)
- [Claude Code Docs — LLM Gateway](https://code.claude.com/docs/en/llm-gateway)
- [Claude Code Docs — Network Configuration](https://code.claude.com/docs/en/network-config)
- [Planos de Assinatura do Claude Code](https://support.claude.com/en/articles/11049762-choosing-a-claude-plan)
