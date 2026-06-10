# Templates de Configuração

Este README descreve os templates disponíveis para os scripts helpers em `~/.local/bin/bashrc/` e explica como customizar os arquivos `.example` usados pelo projeto.

## Como Customizar Templates

Os templates usam placeholders no formato `{{VARIABLE_NAME}}` que são substituídos dinamicamente pelos scripts.

### Templates Disponíveis

- `dot-env.example`: Template para arquivo `.env` com variáveis de ambiente
- `poc-env.example`: Template para arquivos de ambiente em `envs/`
- `pyproject.toml.example`: Template para arquivo `pyproject.toml`
- `ruff.toml.example`: Template para arquivo `ruff.toml`
- `uv.toml.example`: Template para arquivo `uv.toml` global

### Customização

1. Edite os arquivos `.example` nesta pasta
2. Os scripts helpers usarão automaticamente suas versões customizadas
3. **Importante**: Os scripts seguem versionamento conservador - se um arquivo de configuração já existir, ele não será sobrescrito

### Placeholders por Template

#### dot-env.example
- `{{API_KEY}}`: API_KEY de cada produto com o qual o projeto terá integração

#### poc-env.example
- `{{PRODUCT_NAME}}`: Nome do ambiente (prod-a, prod-b, etc.)

#### pyproject.toml.example
- `{{PROJECT_NAME}}`: Nome do projeto
- `{{PYTHON_VERSION}}`: Versão mínima do Python
- `{{AUTHOR_NAME}}`: Nome do autor (do git config)
- `{{AUTHOR_EMAIL}}`: Email do autor (do git config)

#### ruff.toml.example
- `{{PROJECT_NAME}}`: Nome do projeto
- `{{PYTHON_VERSION}}`: Versão target do Python
- `{{LINE_LENGTH}}`: Comprimento máximo da linha

#### uv.toml.example
- `{{UV_CONF_FILE}}`: Caminho para o arquivo de configuração
- `{{UV_CACHE_DST}}`: Caminho para o cache do uv

### Exemplo de Customização

Para modificar o template `.env`, edite `dot-env.example`:

```bash
# Este arquivo possui secrets, manter sempre no .gitignore
# secrets:
# API_KEY="xxx"
# MY_CUSTOM_VAR="valor personalizado"

#configmap:

# Biblioteca 'logger' - definir o nível de detalhe nos logs
LOG_LEVEL="INFO"
```