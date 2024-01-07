#!/bin/sh

set -e
ME=$(basename $0)

# https://github.com/Tob1as/docker-php/blob/master/entrypoint.sh

##########################################################################

echo "$ME: info: enabling remoteip support, use this only behind a proxy!"

cat > /etc/apache2/conf-available/remoteip.conf <<EOF
<IfModule mod_remoteip.c>
    RemoteIPHeader X-Forwarded-For
</IfModule>

EOF

/usr/sbin/a2enmod remoteip
/usr/sbin/a2enconf remoteip

##########################################################################

echo "$ME: info: enabling apache status!"

cat > /etc/apache2/conf-available/status.conf <<EOF
<IfModule mod_status.c>
    #ExtendedStatus on
    <Location /server-status>
        SetHandler server-status
        Order deny,allow
        Require all denied
        Require local
        Require ip 10.0.0.0/8
        Require ip 172.16.0.0/12
        Require ip 192.168.0.0/16
        #Require ip fd00::/7
    </Location>
</IfModule>

EOF
	
/usr/sbin/a2enmod status
/usr/sbin/a2enconf status

##########################################################################
