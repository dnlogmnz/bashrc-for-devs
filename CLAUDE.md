# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório.

## Propósito do Projeto

Framework modular de configuração Bash para desenvolvedores Windows que usam Git Bash.
Os scripts são organizados seguindo a **XDG Base Directory Specification** e o **FHS** para manter o `$HOME` limpo.
O diretório `src/home/` espelha a estrutura alvo `~/` — os arquivos aqui são destinados a serem copiados para o diretório home do usuário.

## Estrutura do Repositório

```
src/home/
├── .config/bashrc/            # Scripts de inicialização (executados em ordem alfabética pelo ~/.bashrc)
│   ├── templates/             # Templates de configuração (uv, ruff, Claude, VS Code)
│   │   ├── claude/            # Templates de settings.json do Claude Code
│   │   ├── vscode/            # Templates de settings.json do VS Code
│   │   └── *.example          # Templates de configuração (dot-env, uv, ruff, pyproject.toml, etc.)
│   └── *.sh                   # Scripts numerados por prefixo de dependência
├── bin/                       # Scripts executáveis do projeto (Git Bash adiciona ~/bin ao PATH automaticamente)
│   └── helpers/               # Helpers sourced pelos scripts executáveis
└── .local/share/bashrc/help/  # Documentação e arquivos de ajuda do usuário
```

> **Sobre `~/bin` vs `~/.local/bin`:**<br> Os scripts deste projeto ficam em `~/bin/` porque o Git Bash já adiciona esse diretório ao PATH automaticamente — não precisamos gerenciar PATH para nossos scripts. O `~/.local/bin/` continua relevante para binários instalados via Windows (ex.: `claude.exe` do instalador nativo do Claude Code), e o `8-bash-junctions.sh` garante que esse caminho esteja no PATH.

## Arquitetura de Carregamento dos Scripts

O `~/.bashrc` carrega todos os arquivos `~/.config/bashrc/*.sh` em ordem alfabética.
O prefixo numérico determina a ordem de carregamento e codifica as dependências:

| Prefixo | Responsabilidade |
|---------|------------------|
| `0`     | Core Bash (variáveis de ambiente, funções de exibição) |
| `1`     | Ferramentas — definição de variáveis e PATH (Git, Python, uv, Node.js, Claude Code) |
| `2`     | Ferramentas — criação de diretórios e validações pós-`envs` (uv, Node.js) |
| `7`     | Certificados (`NODE_EXTRA_CA_CERTS` para ambiente corporativo) |
| `8`     | Junctions do Windows (`USERPROFILE` → `HOME`) |
| `9`     | Extras (opt-outs de telemetria) |

Os scripts utilizam os seguintes sufixos de nomenclatura:
- `-envs.sh` — define variáveis de ambiente e entradas no PATH
- `-folders.sh` — cria/valida diretórios e PATH dependentes das variáveis definidas em `-envs.sh`
- `-functions.sh` — declara funções shell (reservado; nenhum script atual usa este sufixo além de `0-bash-functions.sh`)
- `-aliases.sh` — declara aliases (reservado; aliases atuais estão dentro de `-envs.sh`)

## Restrições de Design

- **Conformidade com XDG**.
- **Alvo Windows/Git Bash**: usar formato de caminho Unix (`/c/Users/...`, não `C:\Users\...`).
- **USERPROFILE tem junctions para HOME**: a lógica específica do Windows usa `mklink /J` para junctions em `8-bash-junctions.sh`.
- **Escopo global limpo**: remover funções auxiliares após o uso (`unset -f func_name`); remover variáveis de loop (`unset rc`).
- **Degradação graciosa**: falhas de validação emitem `displayWarning`/`displayFailure` em vez de abortar a sessão do shell.
- **Sem sistema de build**: não há Makefile, package.json ou test runner.
- **Custo de inicialização**: os scripts são executados em todo shell novo; evitar forks no caminho estável (usar built-ins, parameter expansion `${var%/*}`, guardas `[ -d ] ||` antes de `mkdir -p`).

## Adicionando Suporte a Nova Ferramenta

Para adicionar uma nova ferramenta (ex.: `terraform`):
1. Crie `src/home/.config/bashrc/1-tool-envs.sh` para definir variáveis de ambiente e entradas no PATH.
2. Se a ferramenta precisar de diretórios criados ou validações que dependem das variáveis, crie `src/home/.config/bashrc/2-tool-folders.sh`.
3. Opcionalmente crie `src/home/.config/bashrc/1-tool-functions.sh` para helpers complexos.
4. As funções de `0-bash-functions.sh` estão disponíveis — não é necessário reimportá-las.
5. Siga o padrão: validar se os caminhos existem, adicionar ao `$PATH`, emitir `displayFailure` se variáveis obrigatórias estiverem ausentes.

## Idioma

O `README.md` e os comentários inline dos scripts estão em **português (pt-BR)**. As mensagens de commit seguem o mesmo idioma (ver git log). Identificadores de código, nomes de funções e variáveis estão em inglês.
