# WebGIS on x86_64 
* MySQL: https://hub.docker.com/_/mysql/
	* Optional: phpMyAdmin: https://hub.docker.com/r/phpmyadmin/phpmyadmin/
* PostgreSQL with PostGIS: https://hub.docker.com/r/mdillon/postgis/ with https://hub.docker.com/_/postgres/
	* Optional: phpPgAdmin: https://hub.docker.com/r/superkul/phppgadmin/
* GeoServer (with Tomcat): https://hub.docker.com/r/kartoza/geoserver/ with https://hub.docker.com/_/tomcat/
* PHP (with Apache2): https://hub.docker.com/r/tobi312/php/ with https://hub.docker.com/_/php/
* NGNIX (as Proxy): https://hub.docker.com/_/nginx/

Use (Linux):
* ``` $ git clone https://github.com/TobiasH87Docker/docker-compose.git && docker-compose/webgis/ ```
* Change Passwords and Settings: ``` $ nano docker-compose.yml ```
* ``` $ sudo mkdir -p /srv/webgis/{mysql,postgresql,geoserver,nginx,ssl,html} ```
* Optional (SSL): 
	* ``` $ openssl req -x509 -newkey rsa:4086 -subj "/C=/ST=/L=/O=/CN=localhost" -keyout "ssl.key" -out "ssl.crt" -days 3650 -nodes -sha256 ```
	* ``` $ sudo mv ssl.* /srv/webgis/ssl/ ```
* ``` $ sudo cp default.conf /srv/webgis/nginx/ ``` 
* ``` $ sudo docker-compose up -d ```
* Optional (MySQL settings for root to login with phpMyAdmin):
	* ``` $ sudo docker exec -it your-mysql-container bash ```
	* ``` $ mysql -u root -p ```
	* ``` $ GRANT ALL PRIVILEGES ON * . * TO 'root'@'%' IDENTIFIED BY 'YOUR-PASSWORD' WITH GRANT OPTION;FLUSH PRIVILEGES;\q; ```
	* ``` $ exit ```
* Optional (phpMyAdmin+phpPgAdmin+adminer manually installation instead of docker):
	* Change path and check current version numbers: ``` $ nano phpApps.sh ```
	* ``` $ chmod +x phpApps.sh && sudo ./phpApps.sh ```
* http://localhost or https://localhost 
