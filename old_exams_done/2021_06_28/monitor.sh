#!/bin/bash

# Realizzare su Router2 uno script monitor.sh che sorvegli continuamente il traffico NFS (porta
# 2049 del Server, sia tcp sia udp) scrivendo via syslog sul file /var/log/nfs.log di Router1 , per ogni
# pacchetto: IP sorgente, IP destinazione e lunghezza (length)

# 15:03:16.807515 eth0  In  IP 10.0.2.2.54580 > 10.0.2.15.ssh: Flags [.], ack 110348, win 65535, length 0

# dato che l'esame era un po' diverso l'anno scorso, mi limito a catturare tutto il traffico passante per il router2
# che proviene dal router1

ipRegex=^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$

sudo tcpdump -i any -nlp '((dst net 10.222.222.0/24) or (src net 10.222.222.0/24))' |
    (
        while read T IN VERS P SRC V DST RESTO; do
            SIP=$(cut -f1-4 -d. <<<$SRC | cut -d: -f1)
            DIP=$(cut -f1-4 -d. <<<$DST | cut -d: -f1)
            LEN=$(awk -F 'length ' '{print $2}' <<<$RESTO)

            if ! [[ $SIP =~ $ipRegex && $DIP =~ $ipRegex ]]; then
                continue
            fi

            test "$LEN" -gt "0" || continue

            logger -p local4.info -t monitor "$SIP":"$DIP":"$LEN"
        done
    )
