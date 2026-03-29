# Automatize a infraestrutura (Pop!_OS & Ubuntu Edition)

Este script automatiza a configuração de um ambiente de desenvolvimento completo e moderno, focado em produtividade e arquitetura limpa.

### Requisitos do SO

- **Pop!_OS 24.04 LTS** (Recomendado - Suporte nativo completo)
- **Ubuntu 24.04 LTS** (Veja a nota abaixo sobre Flatpak)

> ⚠️ **Nota para usuários de Ubuntu:** O Ubuntu não traz o suporte a Flatpak habilitado por padrão. Para que o script funcione corretamente no Ubuntu, você deve configurar o Flatpak e o repositório Flathub previamente:
> ```bash
> sudo apt update && sudo apt install flatpak
> flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
> ```

### O que o script configura?

#### 🐚 Terminal de Alta Performance
- **ZSH & Oh My Zsh:** Shell padrão com plugins essenciais (`autosuggestions`, `syntax-highlighting`, `docker`, `maven`, `git`, etc.).
- **Powerlevel10k:** Tema visual configurado automaticamente através do arquivo `.p10k.zsh` injetado no sistema.
- **Fontes MesloLGS NF:** Instalação automática das fontes necessárias para suporte a ícones no terminal.

#### 🛠️ Toolchain de Desenvolvimento
- **Java & Build:** Java BellSoft Liberica **v25 (LTS)** e Maven (Última estável) via **SDKMAN**.
- **Frontend:** Node.js **v24 (LTS)** via **NVM** e Angular CLI.
- **JetBrains Toolbox:** Centralizador de IDEs instalado em `~/.local/opt/jetbrains-toolbox`.

#### 🐳 Infraestrutura Docker
- **Docker Engine:** Formato moderno (`.sources`) com plugins `buildx` e `compose`.
- **Otimização:** Configuração de limites de logs e redes internas via `daemon.json`.

#### 📦 Aplicativos (Flatpak)
- **Sublime Text:** Instalado e configurado como editor de texto padrão.
- **Postman:** Ferramenta completa para testes de API.

### Como instalar (One-Liner)

Basta rodar o comando abaixo no seu terminal:

```bash
curl -sL https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main/instala-tudo.sh | sudo bash
```

Em execuções sem TTY interativo disponível, o script agora assume a instalação completa automaticamente para que o `one-liner` funcione corretamente.

Se quiser executar de forma explícita, use:

```bash
curl -sL https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main/instala-tudo.sh | sudo bash -s -- --install
```

Para remoção completa:

```bash
curl -sL https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main/instala-tudo.sh | sudo bash -s -- --remove
```

---
*Nota: O script utiliza o contexto do usuário logado (`SUDO_USER`) para garantir que as configurações de diretórios e variáveis de ambiente (SDKMAN/NVM/ZSH) fiquem vinculadas corretamente ao seu perfil.*
