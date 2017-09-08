# WebGIS on Raspberry Pi / armhf
* https://github.com/TobiasH87Docker/rpi-mysql
* https://github.com/TobiasH87Docker/rpi-postgresql-postgis with https://github.com/TobiasH87Docker/rpi-postgresql
* https://github.com/TobiasH87Docker/rpi-php
* https://github.com/TobiasH87Docker/rpi-apache2
* https://github.com/TobiasH87Docker/rpi-nginx

Example (Linux/Raspbian):
* Requirement: Installed [Docker](https://docs.docker.com/engine/installation/) ``` sudo curl -sSL https://get.docker.com | sh ``` and [Docker-Compose](https://docs.docker.com/compose/install/) 
* ``` $ git clone https://github.com/TobiasH87Docker/docker-compose.git && cd ./docker-compose/rpi-webgis/ ```
* ``` $ sudo mkdir -p /srv/webgis/{mysql,postgresql,nginx,ssl,html} && sudo cp docker-compose.yml /srv/webgis/ && sudo cp default.conf /srv/webgis/nginx/ && sudo cp phpApps.sh /srv/webgis/ && cd /srv/webgis/ ``` 
* Change Passwords and Settings (Domain, ..): ``` $ nano docker-compose.yml ```
* Change Domain ``` $ sudo nano ./nginx/default.conf ```
* SSL-Certificate(temporary?): ``` $ openssl req -x509 -newkey rsa:4086 -subj "/C=/ST=/L=/O=/CN=localhost" -keyout "./ssl/ssl.key" -out "./ssl/ssl.crt" -days 3650 -nodes -sha256 ```
* Get Images and Start Container: ``` $ sudo docker-compose up -d ```
* Note: use for update images and container: ``` $ sudo docker-compose down && sudo docker-compose up -d ``` 
* Optional (phpMyAdmin+phpPgAdmin+adminer manually installation instead of docker):
	* check current version numbers: ``` $ nano phpApps.sh ```
	* ``` $ chmod +x phpApps.sh && sudo ./phpApps.sh ```
* Call: http://YOUR-DOMAIN or https://YOUR-DOMAIN 
