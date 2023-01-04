#!/bin/bash

# script facility.priority nomeFile

#inserisco il nuovo file di logging
echo -e "$1\t$2" >/etc/rsyslog.d/logconfig.conf
#creo il comando da eseguire
COMANDO="/usr/bin/uptime | /usr/bin/logger -p $1"
#inserisco il comando in crontab
(
  crontab -l 2>/dev/null
  echo "*/5 * * * * $COMANDO"
) | crontab -
