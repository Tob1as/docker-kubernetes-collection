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

# https://docs.docker.com/compose/completion/
case "$lsb_dist" in

	ubuntu|debian|centos|photon|raspbian)		
		 curl -L https://raw.githubusercontent.com/docker/compose/$DOCKER_COMPOSE_VERSION/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
	;;
	
	coreos)
		# https://github.com/coreos/bugs/issues/22#issuecomment-59951575
		echo "Source: https://github.com/coreos/bugs/issues/22#issuecomment-59951575"
		echo "execute: 
		
		toolbox dnf -y install bash-completion curl \ 
			&& toolbox curl -L https://raw.githubusercontent.com/docker/docker-ce/master/components/cli/contrib/completion/bash/docker -o /usr/share/bash-completion/completions/docker \ 
			&& toolbox curl -L https://raw.githubusercontent.com/docker/compose/$DOCKER_COMPOSE_VERSION/contrib/completion/bash/docker-compose -o /usr/share/bash-completion/completions/docker-compose \ 
			&& toolbox cp /usr/share/bash-completion /media/root/var/ -R  \ 
			&& source /var/bash-completion/bash_completion \ 
			&& cp /home/core/.bashrc /home/core/.bashrc.new && mv /home/core/.bashrc.new /home/core/.bashrc && chown core:core /home/core/.bashrc \ 
			&& echo 'source /var/bash-completion/bash_completion' >> /home/core/.bashrc
		"
	;;

	*)
		echo "... and command completion not needed."
	;;

esac
