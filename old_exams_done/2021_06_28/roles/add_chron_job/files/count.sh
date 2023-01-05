#!/bin/bash

# Realizzare su Router1 uno script count.sh che ogni 20 minuti, nelle sole ore lavorative (dalle 8 alle
# 19, dal lunedì al venerdì)

# • effettui uno spostamento corretto ed efficiente di quanto contenuto in /var/log/nfs.log in
# /var/log/nfs.log.last, in modo che contestualmente il log di nuovi messaggi riprenda nel file
# (nuovo) /var/log/nfs.log

# • analizzi /var/log/nfs.log.last calcolando, per ogni IP della rete dei Client presente nel log:

# • la somma delle lunghezze dei pacchetti che lo riguardano (in entrambe le direzioni)

# • il numero totale di pacchetti che lo riguardano (in entrambe le direzioni)

# • per ogni macchina client che ha generato più di 20MB di traffico o scambiato più di 10.000
# pacchetti, invochi lo script alert.sh passandogli come parametro l'IP

# anche in questo caso, dato che il file monitor.sh non monitora i pacchetti nfs, supponiamo di sorvegliare il file
# monitor.log

ssh 192.168.56.222 "/usr/bin/sudo /usr/bin/mv /var/log/monitor.log /var/log/monitor.log.last"
ssh 192.168.56.222 "/usr/bin/sudo systemctl restart rsyslog"

declare -A IPLEN
declare -A COUNT

ssh vagrant@192.168.56.222 "/usr/bin/sudo /usr/bin/cat /var/log/monitor.log.last" | (

    # Jan  5 08:26:52 router2 monitor: 10.222.222.167:10.111.111.125:64
    while read line; do
        # echo "$line"

        SRC=$(echo "$line" | rev | cut -d: -f3 | rev)
        DST=$(echo "$line" | rev | cut -d: -f2 | rev)
        LEN=$(echo "$line" | rev | cut -d: -f1 | rev)

        ((IPLEN[$SRC] += $LEN))
        ((IPLEN[$DST] += $LEN))
        ((COUNT[$SRC] += 1))
        ((COUNT[$DST] += 1))
    done
)

for C in "${!IPLEN[@]}"; do
    [[ ${IPLEN[$C]} -gt 20000000 || ${COUNT[$C]} -gt 10000 ]] && /usr/bin/alert.sh $C
done
