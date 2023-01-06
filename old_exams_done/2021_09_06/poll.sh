#!/bin/bash

# Realizzare su router uno script /root/poll.sh che esplori l'intervallo di indirizzi assegnabili ai
# server, ricavando via SNMP il carico di ogni server attivo (si noti che nell'intervallo di indirizzi solo
# alcuni server possono essere attivi e quindi rispondere alla query).

# Il carico è definito come il numero di linee presenti nel file /var/log/conn.log di un server. Lo script
# deve memorizzare nel file /tmp/bestserver l'indirizzo del server col carico più basso.

# Lo script deve essere eseguito automaticamente ogni 3 minuti; l'esplorazione deve quindi essere
# svolta in modo da concludersi in un tempo molto più breve, indipendentemente da quanti server
# siano raggiungibili nell'intervallo di indirizzi considerato.

servers=$(cat /var/lib/misc/dnsmasq.leases | cut -d' ' -f3 | grep "10.200.")

tmp=$(mktemp)

echo "$servers" | (
    while read server; do
        count=$(
            snmpget -v 1 -c public "$server" NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"trafficcount\" | xargs |
                awk -F 'STRING: ' '{print $2}'
        )

        [[ -z "$count" ]] && continue

        echo "$server:$count"
    done >"$tmp"
)

least=$(cat "$tmp" | cut -d':' -f2 | sort -n)
cat "$tmp" | grep "$least" | head -n1 | grep "$least" | cut -d: -f1 >/tmp/bestserver

rm "$tmp"
