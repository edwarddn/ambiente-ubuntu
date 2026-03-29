#!/bin/bash

set -e

# --- Definições de Versão (Pinned Versions) ---
JAVA_VERSION_PREFIX="25.*-librca"
NODE_VERSION="24"

# --- Helpers de Arquitetura ---

# Obtém o diretório onde o script está localizado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

run_as_user() {
  sudo -u "$SUDO_USER" bash -c "$1"
}

source_sdkman() {
  echo "source \"/home/$SUDO_USER/.sdkman/bin/sdkman-init.sh\""
}

source_nvm() {
  echo "export NVM_DIR=\"/home/$SUDO_USER/.nvm\" && [ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\""
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
  
  # Injetar a configuração do p10k se o arquivo existir no repositório
  if [ -f "$SCRIPT_DIR/.p10k.zsh" ]; then
    echo 'Injetando configuração personalizada do Powerlevel10k...'
    cp "$SCRIPT_DIR/.p10k.zsh" "/home/$SUDO_USER/"
    chown "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.p10k.zsh"
    # Garante que o .zshrc carregue o .p10k.zsh no topo
    run_as_user "sed -i '1i[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' ~/.zshrc"
  fi

  echo 'Instalando plugins adicionais do ZSH...'
  run_as_user 'git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions'
  run_as_user 'git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting'

  echo 'Configurando plugins no .zshrc...'
  run_as_user "sed -i 's/plugins=(git)/plugins=(git docker gradle mvn spring extract sudo zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc"
}

removerZsh() {
  echo 'Removendo ZSH e voltando para o Bash...'
  chsh -s $(which bash) "$SUDO_USER"
  rm -rf "/home/$SUDO_USER/.oh-my-zsh"
  rm -f "/home/$SUDO_USER/.zshrc"
  rm -f "/home/$SUDO_USER/.p10k.zsh"
  apt remove -y zsh
}

instalarFontes() {
  echo 'Instalando fontes MesloLGS NF...'
  local FONT_DIR="/home/$SUDO_USER/.local/share/fonts"
  run_as_user "mkdir -p $FONT_DIR"
  
  if [ -d "$SCRIPT_DIR/fonts" ]; then
    cp "$SCRIPT_DIR/fonts"/*.ttf "$FONT_DIR/"
    chown "$SUDO_USER:$SUDO_USER" "$FONT_DIR"/*.ttf
    run_as_user "fc-cache -f"
  else
    echo "Aviso: Pasta de fontes não encontrada em $SCRIPT_DIR/fonts"
  fi
}

removerFontes() {
  echo 'Removendo fontes MesloLGS NF...'
  rm -f "/home/$SUDO_USER/.local/share/fonts/MesloLGS NF"*.ttf
  run_as_user "fc-cache -f"
}

instalarSdkman() {
  if [ ! -d "/home/$SUDO_USER/.sdkman" ]; then
    echo 'Instalando SDKMAN...'
    run_as_user 'curl -s "https://get.sdkman.io" | bash'
  fi
}

removerSdkman() {
  if [ -d "/home/$SUDO_USER/.sdkman" ]; then
    echo 'Removendo SDKMAN...'
    rm -rf "/home/$SUDO_USER/.sdkman"
  fi
}

instalarJava() {
  instalarSdkman
  JAVA_VERSION=$(run_as_user "$(source_sdkman) && sdk list java | grep \"$JAVA_VERSION_PREFIX\" | grep -v '\-fx' | grep -v '\-ea' | head -n 1 | awk '{print \$NF}'")
  
  if [ -z "$JAVA_VERSION" ]; then
    echo "Erro: Java com prefixo $JAVA_VERSION_PREFIX não encontrado no SDKMAN."
    return 1
  fi

  echo "Instalando Java $JAVA_VERSION via SDKMAN..."
  run_as_user "$(source_sdkman) && sdk install java $JAVA_VERSION"
}

removerJava() {
  if [ -d "/home/$SUDO_USER/.sdkman" ]; then
    # Busca todas as versões da Liberica instaladas para remover
    JAVA_VERSIONS=$(run_as_user "$(source_sdkman) && sdk list java | grep 'installed' | grep 'librca' | awk '{print \$NF}'")
    
    if [ ! -z "$JAVA_VERSIONS" ]; then
      for ver in $JAVA_VERSIONS; do
        echo "Removendo Java $ver..."
        run_as_user "$(source_sdkman) && sdk uninstall java $ver"
      done
    fi
  fi
}

instalarMaven() {
  instalarSdkman
  echo "Instalando a versão estável mais recente do Maven via SDKMAN..."
  run_as_user "$(source_sdkman) && sdk install maven"
}

removerMaven() {
  if [ -d "/home/$SUDO_USER/.sdkman" ]; then
    MAVEN_VERSION=$(run_as_user "$(source_sdkman) && sdk list maven | grep 'installed' | head -n 1 | awk '{print \$NF}'")
    if [ ! -z "$MAVEN_VERSION" ]; then
      echo "Removendo Maven $MAVEN_VERSION..."
      run_as_user "$(source_sdkman) && sdk uninstall maven $MAVEN_VERSION"
    fi
  fi
}

instalarNode() {
  if [ ! -d "/home/$SUDO_USER/.nvm" ]; then
    echo 'Instalando NVM...'
    run_as_user 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
  fi
  echo "Instalando Node.js v$NODE_VERSION via NVM..."
  run_as_user "$(source_nvm) && nvm install $NODE_VERSION && nvm use $NODE_VERSION && nvm alias default $NODE_VERSION"
}

removerNode() {
  if [ -d "/home/$SUDO_USER/.nvm" ]; then
    echo "Removendo Node.js v$NODE_VERSION..."
    run_as_user "$(source_nvm) && nvm uninstall $NODE_VERSION"
    rm -rf "/home/$SUDO_USER/.nvm"
  fi
}

instalarFirewall() {
  ufw enable
  ufw status verbose
}

removerFirewall() {
  ufw disable
  ufw status verbose
}

instalarJetBrainsToolbox() {
  if [ -d "/home/$SUDO_USER/.local/opt/jetbrains-toolbox" ]; then
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
  local INSTALL_DIR="/home/$SUDO_USER/.local/opt/jetbrains-toolbox"
  apt install -y libfuse2
  
  run_as_user "mkdir -p $INSTALL_DIR"
  run_as_user "curl -sL $DOWNLOAD_URL | tar -xz -C $INSTALL_DIR --strip-components=1"
  echo 'Iniciando Toolbox para configuração inicial...'
  run_as_user "$INSTALL_DIR/bin/jetbrains-toolbox &"
}

removerJetBrainsToolbox() {
  echo 'Removendo JetBrains Toolbox...'
  rm -rf "/home/$SUDO_USER/.local/opt/jetbrains-toolbox"
  rm -rf "/home/$SUDO_USER/.local/share/JetBrains/Toolbox"
  rm -f "/home/$SUDO_USER/.local/share/applications/jetbrains-toolbox.desktop"
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
}

instalarFlatpaks() {
  echo 'Instalando apps via Flatpak...'
  flatpak install --assumeyes flathub com.sublimetext.three
  flatpak install --assumeyes flathub com.getpostman.Postman

  if [ -f "$SCRIPT_DIR/mimeapps.list" ]; then
    rm -f "/home/$SUDO_USER/.config/mimeapps.list"
    cp "$SCRIPT_DIR/mimeapps.list" "/home/$SUDO_USER/.config/"
    chown "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/mimeapps.list"
    sed -i 's/sublime-text_subl.desktop/com.sublimetext.three.desktop/g' "/home/$SUDO_USER/.config/mimeapps.list"
  fi
}

removerFlatpaks() {
  echo 'Removendo Flatpaks...'
  flatpak uninstall --assumeyes com.sublimetext.three
  flatpak uninstall --assumeyes com.getpostman.Postman
  flatpak uninstall --unused --assumeyes
  rm -f "/home/$SUDO_USER/.config/mimeapps.list"
}

instalarAngularCli() {
  echo 'Instalando Angular CLI...'
  run_as_user "$(source_nvm) && npm install -g @angular/cli"
}

removerAngularCli() {
  echo 'Removendo Angular CLI...'
  run_as_user "$(source_nvm) && npm uninstall -g @angular/cli"
}

# --- Orquestração Principal ---

instalar() {
  apt update
  apt upgrade -y
  
  echo 'Instalando ferramentas básicas (Git, Curl, Zip)...'
  apt install -y git curl zip unzip
  
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
  apt update
  apt upgrade -y
  apt autoremove -y
  echo "Ambiente removido. Reinicie o sistema."
}

# Verificação de segurança
if [ "$EUID" -ne 0 ]; then
  echo "Erro: Execute o script com sudo para que ele possa gerenciar pacotes e permissões."
  exit 1
fi

if [ -z "$SUDO_USER" ]; then
  echo "Erro: SUDO_USER não detectado. Use 'sudo ./instala-tudo.sh'."
  exit 1
fi

echo "Olá, $SUDO_USER. Iniciando automação de ambiente para Pop!_OS 24.04..."

while true; do
  read -p "Deseja instalar o ambiente completo? [s/n] " sn
  case $sn in
    [Ss]*) instalar; break ;;
    [Nn]*) break ;;
    *) echo "Responda sim[s] ou não[n]." ;;
  esac
done

while true; do
  read -p "Deseja remover o ambiente (limpeza completa)? [s/n] " sn
  case $sn in
    [Ss]*) remover; break ;;
    [Nn]*) break ;;
    *) echo "Responda sim[s] ou não[n]." ;;
  esac
done
