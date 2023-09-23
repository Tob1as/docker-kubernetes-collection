#!/bin/sh

mariadb -h localhost -u root --password=${MARIADB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS 'exporter'@'%' IDENTIFIED BY 'exp0rt3r' WITH MAX_USER_CONNECTIONS 3; GRANT PROCESS, REPLICATION CLIENT, SELECT ON *.* TO 'exporter'@'%';"
#mariadb -h localhost -u root --password=${MARIADB_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS 'myuser'@'%' IDENTIFIED BY 'password123' WITH MAX_USER_CONNECTIONS 0; CREATE DATABASE IF NOT EXISTS mydatabase CHARACTER SET='utf8' COLLATE='utf8_general_ci'; GRANT ALL PRIVILEGES ON mydatabase.* TO 'myuser'@'%';"
mariadb -h localhost -u root --password=${MARIADB_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
