# Templates de Configuração

Este README descreve os templates disponíveis para os scripts helpers em `~/bin/helpers/` e explica como customizar os arquivos `.example` e `.json` usados pelo projeto.

## Como Customizar Templates

Os templates `.example` usam placeholders no formato `{{VARIABLE_NAME}}` que são substituídos dinamicamente pelos scripts helpers (ex.: `uv-pyproject-toml.sh`, `uv-ruff-toml.sh`). Os templates `.json` em `claude/` e `vscode/` são copiados sem substituição.

### Estrutura

```
templates/
├── dot-env.example                    # Template para .env de aplicação genérica
├── python/
│   ├── cli-env.example                # Template para envs de PoC/CLI
│   ├── pyproject.toml.example         # Template de pyproject.toml
│   ├── ruff.toml.example              # Template de ruff.toml
│   └── uv.toml.example                # Template de uv.toml global
├── claude/
│   ├── home-dot-claude-settings.json  # settings.json global do Claude Code (XDG)
│   └── project--dot-claude-settings.json  # settings.json por projeto
└── vscode/
    └── settings.json                  # Preferências globais do VS Code
```

### Customização

1. Edite os arquivos `.example` (ou `.json`) nesta pasta.
2. Os scripts helpers usarão automaticamente suas versões customizadas.
3. **Importante**: os scripts seguem versionamento conservador — se um arquivo de configuração já existir, ele **não** será sobrescrito.

### Placeholders por Template

#### `dot-env.example`
- `{{API_KEY}}` — API Key de cada produto com o qual o projeto terá integração

#### `python/cli-env.example`
- `{{PRODUCT_NAME}}` — Nome do produto/ambiente (usado em `API_BASE_URL` e comentários)

#### `python/pyproject.toml.example`
- `{{PROJECT_NAME}}` — Nome do projeto
- `{{PYTHON_VERSION}}` — Versão mínima do Python (ex.: `3.14`)
- `{{AUTHOR_NAME}}` — Nome do autor (lido do `git config user.name`)
- `{{AUTHOR_EMAIL}}` — Email do autor (lido do `git config user.email`)

#### `python/ruff.toml.example`
- `{{PROJECT_NAME}}` — Nome do projeto (usado em `lint.isort.known-first-party`)
- `{{PYTHON_VERSION}}` — Versão target (formato `py314`, sem ponto)
- `{{LINE_LENGTH}}` — Comprimento máximo da linha

#### `python/uv.toml.example`
- `{{UV_CACHE_DST}}` — Caminho para o cache do uv

#### `claude/*.json` e `vscode/settings.json`
- Sem placeholders. São copiados literalmente para o destino quando o arquivo correspondente não existir.

### Exemplo de Customização

Para modificar o template `.env`, edite `dot-env.example`:

```bash
# Este arquivo possui secrets, manter sempre no .gitignore
# secrets:
API_KEY="{{API_KEY}}"
MY_CUSTOM_VAR="valor personalizado"

#configmap:

# Biblioteca 'logger' - definir o nível de detalhe nos logs
LOG_LEVEL="INFO"
```
