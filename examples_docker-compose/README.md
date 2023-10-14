# Examples for Docker-Compose

Examples of self-hosted applications in a Docker / docker-compose environment.  

These examples (mostly) use [Traefik](https://traefik.io/traefik/) as Proxy and Prometheus/Grafana/Alertmanager for Monitoring.

## Requirements

The examples are for Linux operating systems (example: Debian) with a container environment, in this case they are managed using docker-compose.

For installation read the official installation guide:
* Install [Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository) (on Debian)
* Install [docker-compose](https://docs.docker.com/compose/install/linux/#install-using-the-repository)-plugin  
  (If not already done with the Docker installation.)

After installing docker-compose-plugin, you can use it with `docker compose` (with a space). In the example `*.yml`-files, the first line contains the command "docker-compose", replace it accordingly or create an alias:
```sh
echo 'alias docker-compose="docker compose"' >> ~/.bashrc
```
(`~/.bash_aliases` or `~/.bashrc`)  
  
Note: If you want to use this on Windows, [Docker Desktop](https://www.docker.com/products/docker-desktop/) with WSL2 ([#1](https://docs.docker.com/desktop/wsl/), [#2](https://learn.microsoft.com/en-us/windows/wsl/)) is recommended.


## Usage

### Network

When you want use the examples with network `mynetwork`, you can create it with sh-script [docker_network_create.sh](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/docker_network_create.sh).  
You can rename it or delete it if you don't need it.

### Traefik

Most examples are with [Traefik](https://traefik.io/traefik/) as Proxy. **[Traefik-Example](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/traefik.yml)**   
Important: The containers (example: Web-Applications) to be used with Traefik must be on the same Docker network.
  
For more information about the Traefik, read the official documentation: https://doc.traefik.io/traefik/

For this [Traefik-Example](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/traefik.yml) i used also self signed certificate create with easy-rsa ([#1](https://github.com/OpenVPN/easy-rsa),[#2](https://github.com/Tob1as/docker-tools#easy-rsa)), when you want use Let's Encrypt you must [configure and enable](https://doc.traefik.io/traefik/https/acme/) it.
  
If you don't want to use Traefik, you have to create your own configurations for another proxy or comment in the ports in the yml files and optional remove network `mynetwork`.  
An example of another proxy like nginx can be found [here](https://github.com/Tob1as/docker-kubernetes-collection/blob/master/examples_docker-compose/config_nginx/conf.d/default.conf).

### Passwords

**Important**: Changes passwords in examples!  

Search for Password "passw0rd" and change it !!  
In Traefik configs for services search under "labels" and then for "basicauth".  
Username changes is optional.

### Monitoring: 

For the Montoring Prometheus/Grafana/Alertmanager/cAdvisor with some prometheus-exporters is used as Software-Stack.

Name          | Website  | GitHub
------------  | -------- | --------
cAdvisor      | - | [Click](https://github.com/google/cadvisor)
Grafana       | [Click](https://grafana.com/oss/grafana/) | [Click](https://github.com/grafana/grafana)
Prometheus    | [Click](https://prometheus.io/)   | [Click](https://github.com/prometheus/prometheus)
Alertmanager  |  see prom  | [Click](https://github.com/prometheus/alertmanager)
node-exporter | see prom  | [Click](https://github.com/prometheus/node_exporter)

All applications in the example use the same subdomain and their own subpaths/subfolders.

Grafana dashboards can be found in the GitHub projects of the exporters or on the [Grafana website](https://grafana.com/grafana/dashboards/).  
When you copy the dashboards `*.json`-files in `.config_monitoring/grafana/provisioning/dashboards/` before first startup, it will automatically add.

If you don't want to use monitoring, don't start it and delete the exporter from the example *.yml files.

### Folder structure

* `*.yml`-files are the docker-compose files
* `config_*/`-folder contains configurations that mostly have to be accessed read-only.
* `data_*/`-folder contains data from containers, it is recommended to backup them periodically. (For Database backups use the database tools/cli.)
* `ssl/`-folder contains own ssl certificate and ca.

### Databases & GUI

Some databases contain additional services in their `*.yml`-files, such as an exporter or even a Web GUI.  
It is recommended to start the Web GUI only if absolutely necessary and then to provide it with an additional password protection (basicauth).

## more Examples

You can find other examples in my other Docker [Projects](https://github.com/Tob1as) beginn with `docker-*`.

## Feedback

If you have feedback, questions or improvements, create an issue or an MR.
