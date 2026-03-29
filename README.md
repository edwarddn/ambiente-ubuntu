# Ambiente Ubuntu

Script para preparar uma máquina nova com um ambiente de desenvolvimento opinativo em Pop!_OS 24.04 ou Ubuntu 24.04.

Se você quer subir seu setup pessoal rápido, sem configurar tudo manualmente, esse repositório foi feito para isso. A ideia é simples: rodar um comando, instalar o essencial e deixar o terminal, Java, Node, Docker e algumas ferramentas prontas para uso.

## Para quem é

Este script faz sentido se você:

- acabou de instalar o sistema e quer montar seu ambiente do zero;
- usa Java, Maven, Node, Angular e Docker no dia a dia;
- quer Zsh com Oh My Zsh e Powerlevel10k já configurados;
- prefere um setup pronto, mesmo que ele reflita escolhas específicas deste projeto.

Se você quer controle fino de cada pacote e de cada arquivo de configuração, melhor revisar o script antes de executar.

## Premissa do projeto

Este script foi pensado para uso em uma máquina recém-instalada.

Ele assume uma base mínima do sistema operacional, como pacotes que já podem vir no Pop!_OS ou no Ubuntu, e monta por cima um ambiente de desenvolvimento pessoal. A ideia não é administrar tudo que existe na máquina. A ideia é preparar rapidamente o que este projeto considera parte do ambiente de trabalho.

Por isso, o `--remove` não tenta "voltar o sistema ao estado de fábrica". Ele desfaz principalmente o que este script adicionou como toolchain, apps e customizações de terminal.

## O que o script instala e configura

### Base do sistema

- atualiza os índices do APT e executa `apt upgrade -y`;
- instala ferramentas básicas: `git`, `curl`, `zip`, `unzip` e `wget`;
- instala `flatpak`, se necessário.

Esses itens fazem parte da base esperada para o ambiente funcionar. Alguns deles podem já existir no sistema, especialmente em instalações padrão do Pop!_OS.

### Ambiente criado pelo script

- habilita e configura o Docker usando o repositório oficial;
- habilita o `ufw`;
- instala `zsh`;
- instala Oh My Zsh;
- instala o tema Powerlevel10k;
- baixa o arquivo [`.p10k.zsh`](./.p10k.zsh);
- adiciona plugins úteis no `.zshrc`;
- instala as fontes MesloLGS NF em `~/.local/share/fonts`;
- instala SDKMAN;
- instala Java BellSoft Liberica compatível com o prefixo definido no script;
- instala Maven via SDKMAN;
- instala NVM;
- instala Node.js `v24`;
- instala Angular CLI globalmente;
- instala JetBrains Toolbox em `~/.local/opt/jetbrains-toolbox`;
- instala Sublime Text e Postman via Flatpak;
- grava o arquivo `~/.config/mimeapps.list`.

## O que muda na sua máquina

Na primeira execução, o script altera tanto o sistema quanto o seu usuário:

- troca o shell padrão do usuário para `zsh`;
- cria e remove arquivos dentro do seu `HOME`;
- adiciona seu usuário ao grupo `docker`;
- escreve arquivos em `/etc/apt`, `/etc/docker` e outras áreas do sistema;
- instala software por APT, SDKMAN, NVM e Flatpak.

Por isso, não trate esse script como algo neutro. Ele automatiza um setup real.

## Requisitos

- Pop!_OS 24.04 LTS ou Ubuntu 24.04 LTS;
- acesso a `sudo`;
- internet durante a instalação;
- execução a partir de um usuário normal, usando `sudo`.

O script tenta descobrir o `HOME` real do usuário que chamou o `sudo`, então o uso esperado é sempre com modo explícito:

```bash
curl -sL https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main/instala-tudo.sh | sudo bash -s -- --install
```

## Primeira execução

Se esta é sua primeira vez usando o script, faça nesta ordem:

1. Leia o arquivo [instala-tudo.sh](./instala-tudo.sh).
2. Confirme se as escolhas do projeto fazem sentido para a sua máquina.
3. Execute a instalação com `--install`.
4. Reinicie a sessão ou a máquina ao final.

Se você executar o script sem `--install` ou `--remove`, ele encerra com erro e mostra a forma correta de uso.

## Remoção

Para executar a remoção:

```bash
curl -sL https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main/instala-tudo.sh | sudo bash -s -- --remove
```

O `--remove` desfaz o ambiente criado pelo script, incluindo itens como:

- `~/.nvm`;
- `~/.npm`;
- `~/.oh-my-zsh`;
- `~/.sdkman`;
- `~/.zshrc`;
- `~/.p10k.zsh`;
- fontes MesloLGS NF;
- JetBrains Toolbox;
- `~/.config/mimeapps.list`;
- `~/.wget-hsts`;
- apps instalados por Flatpak neste fluxo;
- configuração do Docker criada pelo script.

Alguns diretórios genéricos, como `~/.local` e `~/.cache`, podem continuar existindo, porque não pertencem exclusivamente a este projeto.

O `--remove` não foi desenhado para remover a base mínima do sistema operacional. Em outras palavras: ele tenta tirar Java, Maven, Node, Angular CLI, JetBrains Toolbox, `zsh`, customizações de terminal, fontes e apps instalados por este fluxo, mas não tenta desmontar o sistema base que já pode vir pronto na distribuição.

## Observações importantes

- O script usa `set -e`, então falhas não tratadas interrompem a execução.
- O script não pergunta interativamente o que fazer. Você precisa escolher explicitamente `--install` ou `--remove`.
- A remoção usa `apt autoremove -y` no final. Revise isso com atenção antes de usar `--remove` em uma máquina já personalizada.
- O projeto é opinativo. Ele não tenta servir todos os perfis de uso.

## Arquivos deste repositório

- [instala-tudo.sh](./instala-tudo.sh): script principal de instalação e remoção.
- [mimeapps.list](./mimeapps.list): associações de aplicativos do usuário.
- [fonts](./fonts): assets auxiliares do projeto.

## Resumo curto

Se você quer preparar uma máquina nova no mesmo estilo deste ambiente, rode o script.

Se você não quer que um script altere shell, Docker, Flatpak, Java, Node e arquivos do seu `HOME`, não rode sem antes revisar.
