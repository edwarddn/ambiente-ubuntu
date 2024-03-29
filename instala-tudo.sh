#!/bin/bash

set -e

JAVA_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.1.0/graalvm-ce-java17-linux-amd64-22.1.0.tar.gz
JAVA_FILE=graalvm-ce-java17-linux-amd64-22.1.0.tar.gz
JAVA_PATH=graalvm-ce-java17-22.1.0

MAVEN_URL=https://dlcdn.apache.org/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
MAVEN_FILE=apache-maven-3.8.6-bin.tar.gz
MAVEN_PATH=apache-maven-3.8.6

NODE_URL=https://nodejs.org/dist/v16.16.0/node-v16.16.0-linux-x64.tar.xz
NODE_FILE=node-v16.16.0-linux-x64.tar.xz
NODE_PATH=node-v16.16.0-linux-x64

instalarJava() {
  if [ -d "/opt/java" ]; then
    echo 'O JAVA já foi instalado'
  else
    echo 'Iniciando a instalação do JAVA'

    cd /opt/

    wget $JAVA_URL

    tar -xzvf $JAVA_FILE
    ln -s /opt/$JAVA_PATH java
    ln -s /opt/java/bin/java /usr/bin/java
    ln -s /opt/java/bin/javac /usr/bin/javac
    
    ln -s /opt/java/bin/js /usr/bin/js
    ln -s /opt/java/bin/lli /usr/bin/lli
    ln -s /opt/java/bin/gu /usr/bin/gu

    echo '#PATH for Java' >/etc/profile.d/java.sh
    echo 'JAVA_HOME=/opt/java' >>/etc/profile.d/java.sh
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >>/etc/profile.d/java.sh

    echo 'Instalação do Java concluida com sucesso'
  fi
}

removerJava() {
  if [ ! -d "/opt/java" ]; then
    echo 'O JAVA não foi instalado'
  else
    echo 'Removendo a instalação do JAVA'

    cd /opt/

    rm -f /opt/$JAVA_FILE
    rm -rf /opt/$JAVA_PATH

    unlink java
    unlink /usr/bin/java
    unlink /usr/bin/javac
    
    unlink /usr/bin/js
    unlink /usr/bin/lli
    unlink /usr/bin/gu

    rm -f /etc/profile.d/java.sh

    echo 'Instalação do Java foi removida com sucesso'
  fi
}

instalarMaven() {
  if [ -d "/opt/maven" ]; then
    echo 'O Maven já foi instalado'
  else
    echo 'Iniciando a instalação do Maven'

    cd /opt/

    wget $MAVEN_URL

    tar -xzvf $MAVEN_FILE

    ln -s /opt/$MAVEN_PATH maven
    ln -s /opt/maven/bin/mvn /usr/bin/mvn

    echo '#PATH for Maven' >/etc/profile.d/maven.sh
    echo 'M2_HOME=/opt/maven' >>/etc/profile.d/maven.sh
    echo 'export PATH=$PATH:$M2_HOME/bin' >>/etc/profile.d/maven.sh

    echo 'Instalação do Maven concluida com sucesso'
  fi
}

removerMaven() {
  if [ ! -d "/opt/maven" ]; then
    echo 'O Maven não foi instalado'
  else
    echo 'Removendo a instalação do Maven'

    cd /opt/

    rm -f /opt/$MAVEN_FILE
    rm -rf /opt/$MAVEN_PATH

    unlink maven
    unlink /usr/bin/mvn

    rm -f /etc/profile.d/maven.sh

    echo 'Instalação do Maven foi removida com sucesso'
  fi
}

instalarNode() {
  if [ -d "/opt/node" ]; then
    echo 'O node já foi instalado'
  else
    echo 'Iniciando a instalação do node'

    cd /opt/

    wget $NODE_URL

    tar -Jxvf $NODE_FILE
    ln -s /opt/$NODE_PATH node

    ln -s /opt/node/bin/node /usr/bin/node
    ln -s /opt/node/bin/npm /usr/bin/npm
    ln -s /opt/node/bin/npx /usr/bin/npx

    echo '# Nodejs' >/etc/profile.d/node.sh
    echo 'export PATH=/opt/node/bin:$PATH' >>/etc/profile.d/node.sh

    echo 'Instalação do node concluida com sucesso'
  fi
}

removerNode() {
  if [ ! -d "/opt/node" ]; then
    echo 'O node não foi instalado'
  else
    echo 'Removendo a instalação do node'

    cd /opt/

    rm -f /opt/$NODE_FILE
    rm -rf /opt/$NODE_PATH
    unlink node

    unlink /usr/bin/node
    unlink /usr/bin/npm
    unlink /usr/bin/npx

    rm -f /etc/profile.d/node.sh

    echo 'Instalação do node foi removida com sucesso'
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

instalarIntellij() {
  snap install intellij-idea-ultimate --classic
}

removerIntellij() {
  snap remove intellij-idea-ultimate
}

instalarDatagrip() {
  snap install datagrip --classic
}

removerDatagrip() {
  snap remove datagrip
}

instalarGit() {
  apt install -y git
}

removerGit() {
  apt remove -y git
}

instalarFlatpak() {
  apt install -y flatpak
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  flatpak install --assumeyes flathub com.syntevo.SmartGit
}

removerFlatpak() {
  if [ -f "/bin/flatpak" ]; then
    flatpak remove --assumeyes com.syntevo.SmartGit
    flatpak remove --unused --assumeyes
  fi
  apt remove -y flatpak
}

instalarFontsMs() {
  apt install -y ttf-mscorefonts-installer
}

removerFontsMs() {
  apt remove -y ttf-mscorefonts-installer
}

instalarDocker() {
  if [ -f "/etc/apt/sources.list.d/docker.list" ]; then
    echo 'O Docker já foi instalado'
  else
    apt install -y ca-certificates curl gnupg lsb-release

    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  fi
  usermod -aG docker $SUDO_USER
}

removerDocker() {
  if [ ! -f "/etc/apt/sources.list.d/docker.list" ]; then
    echo 'O Docker não foi instalado'
  else
    apt purge -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    rm -rf /var/lib/docker
    rm -rf /var/lib/containerd
    rm -rf /etc/apt/keyrings
    rm -f /etc/apt/sources.list.d/docker.list
  fi
}

instalarSublime() {
  snap install sublime-text --classic

  rm -f '/home/'$SUDO_USER'/.config/mimeapps.list'
  wget https://github.com/edwarddn/ambiente-ubuntu/raw/main/mimeapps.list -P '/home/'$SUDO_USER'/.config/'
  chown $SUDO_USER:$SUDO_USER '/home/'$SUDO_USER'/.config/mimeapps.list'
}

removerSublime() {
  snap remove sublime-text
  rm -f '/home/'$SUDO_USER'/.config/mimeapps.list'
}

instalarPostman() {
  snap install postman
}

removerPostman() {
  snap remove postman
}

instalarCode() {
  snap install code --classic
}

removerCode() {
  snap remove code
}

instalarAngularCli() {
  if [ ! -d "/opt/node" ]; then
    echo 'O node não foi instalado'
  else
    npm install -g @angular/cli
  fi
}

removerAngularCli() {
  if [ ! -d "/opt/node" ]; then
    echo 'O node não foi instalado'
  else
    npm uninstall -g @angular/cli
    npm cache clean --force
  fi
}

instalarTheme() {
  sudo -u $SUDO_USER echo "[legacy/profiles:]" >./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "default='d1099164-5230-4164-a712-197838e23d61'" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "list=['b1dcc9dd-5262-4d8d-a863-c897e6d979b9', 'd1099164-5230-4164-a712-197838e23d61']" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "[legacy/profiles:/:d1099164-5230-4164-a712-197838e23d61]" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "background-color='rgb(35,34,34)'" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "background-transparency-percent=1" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "cursor-shape='block'" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "default-size-columns=90" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "default-size-rows=22" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "foreground-color='rgb(196,193,193)'" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "palette=['rgb(46,52,54)', 'rgb(204,0,0)', 'rgb(34,209,139)', 'rgb(196,160,0)', 'rgb(51,142,250)', 'rgb(117,80,123)', 'rgb(6,152,154)', 'rgb(211,215,207)', 'rgb(85,87,83)', 'rgb(239,41,41)', 'rgb(138,226,52)', 'rgb(252,233,79)', 'rgb(114,159,207)', 'rgb(173,127,168)', 'rgb(52,226,226)', 'rgb(238,238,236)']" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "use-theme-colors=false" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "use-theme-transparency=false" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "use-transparent-background=true" >>./terminal_jafidelis_theme.txt
  sudo -u $SUDO_USER echo "visible-name='personal'" >>./terminal_jafidelis_theme.txt

  RUID=$(who | awk 'FNR == 1 {print $1}')
  RUSER_UID=$(id -u ${RUID})
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" dconf load /org/gnome/terminal/ <./terminal_jafidelis_theme.txt

  rm -f ./terminal_jafidelis_theme.txt

  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 28
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.shell.extensions.ding icon-size 'small'
}

removerTheme() {
  sudo -u $SUDO_USER echo "[legacy/profiles:]" >./terminal_original_theme.txt
  sudo -u $SUDO_USER echo "default='b1dcc9dd-5262-4d8d-a863-c897e6d979b9'" >>./terminal_original_theme.txt
  sudo -u $SUDO_USER echo "list=['b1dcc9dd-5262-4d8d-a863-c897e6d979b9']" >>./terminal_original_theme.txt

  RUID=$(who | awk 'FNR == 1 {print $1}')
  RUSER_UID=$(id -u ${RUID})
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" dconf load /org/gnome/terminal/ <./terminal_original_theme.txt

  rm -f ./terminal_original_theme.txt

  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings reset org.gnome.desktop.interface color-scheme
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings reset org.gnome.shell.extensions.dash-to-dock dash-max-icon-size
  sudo -u $SUDO_USER DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${RUSER_UID}/bus" gsettings reset org.gnome.shell.extensions.ding icon-size
}

instalarCustomShell() {
  rm -f '/home/'$SUDO_USER'/.bashrc'
  wget https://raw.githubusercontent.com/edwarddn/ambiente-ubuntu/main/.bashrc -P '/home/'$SUDO_USER'/'
  chown $SUDO_USER:$SUDO_USER '/home/'$SUDO_USER'/.bashrc'
}

removerCustomShell() {
  rm -f '/home/'$SUDO_USER'/.bashrc'
  cp '/etc/skel/.bashrc' '/home/'$SUDO_USER'/'
  chown $SUDO_USER:$SUDO_USER '/home/'$SUDO_USER'/.bashrc'
}

instalar() {
  apt update
  apt upgrade -y
  instalarJava
  instalarMaven
  instalarNode
  instalarFirewall
  instalarGit
  instalarDocker
  instalarIntellij
  instalarDatagrip
  instalarSublime
  instalarPostman
  instalarCode
  instalarFlatpak
  instalarFontsMs
  instalarAngularCli
  instalarTheme
  instalarCustomShell
  reboot
}

remover() {
  removerAngularCli
  removerFlatpak
  removerJava
  removerMaven
  removerNode
  removerFirewall
  removerGit
  removerDocker
  removerIntellij
  removerDatagrip
  removerSublime
  removerPostman
  removerCode
  removerFontsMs
  removerTheme
  removerCustomShell
  apt update
  apt upgrade -y
  apt autoremove -y
  reboot
}

if [ "$EUID" -ne 0 ]; then
  echo "Execute o script com sudo"
  exit
fi

echo 'Olá,' $SUDO_USER

while true; do
  read -p "Deseja instalar? [s/n] " sn
  case $sn in
  [Ss]*)
    instalar
    break
    ;;
  [Nn]*) break ;;
  *) echo "Responda sim[s] ou não[n]." ;;
  esac
done

while true; do
  read -p "Deseja remover? [s/n] " sn
  case $sn in
  [Ss]*)
    remover
    break
    ;;
  [Nn]*) break ;;
  *) echo "Responda sim[s] ou não[n]." ;;
  esac
done
