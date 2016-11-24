# WebGIS on Raspberry Pi / armhf
* https://github.com/TobiasH87Docker/rpi-mysql
* https://github.com/TobiasH87Docker/rpi-postgresql-postgis with https://github.com/TobiasH87Docker/rpi-postgresql
* https://github.com/TobiasH87Docker/rpi-php
* https://hub.docker.com/r/tobi312/rpi-nginx/

Use:
* ``` git clone https://github.com/TobiasH87Docker/docker-compose.git && docker-compose/rpi-webgis/ ```
* Change Passwords and Settings: ``` nano docker-compose.yml ```
* Edit nginx config (Hostname): ``` nano default.conf ```
* ``` mkdir -p /home/pi/{html,.ssl} && mkdir -p /home/pi/.config/nginx && mkdir -p /home/pi/.local/share/{postgresql,mysql} ```
* Optional (SSL): 
	* ``` openssl genrsa -out ssl.key 4096 ```
	* ``` openssl req -new -key ssl.key -out ssl.csr ```
	* ``` openssl x509 -req -days 1825 -in ssl.csr -signkey ssl.key -out ssl.crt ```
	* ``` sudo mv ssl.* /home/pi/.ssl/ ```
* ``` sudo cp default.conf /home/pi/.config/nginx/ ``` 
* ``` docker-compose up -d ```  
* http://localhost 