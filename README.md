# Automatize a infraestrutura (Pop!_OS Edition)

Este script automatiza a configuração de um ambiente de desenvolvimento completo e moderno, otimizado para o **Pop!_OS 24.04 LTS**.

### Requisitos do SO

- Pop!_OS 24.04 (LTS)

### O que o script configura?

#### 🐚 Terminal de Alta Performance
- **ZSH & Oh My Zsh:** Shell padrão com plugins essenciais (`autosuggestions`, `syntax-highlighting`, `docker`, `maven`, `git`, etc.).
- **Powerlevel10k:** Tema visual configurado automaticamente através do arquivo `.p10k.zsh` injetado no sistema.
- **Fontes MesloLGS NF:** Instalação automática das fontes necessárias para suporte a ícones no terminal.

#### 🛠️ Toolchain de Desenvolvimento
- **Java & Build:** Java BellSoft Liberica (Última LTS) e Maven (Última estável) via **SDKMAN**.
- **Frontend:** Node.js v24 via **NVM** e Angular CLI.
- **JetBrains Toolbox:** Centralizador de IDEs instalado em `~/.local/opt/jetbrains-toolbox`.

#### 🐳 Infraestrutura Docker
- **Docker Engine:** Formato moderno (`.sources`) com plugins `buildx` e `compose`.
- **Otimização:** Configuração de limites de logs e redes internas via `daemon.json`.

#### 📦 Aplicativos (Flatpak)
- **Sublime Text:** Instalado e configurado como editor de texto padrão.
- **Postman:** Ferramenta completa para testes de API.

### Como instalar

```bash
cd ~/Downloads
wget https://github.com/edwarddn/ambiente-ubuntu/raw/main/instala-tudo.sh
chmod +x instala-tudo.sh
sudo ./instala-tudo.sh
```

---
*Nota: O script utiliza o contexto do usuário logado (`SUDO_USER`) para garantir que as configurações de diretórios e variáveis de ambiente (SDKMAN/NVM/ZSH) fiquem vinculadas corretamente ao seu perfil.*
