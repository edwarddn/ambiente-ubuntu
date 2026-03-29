#!/bin/bash

set -e

# --- Definições de Versão e URLs ---
JAVA_VERSION_PREFIX="25.*-librca"
NODE_VERSION="24"
REPO_URL="https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main"

# --- Helpers de Arquitetura ---

user_home() {
  getent passwd "$SUDO_USER" | cut -d: -f6
}

run_as_user() {
  sudo -u "$SUDO_USER" env HOME="$USER_HOME" bash -c "$1"
}

source_sdkman() {
  echo "source \"$USER_HOME/.sdkman/bin/sdkman-init.sh\""
}

source_nvm() {
  echo "export NVM_DIR=\"$USER_HOME/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\""
}

remove_user_path() {
  rm -rf "$USER_HOME/$1"
}

# --- Módulos de Instalação ---

instalarZsh() {
  echo 'Instalando e configurando ZSH...'
  apt install -y zsh
  chsh -s $(which zsh) "$SUDO_USER"

  echo 'Instalando Oh My Zsh...'
  run_as_user 'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

  echo 'Instalando tema Powerlevel10k...'
  run_as_user 'git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k'
  
  echo 'Configurando Powerlevel10k no .zshrc...'
  run_as_user "sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/g' ~/.zshrc"
  
  echo 'Baixando configuração personalizada do Powerlevel10k...'
  run_as_user "wget $REPO_URL/.p10k.zsh -O ~/.p10k.zsh"
  # Garante que o .zshrc carregue o .p10k.zsh no topo
  run_as_user "sed -i '1i[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' ~/.zshrc"

  echo 'Instalando plugins adicionais do ZSH...'
  run_as_user 'git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
  run_as_user 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

  echo 'Configurando plugins no .zshrc...'
  run_as_user "sed -i 's/plugins=(git)/plugins=(git docker gradle mvn spring extract sudo zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc"
}

removerZsh() {
  echo 'Removendo ZSH e voltando para o Bash...'
  chsh -s "$(which bash)" "$SUDO_USER" || true
  remove_user_path ".oh-my-zsh"
  rm -f "$USER_HOME/.zshrc"
  rm -f "$USER_HOME/.p10k.zsh"
  apt remove -y zsh || true
}

instalarFontes() {
  echo 'Baixando e instalando fontes MesloLGS NF...'
  local FONT_DIR="$USER_HOME/.local/share/fonts"
  run_as_user "mkdir -p $FONT_DIR"
  
  local BASE_FONT_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"
  
  run_as_user "wget $BASE_FONT_URL/MesloLGS%20NF%20Regular.ttf -P $FONT_DIR/"
  run_as_user "wget $BASE_FONT_URL/MesloLGS%20NF%20Bold.ttf -P $FONT_DIR/"
  run_as_user "wget $BASE_FONT_URL/MesloLGS%20NF%20Italic.ttf -P $FONT_DIR/"
  run_as_user "wget $BASE_FONT_URL/MesloLGS%20NF%20Bold%20Italic.ttf -P $FONT_DIR/"
  
  run_as_user "fc-cache -f"
}

removerFontes() {
  echo 'Removendo fontes MesloLGS NF...'
  rm -f "$USER_HOME/.local/share/fonts/MesloLGS NF"*.ttf
  run_as_user "fc-cache -f" || true
}

instalarSdkman() {
  if [ ! -d "$USER_HOME/.sdkman" ]; then
    echo 'Instalando SDKMAN...'
    run_as_user 'curl -s "https://get.sdkman.io" | bash'
  fi
}

removerSdkman() {
  if [ -d "$USER_HOME/.sdkman" ]; then
    echo 'Removendo SDKMAN...'
    remove_user_path ".sdkman"
  fi
}

instalarJava() {
  instalarSdkman
  
  # Busca a versão estável mais recente da BellSoft Liberica que combine com o prefixo
  JAVA_VERSION=$(run_as_user "$(source_sdkman) && sdk list java | grep \"$JAVA_VERSION_PREFIX\" | grep -v '\-fx' | grep -v '\-ea' | head -n 1 | awk '{print \$NF}'")
  
  if [ -z "$JAVA_VERSION" ]; then
    echo "Erro: Java com prefixo $JAVA_VERSION_PREFIX não encontrado no SDKMAN."
    return 1
  fi

  echo "Instalando Java $JAVA_VERSION via SDKMAN..."
  run_as_user "$(source_sdkman) && sdk install java $JAVA_VERSION"
}

removerJava() {
  if [ -d "$USER_HOME/.sdkman/candidates/java" ]; then
    echo 'Removendo instalações de Java gerenciadas pelo SDKMAN...'
    run_as_user "find \"$USER_HOME/.sdkman/candidates/java\" -mindepth 1 -maxdepth 1 ! -name current -exec rm -rf {} +" || true
    rm -f "$USER_HOME/.sdkman/var/candidates/java/current" || true
  fi
}

instalarMaven() {
  instalarSdkman
  echo "Instalando a versão estável mais recente do Maven via SDKMAN..."
  run_as_user "$(source_sdkman) && sdk install maven"
}

removerMaven() {
  if [ -d "$USER_HOME/.sdkman/candidates/maven" ]; then
    echo 'Removendo instalações de Maven gerenciadas pelo SDKMAN...'
    run_as_user "find \"$USER_HOME/.sdkman/candidates/maven\" -mindepth 1 -maxdepth 1 ! -name current -exec rm -rf {} +" || true
    rm -f "$USER_HOME/.sdkman/var/candidates/maven/current" || true
  fi
}

instalarNode() {
  if [ ! -d "$USER_HOME/.nvm" ]; then
    echo 'Instalando NVM...'
    run_as_user 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
  fi
  echo "Instalando Node.js v$NODE_VERSION via NVM..."
  run_as_user "$(source_nvm) && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION"
}

removerNode() {
  if [ -d "$USER_HOME/.nvm" ]; then
    echo "Removendo Node.js v$NODE_VERSION..."
    run_as_user "$(source_nvm) && nvm deactivate >/dev/null 2>&1 || true; nvm uninstall $NODE_VERSION >/dev/null 2>&1 || true" || true
    remove_user_path ".nvm"
  fi
  remove_user_path ".npm"
}

instalarFirewall() {
  ufw enable
  ufw status verbose
}

removerFirewall() {
  ufw disable || true
  ufw status verbose || true
}

instalarJetBrainsToolbox() {
  if [ -d "$USER_HOME/.local/opt/jetbrains-toolbox" ]; then
    echo 'JetBrains Toolbox já instalado.'
    return
  fi

  echo 'Buscando versão mais recente do JetBrains Toolbox...'
  local API_URL="https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release"
  local DOWNLOAD_URL=$(curl -sL "$API_URL" | grep -Po '"linux":\{"link":"\K[^"]*')
  
  if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.3.1.31116.tar.gz"
  fi

  echo 'Instalando JetBrains Toolbox...'
  local INSTALL_DIR="$USER_HOME/.local/opt/jetbrains-toolbox"
  apt install -y libfuse2
  
  run_as_user "mkdir -p $INSTALL_DIR"
  run_as_user "curl -sL $DOWNLOAD_URL | tar -xz -C $INSTALL_DIR --strip-components=1"
  echo 'Iniciando Toolbox para configuração inicial...'
  run_as_user "$INSTALL_DIR/bin/jetbrains-toolbox &"
}

removerJetBrainsToolbox() {
  echo 'Removendo JetBrains Toolbox...'
  rm -rf "$USER_HOME/.local/opt/jetbrains-toolbox"
  rm -rf "$USER_HOME/.local/share/JetBrains/Toolbox"
  rm -f "$USER_HOME/.local/share/applications/jetbrains-toolbox.desktop"
}

instalarDocker() {
  if [ -f "/etc/apt/sources.list.d/docker.sources" ]; then
    echo 'O Docker já foi instalado'
  else
    echo 'Iniciando a instalação do Docker (formato moderno)...'
    apt update
    apt install -y ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    cat <<EOF > /etc/apt/sources.list.d/docker.sources
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    echo 'Configurando daemon.json do Docker...'
    mkdir -p /etc/docker
    cat <<EOF > /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "10"
  },
  "default-address-pools":
  [
    {
      "base": "10.17.0.0/16",
      "size": 24
    }
  ]
}
EOF
    systemctl restart docker || true
  fi
  usermod -aG docker "$SUDO_USER"
}

removerDocker() {
  if [ ! -f "/etc/apt/sources.list.d/docker.sources" ]; then
    echo 'O Docker não foi instalado'
  else
    echo 'Removendo Docker e configurações...'
    apt purge -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -f /etc/apt/keyrings/docker.asc
    rm -f /etc/apt/sources.list.d/docker.sources
    rm -f /etc/docker/daemon.json
  fi
  gpasswd -d "$SUDO_USER" docker >/dev/null 2>&1 || true
}

instalarFlatpaks() {
  echo 'Configurando suporte a Flatpak...'
  if ! command -v flatpak &> /dev/null; then
    apt install -y flatpak
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  fi

  echo 'Instalando apps via Flatpak...'
  flatpak install --assumeyes flathub com.sublimetext.three
  flatpak install --assumeyes flathub com.getpostman.Postman

  echo 'Baixando e configurando mimeapps.list...'
  local MIME_FILE="$USER_HOME/.config/mimeapps.list"
  run_as_user "mkdir -p \"$USER_HOME/.config\""
  run_as_user "wget $REPO_URL/mimeapps.list -O $MIME_FILE"
  run_as_user "sed -i 's/sublime-text_subl.desktop/com.sublimetext.three.desktop/g' $MIME_FILE"
}

removerFlatpaks() {
  echo 'Removendo Flatpaks...'
  flatpak uninstall --assumeyes com.sublimetext.three || true
  flatpak uninstall --assumeyes com.getpostman.Postman || true
  flatpak uninstall --unused --assumeyes || true
  rm -f "$USER_HOME/.config/mimeapps.list"
}

instalarAngularCli() {
  echo 'Instalando Angular CLI...'
  run_as_user "$(source_nvm) && npm install -g @angular/cli"
}

removerAngularCli() {
  echo 'Removendo Angular CLI...'
  run_as_user "$(source_nvm) && npm uninstall -g @angular/cli >/dev/null 2>&1 || true" || true
}

show_usage() {
  cat <<EOF
Uso: bash instala-tudo.sh --install
   ou bash instala-tudo.sh --remove

  --install  Executa a instalação completa do ambiente.
  --remove   Executa a remoção completa do ambiente.
EOF
}

MODE=""

for arg in "$@"; do
  case "$arg" in
    --install)
      if [ -n "$MODE" ] && [ "$MODE" != "install" ]; then
        echo "Erro: use apenas um modo por execução: --install ou --remove."
        exit 1
      fi
      MODE="install"
      ;;
    --remove)
      if [ -n "$MODE" ] && [ "$MODE" != "remove" ]; then
        echo "Erro: use apenas um modo por execução: --install ou --remove."
        exit 1
      fi
      MODE="remove"
      ;;
    --help|-h)
      show_usage
      exit 0
      ;;
    *)
      echo "Erro: argumento inválido '$arg'."
      show_usage
      exit 1
      ;;
  esac
done

# --- Orquestração Principal ---

instalar() {
  apt update
  apt upgrade -y
  
  echo 'Instalando ferramentas básicas (Git, Curl, Zip, Wget)...'
  apt install -y git curl zip unzip wget
  
  instalarZsh
  instalarFontes
  instalarJava
  instalarMaven
  instalarNode
  instalarFirewall
  instalarDocker
  instalarJetBrainsToolbox
  instalarFlatpaks
  instalarAngularCli
  echo "Ambiente configurado com sucesso! Reinicie para aplicar todas as mudanças."
}

remover() {
  removerAngularCli
  removerMaven
  removerJava
  removerSdkman
  removerNode
  removerZsh
  removerFontes
  removerFirewall
  removerDocker
  removerJetBrainsToolbox
  removerFlatpaks
  rm -f "$USER_HOME/.wget-hsts"
  apt autoremove -y
  echo "Ambiente removido. Reinicie o sistema."
}

# Verificação de segurança
if [ "$EUID" -ne 0 ]; then
  echo "Erro: Execute o script com sudo ou como root."
  exit 1
fi

# Tenta detectar o usuário real que chamou o sudo, mesmo em pipes
REAL_USER=${SUDO_USER:-$(logname 2>/dev/null || whoami)}

if [ -z "$REAL_USER" ] || [ "$REAL_USER" == "root" ]; then
  echo "Erro: Não foi possível detectar o usuário não-root. Use 'sudo bash script.sh'."
  exit 1
fi

# Exporta para ser usado pelas funções
SUDO_USER=$REAL_USER
USER_HOME=$(user_home)

if [ -z "$USER_HOME" ] || [ ! -d "$USER_HOME" ]; then
  echo "Erro: não foi possível localizar o diretório HOME de $SUDO_USER."
  exit 1
fi

echo "Olá, $SUDO_USER. Iniciando automação de ambiente para Pop!_OS 24.04..."

if [ -z "$MODE" ]; then
  echo "Erro: informe explicitamente um modo de execução."
  echo
  echo "Use --install para instalar o ambiente."
  echo "Use --remove para remover o ambiente."
  echo
  show_usage
  exit 1
fi

case "$MODE" in
  install) instalar ;;
  remove) remover ;;
esac
