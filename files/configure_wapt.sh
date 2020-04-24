#!/bin/bash
FIRSTRUN="/var/lib/pgsql/9.6/.firstrun"
if [[ ! -e "$FIRSTRUN" ]]
then
    while $(sleep 1); do
    if systemctl is-system-running | grep -qE "running|degraded"
    then
        break
    fi
    done
    sleep 5
    if [ -z "$(ls -A /var/lib/pgsql/9.6)" ]; then
      echo "Populating /var/lib/pgsql/9.6" 
      rsync -a /var/lib/pgsql/9.6.orig/ /var/lib/pgsql/9.6
    fi
    if [ -z "$(ls -A /opt/wapt/conf)" ]; then
      echo "Populating /opt/wapt/conf"
      rsync -a /opt/wapt/conf.orig/ /opt/wapt/conf
    fi
    if [ -z "$(ls -A /etc/nginx)" ]; then
      echo "Populating /etc/nginx"
      rsync -a /etc/nginx.orig/ /etc/nginx
    fi
    if [ -z "$(ls -A /var/www/html)" ]; then
      echo "Populating /var/www/html"
      rsync -a /var/www/html.orig/ /var/www/html
    fi
    if [ -z "$(ls -A /opt/wapt/waptserver/ssl)" ]; then
      rsync -a /opt/wapt/waptserver/ssl.orig/ /opt/wapt/waptserver/ssl
    fi
    echo "Initializing Postgres database :"
    export PGSETUP_INITDB_OPTIONS="-E UTF8" && /usr/pgsql-9.6/bin/postgresql96-setup initdb 
    systemctl enable postgresql-9.6 && systemctl start postgresql-9.6
    systemctl enable waptserver
    if [ "$DISABLE_NGINX" != "1" ] || [[ -z "$DISABLE_NGINX" ]]
    then 
         systemctl enable nginx
    fi
    echo "Running Wapt configuration :"
    /opt/wapt/waptserver/scripts/postconf.sh --quiet  && echo `grep __version__ /opt/wapt/waptserver/config.py | awk -F "=" '{print $2}' | awk -F "\"" '{print $2}'` > $FIRSTRUN 
    cp /etc/ssl/certs/dhparam.pem /opt/wapt/waptserver/ssl/
    rsync -a /opt/wapt/waptserver/static/ /var/www/html/static
    if [[ -n "$WAPTSERVER_PORT" ]]
    then
        regexpnumbers='^[0-9]+$'
        if [[ $WAPTSERVER_PORT =~ $regexpnumbers ]] 
        then
            if [ $WAPTSERVER_PORT -gt 1024 ]
            then 
                echo "waptserver_port = ${WAPTSERVER_PORT}" >> /opt/wapt/conf/waptserver.ini
                sed -i "s/127.0.0.1:8080/127.0.0.1:${WAPTSERVER_PORT}/g" /etc/nginx/conf.d/wapt.conf
            fi
        fi
    fi
    systemctl is-active --quiet waptserver && systemctl restart waptserver || systemctl start waptserver 
    if [ "$DISABLE_NGINX" != "1" ] || [[ -z "$DISABLE_NGINX" ]]
    then
        systemctl is-active --quiet nginx && systemctl restart nginx || systemctl start nginx
    elif [ "$DISABLE_NGINX" == "1" ]
    then
        systemctl is-active --quiet nginx &&  systemctl stop nginx && systemctl disable nginx
    fi 
fi
