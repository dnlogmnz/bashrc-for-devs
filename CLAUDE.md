# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Purpose

Modular Bash configuration framework for Windows developers using Git Bash. Scripts are organized following the **XDG Base Directory Specification** and **FHS** to keep `$HOME` clean. The `src/home/` directory mirrors the target `~/` structure — files here are meant to be copied to the user's home directory.

## Repository Structure

```
src/home/
├── .config/bashrc/        # Scripts de inicialização (executados em ordem alfabética pelo ~/.bashrc)
│   ├── utils/             # Scripts de migração e utilitários
│   ├── templates/         # Templates de configuração (uv, ruff, Claude, VS Code)
│   └── *.sh               # Scripts numerados por prefixo de dependência
├── .local/bin/bashrc/     # Scripts executáveis e helpers para gerenciamento de ferramentas
└── .local/share/bashrc/help/  # Documentação e arquivos de ajuda do usuário
src/home/.config/bashrc/templates/
├── claude/                # Templates de settings.json do Claude Code
├── vscode/                # Templates de settings.json do VS Code
└── *.example              # Templates de configuração (dot-env, uv, ruff, pyproject.toml, etc.)
```

## Script Loading Architecture

`~/.bashrc` sources all `~/.config/bashrc/*.sh` files in alphabetical order. The numeric prefix determines load order and encodes dependencies:

| Prefix | Responsibility |
|--------|----------------|
| `00-*` | Core Bash (env vars, display functions, Windows junctions) |
| `11-*` | Git CLI |
| `21-23-*` | Python (uv), Node.js runtimes |
| `31-*` | Claude Code |
| `99-*` | Extras (telemetry opt-outs) |

Scripts use three naming suffixes:
- `-envs.sh` — sets environment variables and PATH entries
- `-functions.sh` — declares shell functions
- `-aliases.sh` — declares aliases

`-envs.sh` scripts run before their corresponding `-functions.sh` because of alphabetical ordering.

## Display Functions (from `00-bash-functions.sh`)

All scripts use these ANSI-colored output helpers (exported to subshells):

```bash
displayTitle   "text"           # Cyan background header
displayAction  "text"           # Cyan text
displayScript  "text"           # Yellow text
displayInfo    "label" "value"  # Plain aligned key-value
displaySuccess "label" "msg"    # Bold green
displayFailure "label" "msg"    # Bold red
displayWarning "label" "msg"    # Bold yellow
```

Always use these functions for user-facing output — never raw `echo`.

## Key Design Constraints

- **Windows/Git Bash target**: Use Unix path format (`/c/Users/...`, not `C:\Users\...`). Windows-specific logic uses `mklink` for junctions in `00-bash-junctions.sh`.
- **XDG compliance**: Config → `$XDG_CONFIG_HOME` (`~/.config`), data → `$XDG_DATA_HOME` (`~/.local/share`), state → `$XDG_STATE_HOME` (`~/.local/state`), cache → `$XDG_CACHE_HOME` (`~/.cache`).
- **Clean global scope**: Unset helper functions after use (`unset -f func_name`); unset loop variables (`unset rc`).
- **Graceful degradation**: Validation failures emit `displayWarning`/`displayFailure` rather than aborting the shell session.
- **No build system**: There is no Makefile, package.json, or test runner. Validation is manual via `claude doctor` and by inspecting shell startup output.

## Adding New Tool Support

To add a new tool (e.g., `terraform`):
1. Crie `src/home/.config/bashrc/XX-tool-envs.sh` (numerado para carregar após dependências).
2. Opcionalmente crie `src/home/.config/bashrc/XX-tool-functions.sh` para helpers complexos.
3. Source `00-bash-functions.sh` functions are available — no need to re-import them.
4. Follow the pattern: validate paths exist, add to `$PATH`, emit `displayFailure` if required vars are missing.

## Claude Code Integration (`31-claude-code-envs.sh`)

- Sets `CLAUDE_CODE_DIR` to `$XDG_CONFIG_HOME/claude` (overrides the default `~/.claude`).
- Auto-discovers `bash.exe` in common Windows locations for `CLAUDE_CODE_GIT_BASH_PATH`.
- Defines aliases: `c` → `claude`, `cc` → `claude --continue`.
- Validation can be suppressed with `CLAUDE_SKIP_VALIDATION=1` for scripting/automation.
- Looks for `$CLAUDE_CODE_DIR/settings.json` and `$CLAUDE_CODE_DIR/.credentials.json`.

## Language

README.md and inline script comments are in **Portuguese (pt-BR)**. Commit messages follow Portuguese too (see git log). Code identifiers, function names, and variable names are in English.
