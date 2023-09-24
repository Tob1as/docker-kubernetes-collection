# Examples for Docker-Compose

Requirements:
* installed [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository)
* installed [Docker-Compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)
* Help? Use my install [Script](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/scripts/docker+docker-compose_install.sh) for Linux Debian/Raspbian.

## Examples

In this folder or in my other [Projects](https://github.com/Tob1as) beginn with `docker-*`.

### Network

When you want use my examples with network `mynetwork`, you can create it with sh-script [docker_network_create.sh](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/docker_network_create.sh). When not, then delete it from yml files.

### Traefik

Some examples with [Trafik](https://traefik.io/traefik/) as Proxy. [Traefik-Example](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/traefik.yml)  
If you don't want to use Traefik, you have to create your own configurations for another proxy or comment in the ports in the yml files and optional remove network `mynetwork`.
