# Especificação XDG

A especificação de diretórios XDG define onde aplicativos devem armazenar arquivos de configuração, dados do usuário, cache e estado de execução. Ela ajuda a manter o diretório pessoal (`$HOME`) mais organizado, evitando a dispersão de arquivos e pastas ocultos (começados com ponto `.`) e facilitando a migração e o backup dos dados.

Essa convenção é popular porque cria um padrão consistente entre diferentes aplicações e sistemas, reduzindo conflitos e tornando mais fácil para o usuário e para administradores entenderem onde cada tipo de arquivo deve ficar.

# Diretórios

## Diretórios locais - apenas para o usuário corrente

1. **XDG_CONFIG_HOME**: `$HOME/.config`
  * Contém apenas arquivos pequenos de preferências (arquivos .toml, .json, etc) e scripts de inicialização.  
  * Backup obrigatório, oferecendo fácil sincronização e portabilidade entre diferentes computadores.
  * Exemplos:
    * `$HOME/.config/bashrc`: para armazenar os shell scripts e arquivos de configuração do projeto BashRC for Devs.

1. **XDG_DATA_HOME**: 
  * Contém dados criados pelas aplicações por você ou para você, os quais devem ser agnósticos em relação ao hardware ou ao sistema operacional específico.
  * Backup recomendado.
  * Exemplos:
    * `$HOME/.local/share/templates`: para modelos de documentos e modelos de arquivos.
    * `$HOME/.local/share/qual???`: para bancos de dados locais locais (como o arquivo do seu gerenciador de senhas KeePass, suas notas de texto plano ou listas de tarefas).
    * `$HOME$/.local/share/fonts`: para fontes personalizadas instaladas pelo usuário.
    * `$HOME$/.local/share/applications`: para talhos do menu de aplicativos, que funcionam perfeitamente em outras máquinas desde que os mesmos programas estejam instalados.

3. **XDG_STATE_HOME**: `$HOME/.local/state`
  * Contém dados de estado que devem persistir entre as reinicializações dos aplicativos, mas que não são importantes ou portáveis o suficiente para serem armazenados em $XDG_DATA_HOME.
  * Backup dispensável (estado volátil). perder esses arquivos causa apenas pequenos inconvenientes estéticos, mas nenhuma perda de dados estruturais.
  * Exemplos:
    * `$HOME/.local/state/vlc` armazena o histórico de arquivos recentemente abertos e logs do player.

4. **XDG_CACHE_HOME**
  * Diretório para armazenar dados não essenciais ou temporários (cache) do usuário.
  * Exemplos
    * `$HOME/.cache/thumbnails`: para armazenar miniaturas de imagens geradas pelo gerenciador de arquivos.


## Diretórios locais - para todos usuários do computador

1. **XDG_RUNTIME_DIR**
  * Diretório para objetos de tempo de execução e comunicação síncrona do usuário.
  * Exemplo: `/run/user/1000/bus` armazena sockets de comunicação local e pipes criados por processos ativos do usuário.

2. **XDG_DATA_DIRS**
  * Conjunto de diretórios adicionais ordenados por preferência para buscar arquivos de dados do sistema.
  * Exemplo: `/usr/local/share/:/usr/share/` serve de caminho global para recursos compartilhados por todos os usuários.

3. **XDG_CONFIG_DIRS**
  * Conjunto de diretórios adicionais ordenados por preferência para buscar arquivos de configuração do sistema.
  * Exemplo: `/etc/xdg/menus` armazena os arquivos de configuração globais do menu do sistema.

# **Fonte**
  * [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir/latest/)