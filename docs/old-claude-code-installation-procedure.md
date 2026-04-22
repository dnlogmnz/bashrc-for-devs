# **Claude Code**: Configuração e Instalação

Este documento descreve o processo de instalação e configuração do **Claude Code** (CLI) e extensão para o VS Code, e todas as configurações necessárias para consumo de modelos (LLMs) no Provedor escolhido.

  * Para consumir os modelos (LLMs) da Anthropic, você precisa de um dos [Planos de Assinatura do Claude Code](https://support.claude.com/en/articles/11049762-choosing-a-claude-plan) [^1].
  
  * Se você decidir consumir os modelos de um Provedor que não seja a Anthropic (GCP VertexAI, AWS Bedrock, AI Gateway), a integração com o LLM irá ocorrer sem tráfego de dados e sem login na infraestrutura pública da Anthropic.

O diagrama abaixo ilustra como o **Claude Code** opera utilizando o Git Bash como motor de execução local, e o uso do Genial como gateway seguro para modelos (LLM's) privados.

![Diagrama de arquitetura técnica ilustrando a instalação segura do **Claude Code** em um ambiente Windows 11. O diagrama está dividido em duas seções principais: 'Notebook do Desenvolvedor' e 'Infraestrutura Corporativa'. No notebook, o usuário interage com o **Claude Code** CLI ou a extensão do VS Code, que utiliza o Git Bash para executar comandos locais e variáveis de ambiente para configuração. O tráfego de dados segue por HTTPS usando um token privado para um AI Gateway (LiteLLM) na infraestrutura corporativa, que roteia as requisições para modelos de IA privados. Uma linha tracejada com o rótulo 'BLOQUEADO' indica que qualquer comunicação com a nuvem pública da Anthropic é impedida, garantindo a privacidade dos dados.][^image1]

## 1. Pré-requisitos de Instalação

Antes de começar a instalação do **Claude Code CLI** e/ou da **Extensão para VS Code**, é necessário confirmar todos os pré-requisitos indicados nesta seção.

### 1.1. Pressupostos

O procedimento descrito neste documento usa alguns pressupostos:

  * O usuário do Windows não tem privilégios administrativos nem capacidade de elevação de privilégios.
  
  * Evitar ao máximo o uso de ferramentas do Windows, tais como o PowerShell ou os editores do Registry do Windows (`regedit.exe`, `reg.exe`, e comandos afins).

### 1.2. Editar as variáveis de ambiente para sua conta: `CLAUDE_CODE_GIT_BASH_PATH`

O **Claude Code** em Windows tem como requisito a instalação prévia de um Bash e do cliente do Git, pois depende deles para executar algumas operações:

  * `git.exe`: para realizar operações com branches, commits e outras ações para controle de versão do código fonte diretamente no VS Code.

  * `bash.exe`: para, entre outras ações, realizar testes com o código do projeto [^2].

Para isso, o **Claude Code** precisa saber a localização exata do `bash.exe`.

Se você fez a instalação padrão do Git for Winodws, o Git Bash d seu computador estará em:
    ```
    C:\Users\%USERNAME%\AppData\Local\Git\bin\bash.exe
    ```

Mas se você instalou o Git for Windows em alguma pasta diferente da padrão, deve obrigatoriamente definir a variável de ambiente `CLAUDE_CODE_GIT_BASH_PATH`:

  * Abra o Git Bash, execute `where bash`, e anote o resultado.
  
  * Abra o aplicativo **Editar as variáveis de ambiente para sua conta**:

  * Na seção superior (**Variáveis de ambiente para %USERNAME%**), clique em `Novo...`.
  
  * Adiciona uma variável de ambiente chamada `CLAUDE_CODE_GIT_BASH_PATH`.
  
  * Atribuir o valor indicado pelo comando `where bash` executado acima.


### 1.3. Editar as variáveis de ambiente para sua conta: `CLAUDE_CONFIG_DIR`

O **Bash RC for Devs** adota o padrão XDG de diretórios, então o arquivo `settings.json` (configuração global do Claude Code) ficará em `$HOME/.config/claude`.
  
  * Abra um Git Bash e execute os seguintes comandos:
    ```
    mkdir -p $HOME/.config/claude
    cd $HOME/.config/claude
    touch settings.json
    ```

  * Abra o arquivo `settings.json` recém criado com o editor de sua preferência, e grave o seguinte conteúdo:

    ```json
    {
        // Esquema oficial de definição de dados do **Claude Code**
        "$schema": "https://json.schemastore.org/claude-code-settings.json",

        // Modelos disponibilizados pelo AI Gateway
        "model": "claude-sonnet",   // modelo usado por padrão nas operações
        "availableModels": [        // modelos disponíveis para o comando "/model"
            "sonnet",
            "claude-sonnet",
            "claude-sonnet-4-6",
            "haiku",
            "claude-haiku",
            "claude-haiku-4-5"
        ],

        // Variáveis de ambiente (que poderiam ter sido definidas no sistema operacional)
        "env": {
            // "ANTHROPIC_AUTH_TOKEN": "sk-sua-api-key-no-Provedor",
            // "ANTHROPIC_BASE_URL": "https://link-para-seu-AI-Gateway.com",  // quando seu Provedor não for a Anthropic
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-sonnet",
            "CLAUDE_CODE_SUBAGENT_MODEL": "claude-haiku"
            "ANTHROPIC_MODEL": "claude-sonnet",
        }
    }
    ```


### 1.3. Confirmar instalação do Node.js em versão igual ou superior a 18

O **Claude Code** utiliza o motor Node.js (v18+) para execução de algumas operações [^2], então você  precisa confirmar a versão instalada no computador:

  * Abrir um Prompt de Comandos (`cmd.exe`), e execute o comando `node -v`.
  
  * O resultado deve ser semelhante a:
    ```text
    v22.22.1  :: deve ser qualquer versão maior que 18
    ```

  > **Dica:** *Alguns sites vão indicar o uso de **`npm install -g`**, mas esse procedimento é considerado legado pela Anthropic, que recomenda usar o novo instalador nativo.* [^3]

### 1.3. Confirmar privilégio para download do instalador nativo

Em um navegador, abrir a URL **`https://claude.ai/install.cmd`** com o usuário que irá instalar e usar o **Claude Code**.

O resultado esperado é que seja aberta uma janela de download:

  * Se a janela abrir, está confirmado que o seu `%USERNAME%` tem o privilégio necessário para instalar o **Claude Code**, e o download pode ser cancelado.

  * Em caso de falha de conexão (Timeout ou 403) durante a tentativa, seu usuário no Windows não tem privilégio para download do instalador. Isso provavelmente irá ocorrer apenas em ambiente empresarial, e a provável solução será abrir um ticket para o time de TI instalar o **Claude Code** em seu computador.

### 1.4. Baixar o Certificado Raiz da sua Empresa para um arquivo `.pem`

O **Claude Code** utiliza o motor Node.js/Bun que, por padrão, não utiliza a loja de certificados nativa do Windows.

  * **Em alguns ambientes corporativos**, a integração do **Claude Code** com o Provedor poderá ser rejeitada com erro de SSL ("Self-signed certificate").

  * Se você estiver recebendo o erro de SSL, pode ser necessário baixar o certificado raiz da sua Empresa para um arquivo `.pem`, e definir a variável `NODE_EXTRA_CA_CERTS` apontando para o mesmo.
  
  * O **Bash RC for Devs** possui um script que faz o download do certificado para um diretório sob o seu $HOME.
  
  * Para validar que o arquivo foi baixado use os seguintes comandos:
    ```
    cd $HOME/.config/certs
    where ca_root.pem
    ```
    > **Dica:** Anote o caminho completo para o arquivo, pois é o valor da variável `NODE_EXTRA_CA_CERTS`.

  * Confirme que o arquivo contém um único certificado:
    ```
    cd $HOME/.config/certs
    cat ca_root.pem
    ```
    
    O resultado esperado é semelhante ao seguinte:
    ```
    -----BEGIN CERTIFICATE-----
    várias+linhas+exatamente+com+o+mesmo+comprimento
    cada+uma+com+letras+números+sinais+de+pontuação/
    e+a+última+linha+provavelmente+é+menor=
    -----END CERTIFICATE-----
    ```

### 1.5. Solicitar ao Provedor uma API Key para uso pessoal

  * Você deve entrar na console do Provedor e solicitar uma **Virtual API Key**.

  * O valor da API Key fica disponível somente no momento em que é gerada, então é **obrigatório** copiar o valor e imediatamente atribuir à variável de ambiente ``.

  * Acompanhe o consumo de tokens, principalmente quando o Provedor escolhido não for a Anthropic, caso em que provavelmente não há limite para a quantidade de tokens, porém provavelmente você estará pagando por consumo.

  * **Sugestão**: estabeleça um orçamento máximo mensal (se não tiver ideia de quanto, comece com USD 25/mês), e acompanhe de perto o seu consumo diário de tokens.

### 1.6. Criar arquivo de configuração global do **Claude Code**

#### Por que essas configurações são necessárias?

  * Queremos usar o **Claude Code** integrado ao Provedor (Anthropic, GCP Vertex, AWS Bedrock, AI Gateway).

  * Queremos evitar o uso dos modelos da família Opus, significantemente mais caros.

  * Queremos direcionar a integração com o LLM rodando no Provedor, para o caso do Provedor escolhido não ter sido a Anthropic.

#### Arquivo `settings.json` global

O **Bash RC for Devs** adota o padrão XDG de diretórios, então o arquivo `settings.json` (configuração global do Claude Code) ficará em `$HOME/.config/claude`.
  
  * Abra um Git Bash e execute os seguintes comandos:
    ```
    mkdir -p $HOME/.config/claude
    cd $HOME/.config/claude
    touch settings.json
    ```

  * Abra o arquivo `settings.json` recém criado com o editor de sua preferência e grave o seguinte conteúdo:

    ```json
    {
        // Esquema oficial de definição de dados do **Claude Code**
        "$schema": "https://json.schemastore.org/claude-code-settings.json",

        // Modelos disponibilizados pelo AI Gateway
        "model": "claude-sonnet",   // modelo usado por padrão nas operações
        "availableModels": [        // modelos disponíveis para o comando "/model"
            "sonnet",
            "claude-sonnet",
            "claude-sonnet-4-6",
            "haiku",
            "claude-haiku",
            "claude-haiku-4-5"
        ],

        // Variáveis de ambiente (caso não definidas no sistema operacional)
        "env": {
            "ANTHROPIC_AUTH_TOKEN": "sk-sua-api-key-no-Provedor",
            // "ANTHROPIC_BASE_URL": "https://link-para-provedor-quando-for-diferente-da-Anthropic.com",
            "ANTHROPIC_DEFAULT_SONNET_MODEL": "claude-sonnet",
            "ANTHROPIC_DEFAULT_HAIKU_MODEL": "claude-haiku",
            "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-sonnet",
            "ANTHROPIC_MODEL": "claude-sonnet",
            "CLAUDE_CODE_SUBAGENT_MODEL": "claude-haiku",
            "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": "1",
            "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS": "1",
        },

        // Controla permissão em alguns arquivos e diretórios chave
        "permissions": {
            "Deny": [
                "Edit(./.env\)",            // Impede modificar segredos no .env
                "Read(./.git/**)",          // Protege os metadados do repositório
                "Read(**/node_modules/**)", // Ignora pastas de dependências
                "Read(./build/**)",         // Ignora pastas de build
                "Read(./dist/**)",          // Ignora pastas de distribuição
                "Read(**/\.pem)",           // Impede leitura de certificados
                "Read(**/\*.key)"           // impede leitura de chaves privadas
            ]
        }
    }
    ```

### 1.7. Configurar extensão do **Claude Code** para Visual Studio Code

Antes mesmo de instalar a extensão, você deve fazer estas configurações no VS Code.

  - Clique `CTRL`+`SHIFT`+`P`, escreva `User Settings`, e clique em `User Settings (JSON)`

  - Adicione as seguintes linhas ao arquivo:
    ```
    // **Claude Code**
    "claudeCode.preferredLocation": "panel",
    "claudeCode.disableLoginPrompt": true,
    "claudeCode.environmentVariables": [
        {
            "name": "ANTHROPIC_AUTH_TOKEN",
            "value": "sk-sua-api-key-no-Provedor"
        },
        {
            "name": "ANTHROPIC_BASE_URL",
            "value": "https://link-para-provedor-quando-for-diferente-da-Anthropic.com"
        },
        {
            "name": "ANTHROPIC_MODEL",
            "value": "claude-sonnet",
        },
        {
            "name": "ANTHROPIC_DEFAULT_SONNET_MODEL",
            "value": "claude-sonnet",
        },
        {
            "name": "ANTHROPIC_DEFAULT_HAIKU_MODEL",
            "value": "claude-haiku",
        },
        {
            "name": "ANTHROPIC_DEFAULT_OPUS_MODEL",
            "value": "claude-sonnet",
        },
        {
            "name": "CLAUDE_CODE_SUBAGENT_MODEL",
            "value": "claude-haiku",
        },
        {
            "name": "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC",
            "value": "1",
        },
        {
            "name": "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS",
            "value": "1",
        },
        {
            "name": "CLAUDE_CODE_GIT_BASH_PATH",
            "value":
                "C:\\Users\\%USERNAME%\\AppData\\Local\\Programs\\Git\\bin\\bash.exe"
        },
        {
            "name": "NODE_EXTRA_CA_CERTS",
            "value": "C:\\Users\\%USERNAME%\\.certs\\ca_root.pem"
        }
    ]
    ```

### 1.8. Configurar variáveis de ambiente para sua conta no Windows

Duas variáveis precisam ser definidas antes da inicialização do **Claude Code**.

Abrir a aplicação "Editar as variáveis de ambiente para sua conta" do Windows.

Declarar as variáveis na seção superior, "**Variáveis de usuário para \<%USERNAME%>**":

| Variável | Valor |
| ----     | ----  |
| **CLAUDE_CODE_GIT_BASH_PATH** | **C:\\Users\\%USERNAME%\\AppData\\Local\\Programs\\Git\\bin\\bash.exe** |
| **NODE_EXTRA_CA_CERTS** | **C:\\Users\\%USERNAME%\\.certs\\ca_root.pem** |

![][image3]

## 2. Instalar o **Claude Code** e a Extensão para VS Code

### 2.1. Antes de prosseguir

Somente realizar as instalações DEPOIS de fazer com sucesso as configurações acima.

### 2.2. Instalação do **Claude Code** (CLI)

Abrir um Prompt de Comandos (**cmd.exe**) e executar o comando de instalação 5:

| curl -fsSL https://claude.ai/install.cmd -o install.cmd && install.cmd && del install.cmd |
| :---- |

#### Teste da Instalação:

Feche todas as janelas com Prompt de Comandos (cmd.exe) e Git Bash (bash.exe).

Abra um novo Git Bash, para garantir que as variáveis de ambiente sejam carregadas.

Execute **claude ping**: Deve retornar uma resposta básica do LLM via Genial.

#### Validar que o consumo está sendo via Genial:

Execute **claude /status**

O "API Provider" deve exibir a URL do Genial, e não o endpoint da Anthropic.

### 2.3. Instalação da Extensão para VS Code

Nas extensões do VS Code, procure por **publisher:Anthropic "**Claude Code**"**:

![][image4]

## 3. Procedimentos para Desinstalação

### 3.1. Desinstalar a Extensão do VS Code

Vá à aba de Extensões do VS Code, selecione "**Claude Code**" e clique em "**Uninstall**".

![][image5]

Clique **CTRL** + **SHIFT** + **P**, escreva **User Settings**, e clique em ***User Settings (JSON)***.

Remova as configurações do **Claude Code** do arquivo **settings.json**.

### 3.2. Desinstalar o **Claude Code** (CLI)

Abrir um Git Bash.

Remover o binário: **rm $UserProfile\\.local\\bin\\claude.exe**.

Remover o diretório de dados: **rm -rf $USERPROFILE\\.claude**.

Remover o arquivo de preferências: **rm $USERPROFILE\\.claude.json**.

### 3.3. Limpeza de Variáveis de Ambiente

Abrir o aplicativo "Editar as variáveis de ambiente para sua conta".

Remover todas as variáveis iniciadas com **ANTHROPIC\** e **CLAUDE_CODE\**.

Remover  **NODE_EXTRA_CA_CERTS** caso não seja utilizada por outras ferramentas.

## 4. Definições

### 4.1. O que é o **Claude Code**

O **Claude Code** é uma ferramenta de interface de linha de comando (CLI) baseada em agentes autônomos de de IA generativa, capaz de interagir diretamente com o sistema de arquivos e o terminal, com o objetivo de auxiliar desenvolvedores na criação e evolução de códigos fonte de seus projetos de aplicação. 1

Diferente de assistentes de chat comuns, ele possui capacidade agêntica, o que significa que pode ler a estrutura de diretórios, analisar arquivos de código, executar comandos de shell para testes e realizar edições complexas em múltiplos arquivos de forma autônoma [^2].

#### Diretórios e Arquivos do **Claude Code**

O **Claude Code** utiliza os seguintes caminhos no Windows (instalação padrão):

**Binário do Executável:** **%UserProfile%\\.local\\bin\\claude.exe**

**Diretório de Configuração:** **%UserProfile%\\.claude\\**

**Arquivo de Preferências:** **%UserProfile%\\.claude.json** (temas, histórico de dicas)

**Arquivo de Configuração do Agente:** **%UserProfile%\\.claude\\settings.json**

**Arquivo de Credenciais:** **%UserProfile%\\.claude\\.credentials.json**

### 4.2. O que é a extensão do **Claude Code** para VS Code

A extensão para Visual Studio Code é uma interface gráfica que atua como uma ponte (bridge) para o binário CLI do **Claude Code**. A extensão não substitui o CLI; ela o invoca internamente. As configurações de plugins e servidores MCP feitas no CLI são automaticamente refletidas na extensão.2

O **CLI** oferece controle total para automações e fluxos técnicos avançados. Ele permite retroceder o contexto da conversa, gerenciar múltiplas sessões paralelas e executar comandos diretamente via terminal. É a ferramenta ideal para scripts e integração com ferramentas de desenvolvimento externas.

A **extensão** prioriza a experiência visual e a edição imediata dentro do VS Code. Ela facilita a visualização de mudanças no código através de diffs interativos e janelas de chat integradas. É perfeita para quem busca conveniência e uma interface amigável durante a escrita manual de código.

### 4.3. O que é o Git Bash

O **Git for Windows** fornece um ambiente de emulação Bash para sistemas Windows.5

**Relação:** O **Claude Code** utiliza o **bash.exe** internamente para realizar operações de sistema, como leitura de arquivos e execução de scripts.5

**Diretório Padrão de Instalação (Usuário):**
  **C:\\Users\\%USERNAME%\\AppData\\Local\\Programs\\Git\\**

**Localização do Executável:**
  **C:\\Users\\%USERNAME%\\AppData\\Local\\Programs\\Git\\usr\\bin\\bash.exe**

### 4.4. O que é um AI Gateway

Um **AI Gateway** (Gateway de IA) é uma camada de software intermediária (middleware) que se posiciona entre as aplicações internas e os provedores de modelos de IA generativa.8

#### Funções Principais de um AI Gateway:

**Roteamento:** Abstrai chamadas para múltiplos modelos (Anthropic, OpenAI, Gemini) e servidores MCP, simplificando a integração.

**Segurança:** Anonimiza dados sensíveis (PII) e aplica filtros de conformidade (LGPD) antes de enviar dados para provedores externos.

**Controle de Custos (FinOps):** Permite a gestão centralizada de cotas, limites de tokens por time e rateio de despesas.

**Observabilidade:** Mantém logs de auditoria e monitora a latência das respostas.

**Resiliência:** Implementa mecanismos de fallback automático caso um provedor ou região de nuvem apresentar indisponibilidade.

#### Genial: o AI Gateway interno da Porto

Na Porto, o AI Gateway interno disponível para aplicações internas é o Genial.

Entre 2023 e 2026, o Genial foi uma aplicação desenvolvida internamente na Porto.

A partir de 2026, essa aplicação foi substituída por um produto chamado LiteLLM, mas o nome Genial foi mantido.

#### Modelos Claude Disponíveis no Genial (AI Gateway)

A princípio, os modelos Opus não estão disponíveis no Genial.

O motivo é o seu custo significativamente mais elevado em comparação com todos os demais modelos disponibilizados pelo Genial para uso pelas aplicações internas da Porto.

## 5. Estimativa de Licenciamento e Consumo de Tokens

#### Uso do **Claude Code** com Planos de Assinatura da Anthropic

A disponibilização do **Claude Code** como IDE foi pensado pela Anthropic para uso com um de seus planos de assinatura. O quadro a seguir apresenta os principais planos disponíveis.

| Plano Anthropic | Custo Fixo | **Claude Code** Incluído? |
| :---: | :---: | :---: |
| Free | $0 | Não [^4] |
| Pro | $20/mês | Sim |
| Team Premium | $150/mês | Sim |

#### ***Nota:**    As configurações mostradas neste documento permitem o uso do **Claude Code** sem que seja necessário contratar um plano corporativo do produto.*

#### Uso do **Claude Code** através do Genial (AI Gateway interno da Porto)

As configurações que permitem o uso do **Claude Code** integrado ao Genial possui um custo relativo ao consumo real de tokens. Os custos desse consumo serão repassados aos usuários.

#### Estimativa de Custos via Genial - Supondo uso do modelo Sonnet 4.5:

Imagine que uma equipe de Desenvolvimento deseja criar do zero um projeto usando o **Claude Code** configurado para consumir o Genial (modelo Claude Sonnet 4.5). O custo estimado de tokens (março/2026) seria:

Tokens de Entrada (input tokens, ou contexto): USD$ 3 / MToken

Tokens de Saída: USD$ 15 / MToken

Tokens em Cache: USD $0.30 / MToken

Seguem estimativas para início de dois projetos, sendo o primeiro um Frontend em React, e o segundo um backend em Node.js.

**Scaffold Frontend (React)**: Criar um projeto do zero envolve o envio do contexto do sistema (\~60k tokens) mais a geração de múltiplos arquivos. Estimativa: 150k tokens de entrada e 20k de saída. **Custo estimado: $0.75 por execução**.

**Scaffold Backend (Node.js):** Semelhante ao frontend, com menos arquivos de estilo. Estimativa: 100k tokens de entrada e 15k de saída. **Custo estimado: $0.52 por execução.**


---


## Anexo 1 - Mermaid do Diagrama na página 1
[^i]
```
graph TD

subgraph "Notebook do Desenvolvedor (Windows 11)"
    User --> CLI["**Claude Code** (CLI)"]
    VSCode -- "Extensão" --> CLI
    CLI -- "Executa comandos" --> BASH[Git Bash]
    CLI -- "Variáveis de Ambiente" --> NODEJS[node.js]
end

subgraph "Infraestrutura Corporativa"
    NODEJS -- "HTTPS (Token Privado)" --> GW["AI Gateway\n(Genial v2/LiteLLM)"]
    GW -- "Segurança/Governança/FinOps" --> LLMs["LLMs\n(Azure, GCP, AWS, OCI)"]
end

CLI -.->|"BLOQUEADO"| ANT["Anthropic Cloud"]
```


## Anexo 2 - Fontes consultadas

[^1]: [Quickstart - Claude Code Docs](https://code.claude.com/docs/en/quickstart), acessado em 26/março/2026

[^2]: [Advanced setup - Claude Code Docs](https://code.claude.com/docs/en/setup), acessado em 26/março/2026

[^3]: [Add environment variable to configure .claude config directory location #25762](https://github.com/anthropics/claude-code/issues/25762) - GitHub, acessado em 26/março/2026

[^4]: [Planos de Assinatura do Claude Code](https://support.claude.com/en/articles/11049762-choosing-a-claude-plan), acessado em 26/março/2026

[^92]: [Claude Code VS Code extension: A complete guide in 2025 | eesel AI](https://www.eesel.ai/blog/claude-code-vs-code-extension), acessado em 26/março/2026

[^93]: [Use Claude Code in VS Code - Claude Code Docs](https://code.claude.com/docs/en/vs-code), acessado em 26/março/2026

[^94]: [LLM gateway configuration - Claude Code Docs](https://code.claude.com/docs/en/llm-gateway), acessado em 26/março/2026

[^96]: [Claude Code Quickstart | LiteLLM](https://docs.litellm.ai/docs/tutorials/claude_responses_api), accessed March 26, 2026

[^98]: [Authentication - Claude Code Docs](https://code.claude.com/docs/en/authentication), acessado em 26/março/2026

[^99]: [Configure Claude Code for Microsoft Foundry](https://learn.microsoft.com/en-us/azure/foundry/foundry-models/how-to/configure-claude-code), acessado em 26/março/2026

[^80]: [Claude Code Overview](https://code.claude.com/docs/en/overview#terminal), acessado em 26/março/2026

[^81]: [Claude Code CLI Environment Variables · GitHub](https://gist.github.com/unkn0wncode/f87295d055dd0f0e8082358a0b5cc467), acessado em 26/março/2026

[^82]: [Configuração do modelo Claude Code | Anthropic Help Center](https://support.claude.com/pt/articles/11940350-configuracao-do-modelo-claude-code), acessado em 26/março/2026

