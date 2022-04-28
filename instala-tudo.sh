#!/bin/bash

set -e

instalarJava() {

	if [ -d "/opt/java" ]; then
		echo 'O JAVA já foi instalado'
	else
		echo 'Iniciando a instalação do JAVA'

		cd /opt/

		wget https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_linux-x64_bin.tar.gz

		tar -xzvf openjdk-17.0.2_linux-x64_bin.tar.gz
		ln -s /opt/jdk-17.0.2 java
		ln -s /opt/java/bin/java /usr/bin/java
		ln -s /opt/java/bin/javac /usr/bin/javac

		echo '#PATH for Java' > /etc/profile.d/java.sh
		echo 'JAVA_HOME=/opt/java' >> /etc/profile.d/java.sh
		echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile.d/java.sh

		echo 'Instalação do Java concluida com sucesso'
	fi
}

removerJava() {

	if [ ! -d "/opt/java" ]; then
		echo 'O JAVA não foi instalado'
	else
		echo 'Removendo a instalação do JAVA'

		cd /opt/

		rm /opt/openjdk-17.0.2_linux-x64_bin.tar.gz
	    rm -R /opt/jdk-17.0.2 

	    unlink java
	    unlink /usr/bin/java
	    unlink /usr/bin/javac

	    rm /etc/profile.d/java.sh

	    echo 'Instalação do Java foi removida com sucesso'
	fi
}

instalarMaven() {

	if [ -d "/opt/maven" ]; then
		echo 'O Maven já foi instalado'
	else
		echo 'Iniciando a instalação do Maven'

		cd /opt/

		 wget https://dlcdn.apache.org/maven/maven-3/3.8.5/binaries/apache-maven-3.8.5-bin.tar.gz
		
	    tar -xzvf apache-maven-3.8.5-bin.tar.gz
	    
	    ln -s /opt/apache-maven-3.8.5 maven
	 	ln -s /opt/maven/bin/mvn /usr/bin/mvn

		echo '#PATH for Maven' > /etc/profile.d/maven.sh
		echo 'M2_HOME=/opt/maven' >> /etc/profile.d/maven.sh
		echo 'export PATH=$PATH:$M2_HOME/bin' >> /etc/profile.d/maven.sh

		echo 'Instalação do Maven concluida com sucesso'
	fi
}

removerMaven() {

	if [ ! -d "/opt/maven" ]; then
		echo 'O Maven não foi instalado'
	else
		echo 'Removendo a instalação do Maven'

		cd /opt/

		rm /opt/apache-maven-3.8.5-bin.tar.gz
		rm -R /opt/apache-maven-3.8.5
	    
	    unlink maven
	 	unlink /usr/bin/mvn

		rm /etc/profile.d/maven.sh

		echo 'Instalação do Maven foi removida com sucesso'
	fi
}

instalarNode() {

	if [ -d "/opt/node" ]; then
		echo 'O node já foi instalado'
	else
		echo 'Iniciando a instalação do node'

		cd /opt/

		wget https://nodejs.org/dist/v16.14.2/node-v16.14.2-linux-x64.tar.xz

	    tar -Jxvf node-v16.14.2-linux-x64.tar.xz
	    ln -s /opt/node-v16.14.2-linux-x64 node

	 	ln -s /opt/node/bin/node /usr/bin/node
	 	ln -s /opt/node/bin/npm /usr/bin/npm
	 	ln -s /opt/node/bin/npx /usr/bin/npx

		echo '# Nodejs' > /etc/profile.d/node.sh
		echo 'export PATH=/opt/node/bin:$PATH' >> /etc/profile.d/node.sh

	    echo 'Instalação do node concluida com sucesso'
	fi
}

removerNode() {

	if [ ! -d "/opt/node" ]; then
		echo 'O node não foi instalado'
	else
		echo 'Removendo a instalação do node'

		cd /opt/

		rm /opt/node-v16.14.2-linux-x64.tar.xz
		rm -R /opt/node-v16.14.2-linux-x64
	    unlink node

	 	unlink /usr/bin/node
	 	unlink /usr/bin/npm
	 	unlink /usr/bin/npx

		rm /etc/profile.d/node.sh

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

instalarFontsMs() {
	apt install -y ttf-mscorefonts-installer
}

removerFontsMs() {
	apt remove -y ttf-mscorefonts-installer	
}

instalarSublime() {
	snap install sublime-text --classic
}

removerSublime() {
	snap remove sublime-text
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


instalar() {
	apt update
	apt upgrade -y
	instalarJava
	instalarMaven
	instalarNode
	instalarFirewall
	instalarGit
	instalarIntellij
	instalarDatagrip
	instalarSublime
	instalarPostman
	instalarCode
	instalarFontsMs
	instalarAngularCli
	reboot
}

remover() {
	removerAngularCli
	removerJava
	removerMaven
	removerNode
	removerFirewall
	removerGit
	removerIntellij
	removerDatagrip
	removerSublime
	removerPostman
	removerCode
	removerFontsMs
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
    read -p "Deseja instalar? " sn
    case $sn in
        [Ss]* ) instalar; break;;
        [Nn]* ) break;;
        * ) echo "Responda sim ou não.";;
    esac
done

while true; do
    read -p "Deseja remover? " sn
    case $sn in
        [Ss]* ) remover; break;;
        [Nn]* ) break;;
        * ) echo "Responda sim ou não.";;
    esac
done
