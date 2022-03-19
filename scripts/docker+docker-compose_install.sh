#!/bin/bash
set -e

# Docker & docker-compose v2 install on Debian/Raspbian 11 bullseye!
# 
# Source-URL: https://github.com/Tob1asDocker/Collection/blob/master/scripts/docker+docker-compose_install.sh
# Created: 2021-12-19 ; last Update: 2022-03-19
# Read more:
#   * https://docs.docker.com/engine/install/debian/ 
#   * https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script
#   * https://docs.docker.com/compose/cli-command/#install-on-linux
#   * https://github.com/docker/compose#linux
#   * https://docs.docker.com/engine/reference/commandline/dockerd/
#   * https://docs.docker.com/config/daemon/ipv6/

# colors
n=`tput sgr0`     # normal/reset
r=`tput setaf 1`  # red
g=`tput setaf 2`  # green
y=`tput setaf 3`  # yellow
b=`tput setaf 4`  # blue
lb=`tput setaf 6` # lightblue

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

if ! command_exists sudo; then
    echo "${r}>> Please install sudo!${n}"
    exit 0
fi

# Install some required packages
install_requirements () {
    echo "${b}>> Install some required packages${n}"
    sudo apt update
    sudo apt install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg2 \
        software-properties-common \
        lsb-release
}

# get system info
lsb_dist="$(. /etc/os-release && echo "$ID" | tr '[:upper:]' '[:lower:]')"
#lsb_dist="$(lsb_release -is | tr '[:upper:]' '[:lower:]')"
#lsb_dist_codename="$(lsb_release -cs | tr '[:upper:]' '[:lower:]')"
#kernelname="$(uname -s | tr '[:upper:]' '[:lower:]')"
#arch="$(uname -m | tr '[:upper:]' '[:lower:]')"
#arch_dpkg=$(dpkg --print-architecture)
#current_user=$(last -Fwp now | grep 'logged in' | head -n 1 | cut -d' ' -f1) # get last login user
current_user=$(whoami)
#current_user=$(echo $USER)

# Install Docker
install_docker () {
    if ! command_exists docker; then
        echo "${b}>> Install Docker${n}"
        
        # Get the Docker signing key for packages
        curl -fsSL "https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg" | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
        #sudo apt-key add /usr/share/keyrings/docker-archive-keyring.gpg
	    
        # Add the Docker official repos
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
        
        # Install Docker
        sudo apt update
        case "$lsb_dist" in
            raspbian)
                sudo apt install -y --no-install-recommends docker-ce-cli docker-ce containerd.io
                sudo apt install -y docker-ce-rootless-extras
            ;;
            *)
                sudo apt install -y docker-ce-cli docker-ce containerd.io docker-ce-rootless-extras
            ;;
        esac
	    
        # add docker permission to user (restart shell session requied)
        case "$lsb_dist" in
            raspbian)
                echo "${b}>>> add user pi to docker group${n}"
                sudo usermod -aG docker pi
            ;;
            *)
                if [[ "$current_user" != "root" ]]; then
                    sudo usermod -aG docker $current_user
                else
                    echo "${b}>>> optional: add your user to docker group with: \"sudo usermod -aG docker USER\"${n}"
                fi
            ;;
        esac
	    
        # restart docker
        #sudo systemctl restart docker
    else 
        echo "${lb}>> Docker is exists.${n}"
    fi

    # check version
    #DOCKERD_VERSION_INSTALLED="$(dockerd -v | cut -d ' ' -f3 | cut -d ',' -f1)"
    #DOCKER_VERSION_INSTALLED="$(docker -v | cut -d ' ' -f3 | cut -d ',' -f1)"
    sudo dockerd -v
    sudo docker -v
}

# Install docker-compose (v2) (repeat this part if you want to make an update)
install_docker_compose () {
    echo "${b}>> Install docker-compose (v2)${n}"

    # get latest stable docker-compose version
    #DOCKER_COMPOSE_VERSION=`git ls-remote --tags git://github.com/docker/compose.git | awk '{print $2}' | grep -v 'docs\|rc' | awk -F'/' '{print $3}' | sort -V | tail -n1`
    DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
    #DOCKER_COMPOSE_VERSION"v2.2.2" # install specific version
    #DOCKER_COMPOSE_VERSION"1.29.2" # v1 not working on raspbian, use "sudo pip3 install docker-compose --upgrade"

    # download docker-compose
    sudo curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s | tr '[:upper:]' '[:lower:]'`-`uname -m | sed 's/l//'` -o /usr/libexec/docker/cli-plugins/docker-compose

    # set file permission
    sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose

    # check version
    #DOCKER_COMPOSE_VERSION_INSTALLED=$(docker compose version | cut -d ' ' -f4)
    sudo docker compose version
}

# docker: enable IPv6 NAT
enable_docker_ipv6nat () {
    if [ ! -f "/etc/docker/daemon.json" ] ; then
        echo "${b}>> docker: enable IPv6 NAT${n}"
        sudo sh -c 'cat << EOF > /etc/docker/daemon.json
{
  "experimental": true,
  "ip6tables": true,
  "ipv6": true,
  "fixed-cidr-v6": "fd00:dead:beef::/48"
}'
        # restart docker
        sudo systemctl restart docker
    else 
        echo "${y}>> docker: enable IPv6 NAT failed. \"/etc/docker/daemon.json\" is exists.${n}"
    fi
}

# docker-compose: set alias for current user
set_docker_compose_alias () {
    if ! grep -q "docker compose" ~/.bash_aliases; then
        echo "${b}>> docker-compose: set alias for current user \"$current_user\"${n}"
        echo 'alias docker-compose="docker compose"' >> ~/.bash_aliases
    else 
        echo "${y}>> docker-compose: set alias failed. Is alias exists in \"~/.bash_aliases\"?${n}"
    fi
}

# Main
main () {
    install_requirements
    install_docker
    install_docker_compose
    #enable_docker_ipv6nat
    set_docker_compose_alias
    echo "${g}>> install done! (Recommended: Restart you shell session!)${n}"
}

main