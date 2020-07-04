#!/bin/bash
set -e

# Docker on Raspbian 10 Buster!!!!
# Source-URL: https://gist.github.com/Tob1as/f6fba3fc041d3c8aacfa68441cc54124
# Created: 2019-07-24 ; last Updated: 2020-07-04
# if error "/bin/bash^M: bad interpreter" then execute: "sed -i -e 's/\r$//' *.sh"
# Read more:
# 	https://github.com/docker/for-linux/issues/709
# 	https://withblue.ink/2019/07/13/yes-you-can-run-docker-on-raspbian.html
# 	https://www.heise.de/ct/artikel/Fehler-Korrekturen-und-Neues-rund-um-den-Raspi-4-4471888.html#nav_container_mit__2
# 	https://docs.docker.com/compose/install/#alternative-install-options

# Install some required packages
install_requirements () {
	sudo apt update
	sudo apt install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg2 \
		software-properties-common
}

# Install Docker
install_docker () {
	# Get the Docker signing key for packages
	curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | sudo apt-key add -
	
	# Add the Docker official repos
	echo "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
		$(lsb_release -cs) stable" | \
		sudo tee /etc/apt/sources.list.d/docker.list
		
	# replace raspbian with debian in docker.list
	#sudo sed -i -e 's/raspbian/debian/g' /etc/apt/sources.list.d/docker.list
	
	# Install Docker
	sudo apt update
	sudo apt install -y --no-install-recommends docker-ce
	sudo usermod -aG docker pi
}

# ARMv6 (RaspberryPi 1) fix
install_docker_containerdio_armv6_fix () {
	if [[ "$(uname -m)" = "armv6"* ]]; then
		curl -fsSL https://packagecloud.io/Hypriot/rpi/gpgkey | sudo apt-key add -
		
		echo "deb https://packagecloud.io/Hypriot/rpi/$(. /etc/os-release; echo "$ID") \
			$(lsb_release -cs) main" | \
			sudo tee /etc/apt/sources.list.d/Hypriot_rpi.list
		
		sudo sh -c 'cat << EOF > /etc/apt/preferences.d/Hypriot_rpi
Package: containerd.io
Pin: origin packagecloud.io
Pin-Priority: 1001
EOF'
		
		sudo apt update
		sudo apt install -y --no-install-recommends --allow-downgrades containerd.io
		sudo systemctl restart docker
	fi
}

# Install docker-compose
install_docker_compose () {
	#sudo apt install -y docker-compose # old Version (1.21.0-3), use pip!
	#sudo apt install -y python-pip libffi-dev python-backports.ssl-match-hostname
	#sudo apt install -y python-pretty-yaml python-dockerpty python-texttable python-functools32 python-bcrypt python-nacl \
	#	python-chardet python-certifi python-urllib3 python-idna python-requests python-websocket python-dockerpycreds \
	#	python-pycparser python-cffi  python-docker python-paramiko python-jsonschema python-docopt python-cached-property \
	#	python-backports-shutil-get-terminal-size
	#sudo pip install docker-compose --upgrade
	sudo pip3 install docker-compose --upgrade
}

# Install Bash Completion for docker
install_bash_completion_docker () {
	sudo mkdir -p /etc/bash_completion.d/
	#DOCKER_VERSION="$(docker -v | cut -d ' ' -f3 | cut -d ',' -f1 | awk '{printf "%.2f\n", $NF}')"
	DOCKER_VERSION=$(curl -s https://api.github.com/repos/docker/docker-ce/releases/latest | grep 'tag_name' | cut -d\" -f4  | tr -d v | awk '{printf "%.2f\n", $NF}')
	sudo curl -L https://github.com/docker/docker-ce/raw/$DOCKER_VERSION/components/cli/contrib/completion/bash/docker -o /etc/bash_completion.d/docker
}

# Install Bash Completion for docker-compose
install_bash_completion_docker_compose () {
	sudo mkdir -p /etc/bash_completion.d/
	#DOCKER_COMPOSE_VERSION=$(docker-compose -v | cut -d ' ' -f3 | cut -d ',' -f1)
	DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
	sudo curl -L https://raw.githubusercontent.com/docker/compose/$DOCKER_COMPOSE_VERSION/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
}

# Show installed versions
show_installed_versions () {
	docker -v
	docker-compose -v
}

# Main
main () {
	install_requirements
	install_docker
	#install_docker_containerdio_armv6_fix
	install_docker_compose
	install_bash_completion_docker
	install_bash_completion_docker_compose
	show_installed_versions
}

main
