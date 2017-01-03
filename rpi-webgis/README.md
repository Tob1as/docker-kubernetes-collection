# WebGIS on Raspberry Pi / armhf
* https://github.com/TobiasH87Docker/rpi-mysql
* https://github.com/TobiasH87Docker/rpi-postgresql-postgis with https://github.com/TobiasH87Docker/rpi-postgresql
* https://github.com/TobiasH87Docker/rpi-php
* https://github.com/TobiasH87Docker/rpi-apache2
* https://github.com/TobiasH87Docker/rpi-nginx

Use:
* ``` $ git clone https://github.com/TobiasH87Docker/docker-compose.git && docker-compose/rpi-webgis/ ```
* ``` $ mkdir -p /home/pi/{html,.ssl} && mkdir -p /home/pi/.config/{nginx,httpd} && mkdir -p /home/pi/.local/share/{postgresql,mysql} ```
* Optional (SSL): 
	* ``` $ openssl req -x509 -newkey rsa:4086 -subj "/C=/ST=/L=/O=/CN=localhost" -keyout "ssl.key" -out "ssl.crt" -days 3650 -nodes -sha256 ```
	* ``` $ mv ssl.* /home/pi/.ssl/ ```
* Edit nginx config (e.g. Hostname): ``` $ nano default.conf ```
* ``` $ cp default.conf /home/pi/.config/nginx/ ``` 
* Change Passwords and Settings: ``` $ nano docker-compose.yml ```
* ``` $ sudo docker-compose up -d ``` (Install docker-compose for Pi see here: https://github.com/hypriot/arm-compose) 
* Optional (phpMyAdmin+phpPgAdmin+adminer manually installation):
	* Change path and check current version numbers: ``` $ nano phpApps.sh ```
	* ``` $ chmod +x phpApps.sh && ./phpApps.sh ```
* http://localhost
