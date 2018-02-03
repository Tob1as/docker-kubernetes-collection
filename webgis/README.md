# WebGIS on x86_64 
* MySQL: https://hub.docker.com/_/mysql/ | https://hub.docker.com/r/mysql/mysql-server/
* PostgreSQL with PostGIS: https://hub.docker.com/r/mdillon/postgis/ include https://hub.docker.com/_/postgres/
* GeoServer with Tomcat: https://hub.docker.com/r/kartoza/geoserver/ (<= v2.8.0) | https://hub.docker.com/r/oscarfonts/geoserver/ (=> v2.9.0) include https://hub.docker.com/_/tomcat/
* PHP (with Apache2): https://hub.docker.com/r/tobi312/php/ include https://hub.docker.com/_/php/
* LetsEncrypt (SSL): https://quay.io/repository/letsencrypt/letsencrypt
* NGNIX (as Proxy): https://hub.docker.com/_/nginx/
* IPv6:
	* NAT: https://hub.docker.com/r/robbertkl/ipv6nat/ or
	* https://docs.docker.com/engine/userguide/networking/default_network/ipv6/#how-ipv6-works-on-docker and https://docs.docker.com/compose/compose-file/#ipv4_address-ipv6_address

Example (Linux/Debian):
* Requirement: Installed [Docker](https://docs.docker.com/engine/installation/) ``` sudo curl -sSL https://get.docker.com | sh ``` and [Docker-Compose](https://docs.docker.com/compose/install/) 
* ``` $ git clone https://github.com/TobiasH87Docker/docker-compose.git && cd ./docker-compose/webgis/ ```
* ``` $ sudo mkdir -p /srv/webgis/{mysql,postgresql,geoserver,nginx,ssl,html,letsencrypt} && sudo cp docker-compose.yml /srv/webgis/ && sudo cp default.conf /srv/webgis/nginx/ && sudo cp phpApps.sh /srv/webgis/ && cd /srv/webgis/ ``` 
* Change Passwords and Settings (Domain, E-Mail ..): ``` $ nano docker-compose.yml ```
* Change Domain ``` $ sudo nano ./nginx/default.conf ```
* SSL-Certificate (temporary, later LetsEncrypt): ``` $ openssl req -x509 -newkey rsa:4086 -subj "/C=/ST=/L=/O=/CN=localhost" -keyout "./ssl/ssl.key" -out "./ssl/ssl.crt" -days 3650 -nodes -sha256 ```
* Get Images and Start Container: ``` $ sudo docker-compose up -d ```
* Change own Certificate to LetsEncrypt (uncomment/comment in ssl section): ``` $ sudo nano ./nginx/default.conf ``` and reload nginx ``` $ sudo docker exec webgis_nginx_1 nginx -s reload ```
	* update/renew LetsEncrypt Certificate: ``` $ sudo docker start webgis_letsencrypt_1 && sleep 30 && sudo docker exec webgis_nginx_1 nginx -s reload ``` (recommendation: via crontab)
* Note: use for update images and container: ``` $ sudo docker-compose down && sudo docker-compose up -d ``` 
* Optional (MySQL settings for root to login with phpMyAdmin):
	* ``` $ sudo docker exec -it webgis_mysql_1 sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' ``` and then in mysql console
	* ``` GRANT ALL PRIVILEGES ON * . * TO 'root'@'%' IDENTIFIED BY 'YOUR-PASSWORD' WITH GRANT OPTION;FLUSH PRIVILEGES;\q; ```
* Optional (phpMyAdmin+phpPgAdmin+adminer manually installation instead of docker):
	* check current version numbers: ``` $ nano phpApps.sh ```
	* ``` $ chmod +x phpApps.sh && sudo ./phpApps.sh ```
* Call: http://YOUR-DOMAIN or https://YOUR-DOMAIN 
