# WebGIS on x86_64 
* https://hub.docker.com/_/mysql/
* https://hub.docker.com/r/phpmyadmin/phpmyadmin/
* https://hub.docker.com/r/mdillon/postgis/ with https://hub.docker.com/_/postgres/
* https://hub.docker.com/r/superkul/phppgadmin/
* https://hub.docker.com/r/kartoza/geoserver/
* https://hub.docker.com/_/php/
* https://hub.docker.com/_/nginx/

Use:
* ``` git clone REPOSITORY && docker-compose/webgis/ ```
* ``` docker build -t php:5.6-apache-extend ../../php/5.6-apache-extend/ ```
* Change Passwords and Settings: ``` nano docker-compose.yml ```
* ``` sudo mkdir -p /srv/tobias/{mysql,postgresql,geoserver,nginx,ssl,html} ```
* Optional (SSL): 
	* ``` openssl genrsa -out ssl.key 4096 ```
	* ``` openssl req -new -key ssl.key -out ssl.csr ```
	* ``` openssl x509 -req -days 1825 -in ssl.csr -signkey ssl.key -out ssl.crt -sha256 ```
	* ``` sudo mv ssl.* /srv/tobias/ssl/ ```
* ``` sudo cp default.conf /srv/tobias/nginx/ ``` 
* ``` docker-compose up -d ```  
* http://localhost 