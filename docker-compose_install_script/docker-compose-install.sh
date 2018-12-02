#!/bin/bash
# if error "/bin/bash^M: bad interpreter" then execute: "sed -i -e 's/\r$//' docker-compose-install.sh"

get_distribution() {
	lsb_dist=""
	# Most system has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string for case statements
	echo "$lsb_dist"
}

# perform some very rudimentary platform detection
lsb_dist=$( get_distribution )
lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

# get latest stable docker-compose version
#DOCKER_COMPOSE_VERSION=`git ls-remote --tags git://github.com/docker/compose.git | awk '{print $2}' | grep -v 'docs\|rc' | awk -F'/' '{print $3}' | sort -V | tail -n1`
DOCKER_COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

# choose and install
case "$lsb_dist" in

	ubuntu|debian|centos|photon)
		#mkdir -p /usr/local/bin/
		curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
		chmod +x /usr/local/bin/docker-compose
	;;

	coreos)
		mkdir -p /opt/bin/
		curl -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > /opt/bin/docker-compose
		chmod +x /opt/bin/docker-compose
	;;
	
	raspbian)
		pip install docker-compose --upgrade
	;;

	*)
		echo "Script don't support your OS!"
	;;

esac
