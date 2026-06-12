# Scripts de Inicialização (RC) para Bash

Este repositório oferece uma coleção modular de scripts Bash projetados para configurar e otimizar o ambiente de desenvolvimento local, garantindo uma estrutura robusta, organizada e compatível com os padrões modernos de sistemas Unix-like e Git Bash.

## 🎯 Objetivo do Projeto

Um desenvolvedor de aplicações utiliza diversos ecossistemas que exigem variáveis de ambiente e configurações específicas no terminal `bash`. Seguem alguns exemplos de ferramentas comuns:

  * **Runtimes e Linters**: você pode desenvolver aplicações usando `node`, ou então `python` (e com este último, você pode também querer usar `uv` e `ruff`).

  * **Cloud CLIs**: `aws.exe` (AWS CLI v2), `az.exe` (Azure CLI) e `gcloud.exe` (GCP CLI).

  * **Versionamento**: `git.exe` (Git CLI) e `gh.cli` (GitHub CLI).

  * **Virtualização**: Docker Desktop para Windows (assinatura Docker Personal).

  * Entre outros...

Frequentemente, isso resulta em um arquivo `~/.bashrc` desorganizado e difícil de manter. Além disso, algumas dessas ferramentas criam seus próprios arquivos *dotfiles* na raiz do seu `$HOME`, tornando o backup e transferência de suas configurações para outro equipamento um exercício bastante complexo.

Este projeto propõe uma **arquitetura modular**: em vez de um único arquivo gigante, as configurações são separadas por responsabilidade (ambiente, funções e aliases) e por ferramenta (AWS, Git, Docker, etc), facilitando o versionamento e a portabilidade de seus *dotfiles*.

---

## 🏛️ Fundamentação: O Padrão XDG/FHS

Para manter o diretório `$HOME` limpo e organizado, este projeto adota a **XDG Base Directory Specification** em conjunto com o **FHS (Filesystem Hierarchy Standard)**. Este é o padrão contemporâneo para sistemas Unix-like (Linux, macOS e Git Bash), projetado para evitar a poluição da raiz do diretório de usuário com arquivos ocultos (os chamados *dotfiles*).

### O Padrão XDG na Prática (Referência 2026)

O padrão XDG define variáveis de ambiente que apontam para locais específicos para cada tipo de arquivo gerado por aplicações ou pelo usuário:

*   **`$XDG_CONFIG_HOME` (`$HOME/.config/`)**: Destinado a arquivos de configuração (ex: aliases, preferências de editores, envs).
*   **`$XDG_DATA_HOME` (`$HOME/.local/share/`)**: Destinado a dados persistentes que não são configurações (ex: bancos de dados locais, ícones, fontes).
*   **`$XDG_STATE_HOME` (`$HOME/.local/state/`)**: Destinado a arquivos de estado que não devem persistir entre migrações (ex: logs, histórico de comandos, estados de sessões).
*   **`$XDG_CACHE_HOME` (`$HOME/.cache/`)**: Destinado a dados não essenciais que podem ser apagados para liberar espaço (ex: caches de compiladores ou gerenciadores de pacotes).
*   **Binários do Usuário (`$HOME/.local/bin/`)**: Embora não seja estritamente parte da especificação XDG original, o FHS recomenda este local para scripts customizados e executáveis instalados pelo usuário que devem ser incluídos no `$PATH`.

> [!TIP]
> Evite a prática antiga de criar arquivos ocultos (`.arquivo`) diretamente na raiz do seu `$HOME`. Seguir o padrão XDG torna seu ambiente modular, facilita o backup seletivo e simplifica a migração de *dotfiles* entre diferentes máquinas. Verifique se a ferramenta que você quer adicionar ao seu rol de utilitários é aderente ao padrão XDG antes de criar qualquer arquivo ou pasta sob o seu $HOME.


---


### 📦 Como este projeto utiliza essa estrutura

Neste repositório, focamos na organização do seu ambiente Bash dentro dos diretórios preconizados acima:

1.  **Ponto de Entrada**: O Bash utiliza arquivos na raiz do `$HOME` para iniciar a sessão. Este projeto recomenda centralizar a lógica de carregamento no `~/.bashrc`, garantindo que tanto *interactive shells* quanto *login shells* (através do `~/.bash_profile` ou `~/.profile`) carreguem as configurações modulares.
2.  **Configurações**: Todos os scripts de inicialização, aliases e funções serão armazenados de forma organizada em `~/.config/bashrc/`.
3.  **Executáveis**: Scripts utilitários e wrappers (como os do `uv`) deste projeto residem em `~/bin/`, que o Git Bash adiciona ao seu `$PATH` automaticamente (convenção `/etc/profile`). O `~/.local/bin/` segue válido para binários instalados via Windows (ex.: `claude.exe` do instalador nativo do Claude Code) e é mantido no PATH pelo `8-bash-junctions.sh`.
4.  **Ambiente**: Variáveis de ambiente são definidas nos scripts `envs` para redirecionar ferramentas (como Terraform e Python) a usarem `~/.local/share` e `~/.local/state`, mantendo o raiz de seu diretório pessoal sempre limpo.

> **Nota sobre arquivos de inicialização**:
> *   **`~/.bashrc`**: Executado em sessões interativas que não são de login (o padrão ao abrir um novo terminal).
> *   **`~/.bash_profile`**: Executado em *login shells* (ex: via SSH ou no startup do Git Bash). Geralmente, ele deve conter um comando para carregar o `~/.bashrc`, e nada mais.
> *   **`~/.profile`**: Um fallback genérico para shells compatíveis com o padrão POSIX (caso o `~/.bash_profile` não exista). Não utilizado neste projeto.


---



## 📂 Estrutura do Repositório e Scripts

Este projeto mantém os scripts em `src/home/.config/bashrc/`. A numeração dos arquivos garante que as dependências sejam carregadas na ordem correta (ex: carregar variáveis de ambiente antes de funções que dependem delas).


### 🔢 Ordem de Carregamento por Prefixo

O `~/.bashrc` carrega `~/.config/bashrc/*.sh` em ordem alfabética. O prefixo numérico de cada script codifica suas dependências:

| Prefixo | Responsabilidade |
|---|---|
| `0` | Core Bash — variáveis básicas e funções de exibição (`displayFailure`, `displayWarning`, etc.) |
| `1` | Ferramentas — variáveis de ambiente e PATH (Git, Python, uv, Node.js, Claude Code) |
| `2` | Ferramentas — criação/validação de diretórios dependentes de `1-*-envs.sh` |
| `7` | Certificados — `NODE_EXTRA_CA_CERTS` para ambientes com proxy SSL corporativo |
| `8` | Junctions do Windows — `USERPROFILE` → `HOME` via `mklink /J` |
| `9` | Extras — opt-outs de telemetria (AWS, Azure, GCP) |

### 🛠️ Scripts de Configuração de Ambiente (`-envs.sh`)

Definem variáveis de ambiente, ajustam `$PATH` e (quando faz sentido) declaram aliases curtos. Scripts atuais:

*   **0-bash-envs.sh**: Histórico do Bash, configurações de `less`/`vim` em XDG, aliases (`ll`, `la`, `grep`, `npp`).
*   **1-git-envs.sh**: `GIT_CONFIG_GLOBAL` aderente ao XDG, aliases de log.
*   **1-python-envs.sh**: `PYTHONHISTORY`, `PYTHONUNBUFFERED`, `PYTHONIOENCODING`, `PYTHONDONTWRITEBYTECODE`.
*   **1-uv-envs.sh**: Diretórios e configurações do `uv` (cache, tools, registry, link-mode).
*   **1-node-envs.sh**: `NODE_HOME`, `NODE_CURRENT`, variáveis `NPM_CONFIG_*` em XDG.
*   **1-claude-code-envs.sh**: `CLAUDE_CONFIG_DIR` em XDG, validação de autenticação, aliases `c` e `cc`.

### 📁 Scripts de Validação de Diretórios (`-folders.sh`)

Criam diretórios e validam o `$PATH` para ferramentas configuradas nos `-envs.sh`. Separados para garantir que as variáveis já estejam definidas:

*   **2-uv-folders.sh**: Cria diretórios do uv, valida desabilitação dos shims do Python da Windows Store.
*   **2-node-folders.sh**: Cria diretórios do Node.js/npm e adiciona ao `$PATH`.

### ⚡ Scripts de Funções (`-functions.sh`)

Declaram funções complexas para automação. Atualmente:

*   **0-bash-functions.sh**: Funções de exibição (`displayTitle`, `displayInfo`, `displaySuccess`, `displayFailure`, `displayWarning`), exportadas para sub-shells.

> [!TIP]
> Para cada script `-envs.sh` você pode criar o correspondente `-functions.sh` (mesmo prefixo) com helpers da ferramenta.

### 🔧 Scripts auxiliares e infraestrutura

*   **7-node-extra-certs.sh**: Renova certificado raiz CA (cache de 7 dias via `find -mtime`), exporta `NODE_EXTRA_CA_CERTS` e `SSL_CERT_FILE`.
*   **8-bash-junctions.sh**: Resolve `HOME`, garante `~/.local/bin` no PATH (para binários Windows-installed como `claude.exe`), cria junctions em `%USERPROFILE%` para `.aws`, `.cache`, `.certs`, `.claude`, `.config`, `.local`, `.ssh`.
*   **9-extras.sh**: Desabilita telemetria de CLIs de nuvem.

### ⌨️ Scripts de Aliases (`-aliases.sh`)

> [!TIP]
> Declare nestes scripts os aliases pessoais. Atualmente os poucos aliases existentes estão inline nos respectivos `-envs.sh` por simplicidade — separe em `-aliases.sh` quando o volume justificar.

---

## 💡 Implementação Passo a Passo

### 1. Criar a estrutura de diretórios
No seu terminal, execute:
```bash
mkdir -p ~/.config/bashrc/
mkdir -p ~/bin/helpers
```

> O Git Bash adiciona `~/bin` ao `$PATH` automaticamente (`/etc/profile`), então scripts colocados aí ficam disponíveis sem precisar gerenciar PATH.

### 2. Configurar o .bashrc Principal
No seu `~/.bashrc` (ou `~/.bash_profile`) do seu Git Bash, adicione a lógica para carregar automaticamente os arquivos organizados:
```bash
# ~/.bashrc

# Configurações de locale
export LANG=pt_BR.UTF-8
export LC_ALL=pt_BR.UTF-8

# Padrão FHS (Filesystem Hierarchy Standard) / XDG (X Desktop Group)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"

# Carga (source) dos scripts de inicialização do shell (run command files)
if [ -d $XDG_CONFIG_HOME/bashrc ]; then
    for rc in $XDG_CONFIG_HOME/bashrc/*.sh; do
        [ -f "$rc" ] && source "$rc"
    done
fi

# Limpa a variável rc do escopo global
unset rc
```


---


## 🚀 Você está pronto!!

Seguem algumas dicas finais:

* **Caminhos (Paths)**: O Git Bash simula Unix. Ao definir variáveis, prefira caminhos no formato `/c/Users/nome` em vez de `C:\Users\nome`.
* **Backup**: Graças à separação modular, você pode copiar apenas o `$HOME/.bashrc` e  diretório `$HOME/.config` para um novo equipamento. Os demais arquivos serão criados automaticamente pelos scripts deste projeto no destino.
