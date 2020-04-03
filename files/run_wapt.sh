#!/bin/bash
setsid /app/configure_wapt.sh &
exec /usr/sbin/init
