# CLAUDE.md

Este arquivo fornece orientações ao Claude Code (claude.ai/code) ao trabalhar com o código deste repositório.

## Propósito do Projeto

Framework modular de configuração Bash para desenvolvedores Windows que usam Git Bash.
Os scripts são organizados seguindo a **XDG Base Directory Specification** e o **FHS** para manter o `$HOME` limpo.
O diretório `src/home/` espelha a estrutura alvo `~/` — os arquivos aqui são destinados a serem copiados para o diretório home do usuário.

## Estrutura do Repositório

```
src/home/
├── .config/bashrc/            # Scripts de inicialização sourced pelo ~/.bashrc (ordem detalhada abaixo)
│   ├── docs/                  # Documentação e arquivos de ajuda do usuário
│   ├── templates/             # Templates de configuração (uv, ruff, Claude, VS Code)
│   │   ├── claude/            # Templates de settings.json do Claude Code
│   │   ├── vscode/            # Templates de settings.json do VS Code
│   │   └── *.example          # Templates de configuração (dot-env, uv, ruff, pyproject.toml, etc.)
│   └── *.sh                   # Scripts de inicialização (núcleo carregado primeiro; demais em ordem alfabética)
└── bin/                       # Scripts executáveis do projeto (Git Bash adiciona ~/bin ao PATH automaticamente)
    └── helpers/               # Helpers sourced pelos scripts executáveis
```

> **Sobre `~/bin` vs `~/.local/bin`:** <li>Os scripts deste projeto ficam em `~/bin/` porque o Git Bash já adiciona esse diretório ao PATH automaticamente — não precisamos gerenciar PATH para nossos scripts. <li>O `~/.local/bin/` continua relevante para binários instalados via Windows (ex.: `claude.exe` do instalador nativo do Claude Code), e o `bash-junctions.sh` garante que esse caminho esteja no PATH.

## Arquitetura de Carregamento dos Scripts

O `~/.bashrc` carrega os scripts `~/.config/bashrc/*.sh` em três etapas, ordenadas para respeitar as dependências entre eles:

| Etapa | O que carrega | Por quê |
|-------|---------------|---------|
| 1. Núcleo (explícito, primeiro) | `bash-envs.sh`, `bash-functions.sh` | Definem `APPS_BASE`, variáveis básicas e as funções de exibição (`displayFailure`, etc.) usadas por todos os demais |
| 2. Demais scripts (glob, alfabético) | Git, Python, uv, Node.js, Claude Code, certificados, extras | O padrão de nomes `tool-envs.sh` → `tool-folders.sh` faz o alfabético garantir que `-envs` venha antes de `-folders` |
| 3. Junctions (explícito, por último) | `bash-junctions.sh` | Depende de variáveis e diretórios definidos pelos demais scripts rc |

A ordem crítica é expressa diretamente no `~/.bashrc` (núcleo na frente via `source` por nome, junctions no fim), e o restante segue o alfabético — os nomes dos scripts **não** usam mais prefixo numérico.

Os scripts utilizam os seguintes sufixos de nomenclatura:
- `-envs.sh` — define variáveis de ambiente e entradas no PATH
- `-folders.sh` — cria/valida diretórios e PATH dependentes das variáveis definidas em `-envs.sh`
- `-functions.sh` — declara funções shell (reservado; nenhum script atual usa este sufixo além de `bash-functions.sh`)
- `-aliases.sh` — declara aliases (reservado; aliases atuais estão dentro de `-envs.sh`)

## Restrições de Design

- **Conformidade com XDG**.
- **Alvo Windows/Git Bash**: usar formato de caminho Unix (`/c/Users/...`, não `C:\Users\...`).
- **USERPROFILE tem junctions para HOME**: a lógica específica do Windows usa `mklink /J` para junctions em `bash-junctions.sh`.
- **Escopo global limpo**: remover funções auxiliares após o uso (`unset -f func_name`); remover variáveis de loop (`unset rc`).
- **Degradação graciosa**: falhas de validação emitem `displayWarning`/`displayFailure` em vez de abortar a sessão do shell.
- **Sem sistema de build**: não há Makefile, package.json ou test runner.
- **Custo de inicialização**: os scripts são executados em todo shell novo; evitar forks no caminho estável (usar built-ins, parameter expansion `${var%/*}`, guardas `[ -d ] ||` antes de `mkdir -p`).

## Adicionando Suporte a Nova Ferramenta

Para adicionar uma nova ferramenta (ex.: `terraform`):
1. Crie `src/home/.config/bashrc/terraform-envs.sh` para definir variáveis de ambiente e entradas no PATH.
2. Se a ferramenta precisar de diretórios criados ou validações que dependem das variáveis, crie `src/home/.config/bashrc/terraform-folders.sh` — o sufixo `-folders` ordena alfabeticamente após `-envs`, garantindo que as variáveis já existam.
3. Opcionalmente crie `src/home/.config/bashrc/terraform-functions.sh` para helpers complexos.
4. As funções de `bash-functions.sh` estão disponíveis — não é necessário reimportá-las.
5. Siga o padrão: validar se os caminhos existem, adicionar ao `$PATH`, emitir `displayFailure` se variáveis obrigatórias estiverem ausentes.

## Idioma

O `README.md` e os comentários inline dos scripts estão em **português (pt-BR)**. As mensagens de commit seguem o mesmo idioma (ver git log). Identificadores de código, nomes de funções e variáveis estão em inglês.

## Convenção de Mensagens de Commit

**Cabeçalho** (estilo Conventional Commits): `<tipo>: <resumo curto, pt-BR, ≤ ~50 chars>`.
Tipos: `feat`, `fix`, `refactor`, `perf`, `docs`, `style`, `test`, `build`, `chore`, `ci`.

**Corpo** — três rótulos fixos, **todos opcionais**, sempre nesta ordem:

| Rótulo | Pergunta que responde |
|--------|-----------------------|
| `Motivo:` | Por que a mudança foi feita? (problema, necessidade, gatilho, contexto) |
| `Mudança:` | O que foi feito? |
| `Impacto:` | O que isso afeta? (breaking change, migração, efeitos colaterais, follow-ups) |

**Rodapé** (opcional): `BREAKING CHANGE: ...`, referências (`Refs #123`).

> Regra de ouro: **use só o que agrega.** Commit trivial pode ser só o cabeçalho — não force as três seções.

Para mensagens multi-linha, prefira heredoc com delimitador entre aspas (imune a `'`, `$`, backticks):

```bash
git commit -F - <<'EOF'
refactor: Remoção dos prefixos numéricos dos RC scripts

Motivo:
Os prefixos numéricos codificavam a ordem de carregamento via ordenação
alfabética do glob, mas tornavam os nomes ruidosos e frágeis.

Mudança:
A ordem passa a ser expressa explicitamente no ~/.bashrc: core primeiro,
bash-junctions por último, os demais em ordem alfabética entre eles.

Impacto:
Sem mudança de comportamento em runtime — apenas nomes e ordem de carga.
EOF
```
