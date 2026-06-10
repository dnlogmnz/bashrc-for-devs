# Instalação de Aplicativos e Utilitários DevSecOps

## Pressupostos
As instalações de aplicativos no Windows 11 serão feitas com um usuário comum que:
- não tem privilégios administrativos, nem capacidade de obter elevação de privilégios;
- está proibido de usar o PowerShell, editores do Registry (tais como `reg.exe` e `regedit.exe`);
- não pode baixar nada via Windows Store;
- não pode usar winget e outros instaladores normalmente recomendados no Windows.

Todas instalações pressupõe que as seguintes variáveis de ambiente foram adicionadas no "Editar variáveis de ambiente para sua conta":
- `HOME` aponta para `D:\<USUÁRIO>`
- `APPS_BASE` aponta para `D:\<USUÁRIO>\Apps`

Os motivadores são os seguintes:
- O drive `C:` deve estar, na medida do possível, reservado para o Windows.
- A instalação de aplicações apenas para meu `<USUÁRIO>` devem ter como destino pastas sob `%APPS_BASE%`.

## Instalar o Python

## Instalar o AWS CLI v2
Mesmo sem privilégios administrativos e com restrições severas, é possível instalar o AWS CLI v2 no Windows 11 utilizando um método de extração administrativa (msiexec /a). Isso permite "instalar" o software em uma pasta de usuário sem modificar o registro do Windows ou diretórios de sistema.

Para maiores informações, consulte:
- Documentação de instalação: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
- Instalador: https://awscli.amazonaws.com/AWSCLIV2.msi

Executar a instalação, direcionando o local de instalação para `%APPS_BASE%`:
  ```
  msiexec /a "AWSCLIV2.msi" /qb TARGETDIR="%APPS_BASE%"
  ```

Esse comando irá criar o diretório `%APPS_BASE%\Amazon\AWSCLIV2` e extrair o AWS CLI v2 para lá.

Ao final da instalação, você deve:
- Adicionar esse diretório ao PATH do Windows (Editar as variáveis de ambiente para sua conta).
- Mover o diretório `C:\Users\<USUÁRIO>\AppData\Local\Microsoft\WindowsApps` para último lugar no PATH


## Google Cloud CLI
O Google Cloud CLI requer o Python. Antes de instalar o Google Cloud CLI, definir a variável de ambiente ´CLOUDSDK_PYTHON` no "Editar as variáveis de ambiente para sua conta" apontando para `D:\<USUÁRIO>\Apps\Python\bin\python.exe`.

Faça download do instalador do Google Cloud CLI a partir de https://docs.cloud.google.com/sdk/docs/install-sdk?hl=pt-br#latest-version.

Executar a instalação, direcionando o local de instalação para `%APPS_BASE%`:
  ```
  GoogleCloudSDKInstaller.exe /singleuser /D="%APPS_BASE%\Google\Cloud SDK"
  ```

Esse comando irá: 
- Criar o diretório `%APPS_BASE%\Google\Cloud SDK` e extrair o Google Cloud CLI para lá.
- Adicionar `D:\<USUÁRIO>\Apps\Google\Cloud SDK\google-cloud-sdk\bin` ao PATH do Windows.

Ao final da instalação, você deve:
- Mover o diretório `C:\Users\<USUÁRIO>\AppData\Local\Microsoft\WindowsApps` para último lugar no PATH
  

# Junções de diretórios do Windows

## Motivação
Permitir que os aplicativos mantenham seus arquivos de configuração sob `C:\Users\<USUÁRIO>`, ao mesmo tempo que possamos manter o `$HOME` do Git Bash apontando para `D:\%USERNAME%\home`.

## Junções de diretórios

As junções de diretórios devem ser criadas de forma que os diretórios de configurações sejam criados pelos aplicativos e utilitários em `%USERPROFILE%` (ou seja, `C:\Users\%USERNAME%`) ao mesmo tempo que 

| Origem (`%USERPROFILE%`)   | Destino (`$HOME`=`D:\%USERNAME%\home`) |
| ------------------------ | ---------------------------------------- |
| `C:\Users\%USERNAME%\.aws` | `D:\%USERNAME%\home\.config\aws`       |
| `C:\Users\%USERNAME%\.ssh` | `D:\%USERNAME%\home\.ssh`              |




Considere que tenho um Git Bash instalado em meu computador, no qual o `$HOME` aponta para `D:\%USERNAME%\home`, e o meu `$HOME\.bashrc` contém os seguintes comandos:
```
# Configuração de diretórios padrão XDG (X Desktop Group)
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
```

**Contexto**: Eu quero que diretórios e arquivos iniciados por ponto (tais como `.aws`, `.node`, `.vim` e outros), pertencentes ferramentas instaladas no Windows sejam criados normalmente pelos instaladores dessas ferramentas em `C:\Users\%USERNAME%` (p.ex, `C:\Users\%USERNAME%\.aws`, `C:\Users\%USERNAME%\.node`, `C:\Users\%USERNAME%\.vim` e outros), mas meu objetivo criar links simbólicos para diretórios sob o `$HOME` do meu Git Bash. Vou mencionar o nome de uma ferramenta específica e, eventualmente, alguma informação adicional sobre ela, e quero que você apresente os comandos `mkjunction /d` do Windows devem ser executados para que eu possa atingir meu objetivo.

**Ferramenta**: AWS CLI v2, sendo que farei login usando `aws sso login` , e não um arquivo estático com credenciais.