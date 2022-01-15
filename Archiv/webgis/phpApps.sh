#!/bin/bash

# sed -i -e 's/\r$//' phpApps.sh # use this command if error /bin/bash^M: bad interpreter

########### CONFIG ###########

#INSTALLPATH=${PWD}
INSTALLPATH='./html'

AMPACHE_VERSION=3.8.5
PHPMYADMIN_VERSION=4.7.7
PHPPGADMIN_VERSION='dev' # latest stable 5.1, only for php5 and postgres 9.5
ADMINER_VERSION=4.5.0

##############################

echo ">> Install PHP Apps in ${INSTALLPATH}"

cd ${INSTALLPATH}

# https://github.com/ampache/ampache/wiki/Installation
#wget https://github.com/ampache/ampache/releases/download/${AMPACHE_VERSION}/ampache-${AMPACHE_VERSION}_all.zip
#unzip ampache-${AMPACHE_VERSION}_all.zip -d ampache
#chmod 777 ampache/channel && chmod 777 ampache/config && chmod 777 ampache/play && chmod 777 ampache/rest
#rm ampache-${AMPACHE_VERSION}_all.zip
#echo ">>Ampache ${AMPACHE_VERSION} installed. Visit: http://YOUR-DOMAIN/ampache (First call installed ampache and genarate a admin account.)"

# https://www.phpmyadmin.net/
wget -q -O - https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.tar.gz | tar xvzf -
mv phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages phpMyAdmin
mv phpMyAdmin/config.sample.inc.php phpMyAdmin/config.inc.php
sed -i "s/$cfg\['Servers'\]\[\$i\]\['host'\] = 'localhost';/$cfg\['Servers'\]\[\$i\]\['host'\] = 'mysql';/g" phpMyAdmin/config.inc.php
echo ">>phpMyAdmin ${PHPMYADMIN_VERSION} installed. Visit: http://YOUR-DOMAIN/phpMyAdmin"

# http://phppgadmin.sourceforge.net/
if [ $PHPPGADMIN_VERSION == 'dev' ]
then
	#git clone https://github.com/phppgadmin/phppgadmin.git phpPgAdmin
	git clone https://github.com/ralph800/phppgadmin.git phpPgAdmin
	#git clone https://github.com/FranLMSP/phppgadmin.git phpPgAdmin
	#git clone https://github.com/myfarms/phppgadmin.git phpPgAdmin
	cp phpPgAdmin/conf/config.inc.php-dist phpPgAdmin/conf/config.inc.php
	sed -i "s/$conf\['servers'\]\[0\]\['host'\] = '';/$conf\['servers'\]\[0]\['host'\] = 'postgresql';/g" phpPgAdmin/conf/config.inc.php
	sed -i 's/\(^.*conf\[.extra_login_security.\] =\) true/\1 false/' phpPgAdmin/conf/config.inc.php
	echo ">>phpPgAdmin ${PHPPGADMIN_VERSION} installed. Visit: http://YOUR-DOMAIN/phpPgAdmin"
else
	wget -q -O - http://downloads.sourceforge.net/project/phppgadmin/phpPgAdmin%20%5Bstable%5D/phpPgAdmin-${PHPPGADMIN_VERSION}/phpPgAdmin-${PHPPGADMIN_VERSION}.tar.gz | tar xvzf -
	mv phpPgAdmin-${PHPPGADMIN_VERSION} phpPgAdmin
	sed -i "s/$conf\['servers'\]\[0\]\['host'\] = '';/$conf\['servers'\]\[0]\['host'\] = 'postgresql';/g" phpPgAdmin/conf/config.inc.php
	sed -i 's/\(^.*conf\[.extra_login_security.\] =\) true/\1 false/' phpPgAdmin/conf/config.inc.php
	echo ">>phpPgAdmin ${PHPPGADMIN_VERSION} installed. Visit: http://YOUR-DOMAIN/phpPgAdmin"
fi

# https://www.adminer.org/
mkdir adminer && wget https://github.com/vrana/adminer/releases/download/v${ADMINER_VERSION}/adminer-${ADMINER_VERSION}.php -O adminer/index.php
echo ">>Adminer ${ADMINER_VERSION} installed. Visit:  http://YOUR-DOMAIN/adminer"
