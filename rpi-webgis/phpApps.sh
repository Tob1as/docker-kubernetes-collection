#!/bin/bash

########### CONFIG ###########

#INSTALLPATH=${PWD}
INSTALLPATH='/home/pi/html'

AMPACHE_VERSION=3.8.2

PHPMYADMIN_VERSION=4.6.5.2
PHPPGADMIN_VERSION=5.1
ADMINER_VERSION=4.2.5

##############################

echo ">> Install PHP Apps in ${INSTALLPATH}"

cd ${INSTALLPATH}

# https://github.com/ampache/ampache/wiki/Installation
#wget https://github.com/ampache/ampache/releases/download/${AMPACHE_VERSION}/ampache-${AMPACHE_VERSION}_all.zip
#unzip ampache-${AMPACHE_VERSION}_all.zip -d ampache
#chmod 777 ampache/channel && chmod 777 ampache/config && chmod 777 ampache/play && chmod 777 ampache/rest
#rm ampache-${AMPACHE_VERSION}_all.zip
#echo ">>Ampache ${AMPACHE_VERSION} installed. Visit: http://localhost/ampache (First call installed ampache and genarate a admin account.)"

# https://www.phpmyadmin.net/
wget -q -O - https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz | tar xvzf -
mv phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages phpMyAdmin
mv phpMyAdmin/config.sample.inc.php phpMyAdmin/config.inc.php
sed -i "s/$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/$cfg\['Servers'\]\[\$i\]\['host'\] = 'mysql';/g" phpMyAdmin/config.inc.php
echo ">>phpMyAdmin ${PHPMYADMIN_VERSION} installed. Visit: http://localhost/phpMyAdmin"

# http://phppgadmin.sourceforge.net/
wget -q -O - http://downloads.sourceforge.net/project/phppgadmin/phpPgAdmin%20%5Bstable%5D/phpPgAdmin-${PHPPGADMIN_VERSION}/phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz | tar xvzf -
mv phpPgAdmin-${PHPPGADMIN_VERSION} phpPgAdmin
sed -i "s/$conf\['servers'\]\[0\]\['host'\] = '';/$conf\['servers'\]\[0]\['host'\] = 'postgresql';/g" phpPgAdmin/conf/config.inc.php 
sed -i 's/\(^.*conf\[.extra_login_security.\] =\) true/\1 false/' phpPgAdmin/conf/config.inc.php
echo ">>phpPgAdmin ${PHPPGADMIN_VERSION} installed. Visit: http://localhost/phpPgAdmin"


# https://www.adminer.org/
mkdir adminer && wget https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php -O adminer/index.php
echo ">>Adminer ${ADMINER_VERSION} installed. Visit:  http://localhost/adminer"
