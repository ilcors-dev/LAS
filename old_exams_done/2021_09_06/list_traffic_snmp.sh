#!/bin/bash

# script in support a poll.sh, questo script risiede nei server e viene usato da snmp per contare
# in modo raggruppato il traffico contenunto in /var/log/conn.log
# ci sono più ip loggati => per ognuno di questi è necessario sapere le occurrences

# ! NB HO LETTO MALE LA CONSEGNA #!$#!!

cat /var/log/conn.log | awk -F '(count.sh: |root: )' '{print $2}' | sort -u | (
    while read line; do
        count=$(cat /var/log/conn.log | grep "$line" | wc -l)

        echo "$line:$count"
    done
)
