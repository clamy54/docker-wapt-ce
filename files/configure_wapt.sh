#!/bin/bash
FIRSTRUN="/var/lib/pgsql/9.6/.firstrun"
if [ ! -e $FIRSTRUN ]; then
    while $(sleep 1); do
    if systemctl is-system-running | grep -qE "running|degraded"; then
        break
    fi
    done
    sleep 5
    export PGSETUP_INITDB_OPTIONS="-E UTF8" && /usr/pgsql-9.6/bin/postgresql96-setup initdb 
    systemctl enable postgresql-9.6 && systemctl start postgresql-9.6
    systemctl enable waptserver
    systemctl enable nginx
    /opt/wapt/waptserver/scripts/postconf.sh --quiet  && echo `grep __version__ /opt/wapt/waptserver/config.py | awk -F "=" '{print $2}' | awk -F "\"" '{print $2}'` > $FIRSTRUN
    systemctl is-active --quiet waptserver && systemctl restart waptserver || systemctl start waptserver 
    systemctl is-active --quiet nginx && systemctl restart nginx || systemctl start nginx 
fi
