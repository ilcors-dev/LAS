#!/bin/bash

# Su ognuno di due Server (idealmente quelli configurati all'esercizio 1, o se non si è svolto questo, sul server preconfigurato durante il corso e su di un
# suo clone) realizzare uno script failback.sh che svolga queste operazioni:

# a) Interroga via SNMP il Router, che deve rispondere col contenuto del proprio file /tmp/server.attivo. Il contenuto di tale file consiste nel nome di un
# server (Server1 o Server2) seguito eventualmente da uno spazio e dalla parola "new"

# NOTA: l'agent SNMP di Router chiaramente deve essere configurato appositamente per erogare il file quando viene richiesto uno specifico OID; la
# configurazione dell'agent deve essere consegnata.

# b) Se il risultato ottenuto contiene il nome del server su cui è in esecuzione lo script (Server1 o Server2), lo script assegna all'interfaccia eth2 l'indirizzo
# aggiuntivo 10.20.20.20, altrimenti lo script si assicura che l'interfaccia eth2 non detenga l'indirizzo 10.20.20.20, deconfigurandolo se necessario.

# c) Lancia lo script ldap.sh, passando come parametro la parola "new" se è presente nella risposta SNMP

# Configurare Server1 per eseguire failback.sh a ogni minuto dispari, e Server2 per eseguirlo a ogni minuto pari.

server=$(snmpget -v 1 -c public 10.20.20.254 NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"serverattivo\" | awk -F 'STRING: ' '{print $2}')

isMe=$(echo "$server" | grep $(hostname) | wc -l)

if [[ "$isMe" -ge "1" ]]; then
    alreadyAssigned=$(ip a | grep eth2 | grep 10.20.20.20)

    if ! [[ -z "$alreadyAssigned" ]]; then
        sudo ip addr del 10.20.20.20/24 dev eth2
    else
        sudo ip addr add 10.20.20.20/24 dev eth2
    fi
fi

/home/ldap.sh $(echo "$server" | cut -d' ' -f2)
