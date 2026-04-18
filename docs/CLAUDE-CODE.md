# 🤖 Guia Completo: Claude Code no Bash RC for Devs

O **Claude Code** é uma ferramenta de linha de comando (CLI) desenvolvida pela Anthropic. Diferente de IDEs de copiloto, ele opera diretamente no terminal, atuando como um agente que permite interagir com a base de código, executar comandos, realizar testes, e realizar refatorações automatizadas.

Embora seja executado no terminal (como o Git Bash), o Claude Code pode ser perfeitamente usado através dos **terminais integrados** de IDEs como VS Code, PyCharm, IntelliJ, entre outras.

O propósito do **Bash RC for Devs** é definir variáveis de ambiente para o Git Bash for Windows. Mas devido à natureza do Claude Code, será necessário definir algumas variáveis de ambiente fora do escopo do **Bash RC for Devs**.

Este guia explica a hierarquia de configurações e oferece um passo-a-passo prático para configurar seu ambiente.

---

## 📊 1. Níveis e Hierarquia de Precedência

O Claude Code busca configurações em **seis camadas**. Se uma variável estiver definida em duas camadas, a de menor número (mais específica) vence:

| Nível | Escopo | Local | Precedência |
|-------|--------|-------|-------------|
| **1** | Comando | `claude --model claude-3-5-sonnet` | 🔴 Mais específica |
| **2** | Shell | `export` / `31-claude-code-envs.sh` | 🟠 |
| **3** | Projeto (Pessoal) | `PROJETO/.claude/settings.local.json` | 🟡 |
| **4** | Projeto (Compartilhado) | `PROJETO/.claude/settings.json` | 🟢 |
| **5** | Usuário (Global) | `%USERPROFILE%\.claude\settings.json` | 🔵 |
| **6** | Sistema | Windows Env Vars | 🟣 Mais genérica |

### Detalhamento de cada nível

#### 🔴 Nível 1: Flags na Linha de Comando
- **Onde:** Ao executar o Claude Code CLI diretamente na linha de comandos
- **Exemplo:** `claude --model claude-3-5-sonnet-20241022`
- **Uso:** Para testes específicos ou scripts de automação pontuais

#### 🟠 Nível 2: Variáveis de Ambiente do Shell
- **Onde:** Definidas via `export` no Bash ou via script `$HOME/.config/bash/31-claude-code-envs.sh`
- **Uso:** Configurações temporárias ou atalhos que afetam apenas a sessão terminal aberta
- **Este projeto fornece:** Script `31-claude-code-envs.sh` com validações automáticas

#### 🟡 Nível 3: Configurações Pessoais de Projeto
- **Onde:** `PROJETO/.claude/settings.local.json` na raiz do repositório
- **Uso:** Preferências pessoais do desenvolvedor que **não devem** ser versionadas (adicione ao `.gitignore`)
- **Exemplo:** Modelo preferido apenas para você naquele projeto

#### 🟢 Nível 4: Configurações de Projeto (Compartilhadas)
- **Onde:** `PROJETO/.claude/settings.json` na raiz do repositório
- **Uso:** Definições e configurações para a equipe inteira usar, garantindo consistência
- **Nota:** **Deve** ser versionada no Git
- **Exemplo:** Permissões e restrições de acesso para o agente

#### 🔵 Nível 5: Configurações Globais (Usuário)
- **Onde:** `%USERPROFILE%\.claude\settings.json`
- **Uso:** Preferências de interface, telemetria e modelos que valem para qualquer projeto em sua máquina
- **Exemplo:** Modelo padrão, desabilitação de telemetria

#### 🟣 Nível 6: Variáveis de Ambiente do Windows
- **Onde:** "Editar variáveis de ambiente para sua conta"
- **Uso:** Definições estruturais. **Local mais seguro para a `ANTHROPIC_API_KEY`**
- **Nota:** Garante que a chave esteja disponível para IDEs, PowerShell e Git Bash simultaneamente

---

## 🚀 2. Setup Rápido - Passo a Passo

### 2.1 Variáveis de Ambiente do Windows (Nível 6)

Abra **"Editar Variáveis de Ambiente para sua conta"** e adicione:

#### ⚠️ ANTHROPIC_API_KEY (CRÍTICA)
```
Nome:  ANTHROPIC_API_KEY
Valor: sk-proj-xxxxxxxxxxxx
```
**Sem isso, o Claude Code não funciona!**

[Como obter sua chave API](https://platform.claude.com/settings/keys)

#### CLAUDE_CODE_GIT_BASH_PATH (Opcional)
```
Nome:  CLAUDE_CODE_GIT_BASH_PATH
Valor: C:\Program Files\Git\bin\bash.exe
```
**Recomendação:** Deixe em branco para que o script auto-descubra (padrão)

#### NODE_EXTRA_CA_CERTS (Opcional)
Necessário apenas se você estiver atrás de um proxy corporativo com inspeção SSL:
```
Nome:  NODE_EXTRA_CA_CERTS
Valor: C:\path\to\your\corporate-certificate.pem
```

#### CLAUDE_CONFIG_DIR (Opcional)
Se desejar mover a pasta de configuração global para outro drive:
```
Nome:  CLAUDE_CONFIG_DIR
Valor: D:\.claude
```

---

### 2.2 Arquivo JSON Global (Nível 5)

Crie ou edite: **`%USERPROFILE%\.claude\settings.json`**

#### Passo 1: Criar pasta
```bash
mkdir "%USERPROFILE%\.claude"
```

#### Passo 2: Copiar template
Copie o conteúdo de [global-settings.json.example](../extras/claude/global-settings.json.example) ou use:

```json
{
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-6",
    "CLAUDE_CODE_DISABLE_TELEMETRY": "1",
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1"
  },
  "codeExecution": {
    "timeout": 30000,
    "maxOutputSize": 1000000
  }
}
```

#### Passo 3: Validar
O script `31-claude-code-envs.sh` verifica automaticamente se esse arquivo é válido.

---

### 2.3 Script Bash (Nível 2)

Este projeto fornece: **`src/home/.config/bash/31-claude-code-envs.sh`**

#### O que faz:
✅ Exporta atalhos (`alias c="claude"`)  
✅ Auto-descobre `CLAUDE_CODE_GIT_BASH_PATH`  
✅ Configura `CLAUDE_CONFIG_DIR` com padrão XDG  
✅ Valida configurações automaticamente  
✅ Mostra **warnings** se algo estiver faltando  

#### Como usar:
Certifique-se de que este script é sourced em seu `~/.bashrc`:

```bash
# Adicione esta linha em ~/.bashrc:
source ~/.config/bash/31-claude-code-envs.sh
```

---

### 2.4 Configuração de Projeto (Nível 4 - Opcional)

Se você quer controlar permissões do Claude Code por projeto:

#### Passo 1: Criar pasta
```bash
mkdir -p PROJETO/.claude
```

#### Passo 2: Criar arquivo
Crie **`.claude/settings.json`** na raiz do seu repositório Git:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(npm test)",
      "Bash(bash src/**)",
      "Read(./src/**)",
      "Read(./docs/**)"
    ],
    "deny": [
      "Read(.env)",
      "Read(./secrets/**)",
      "Bash(rm -rf *)",
      "Bash(sudo *)"
    ]
  },
  "instructions": {
    "projectDescription": "My Project: Short description",
    "codeStyle": "Use project conventions and best practices",
    "preferredLanguages": ["javascript", "json", "markdown"]
  }
}
```

Veja template completo em [project-settings.json.example](../extras/claude/project-settings.json.example)

#### Passo 3: Versionamento
Adicione ao Git (diferente do `.local.json`):
```bash
git add .claude/settings.json
git commit -m "Add Claude Code project settings"
```

---

## ✅ 3. Validação

Quando você abre um novo Git Bash, o script `31-claude-code-envs.sh` **automaticamente valida** suas configurações.

### Se tudo está OK:
```
[ℹ INFO]: Global Settings JSON: válido (OK)
[ℹ INFO]: Validação: OK - Todas as configurações estão corretas
```

### Se algo está faltando:
```
[⚠️ WARN]: ANTHROPIC_API_KEY → Configure em: Windows Env Vars (...)
[⚠️ WARN]: Global Settings JSON → Configure em: %USERPROFILE%\.claude\settings.json (...)

📋 RESUMO: 2 aviso(s) encontrado(s).
```

---

## 🛠️ 4. Troubleshooting

### ❓ Suprimir warnings (para testes)
```bash
CLAUDE_SKIP_VALIDATION=1 bash
```

### ❓ Ver informações detalhadas de validação
```bash
CLAUDE_DEBUG=1 bash
```

### ❓ Verificar se ANTHROPIC_API_KEY está setada
```bash
echo $ANTHROPIC_API_KEY
```

### ❓ Listar todas as variáveis do Claude Code
```bash
env | grep CLAUDE
```

### ❓ Testar se o Claude Code CLI funciona
```bash
c --version
```

### ❓ JSON inválido em configurações
O script valida automaticamente. Se receber erro:
```bash
# Verificar sintaxe JSON (requer python)
python -m json.tool ~/.claude/settings.json
```

---

## 📋 5. Referência de Caminhos

| Configuração | Caminho / Local | Nível | Escopo |
|---|---|---|---|
| **API Key** | Windows Env Vars | 6 | Sistema |
| **Git Bash Path** | Windows Env Vars | 6 | Sistema |
| **Global Settings** | `%USERPROFILE%\.claude\settings.json` | 5 | Usuário |
| **Project Settings** | `<PROJETO>/.claude/settings.json` | 4 | Projeto (Git) |
| **Personal Settings** | `<PROJETO>/.claude/settings.local.json` | 3 | Projeto (Pessoal) |
| **Shell Exports** | `$HOME/.config/bash/31-claude-code-envs.sh` | 2 | Terminal |
| **CLI Flags** | `claude --model xxx` | 1 | Comando |

---

## 🔍 6. Resumo de Configurações Recomendadas

### Para Todos (Obrigatório)
- ✅ `ANTHROPIC_API_KEY` em Windows Env Vars

### Para Desenvolvimento Ideal
- ✅ `%USERPROFILE%\.claude\settings.json` com preferências globais
- ✅ `31-claude-code-envs.sh` sourced em `~/.bashrc`

### Para Projetos em Equipe
- ✅ `.claude/settings.json` na raiz do projeto com permissões e restrições

### Para Cenários Especiais
- ✅ `CLAUDE_CODE_GIT_BASH_PATH` se auto-descoberta falhar
- ✅ `NODE_EXTRA_CA_CERTS` se atrás de proxy corporativo
- ✅ `.claude/settings.local.json` para preferências pessoais não versionadas

---

**Status**: ✅ Pronto para uso
**Última atualização**: 2026-04-17
