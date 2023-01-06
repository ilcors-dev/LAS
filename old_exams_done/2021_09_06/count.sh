#!/bin/bash

# Realizzare su server1 (sarà poi disponibile su tutti i server) uno script /home/count.sh che resti
# continuamente in ascolto di pacchetti in arrivo dalla rete dei client che richiedono l'apertura di una
# nuova connessione sulla porta ssh. L'indirizzo sorgente deve essere scritto, attraverso rsyslog, sul
# file /var/log/conn.log

# Lo script deve essere automaticamente avviato al boot e riavviato in caso di terminazione anomala.

tcpdump -i eth1 -nlp src net 10.100.0.0/16 and dst port 22 |
    (
        while
            read T IP SIP RESTO
        do
            ip=$(echo "$SIP" | cut -f1-4 -d.)
            logger -p local4.info "$ip"
        done
    )
