#!/bin/bash

# Realizzare su client1 uno script /home/las/connect.sh con queste specifiche:

# • Richiede come parametro sulla riga di comando un nome utente, ed eventualmente uno o più
# altri parametri che rappresentano nell'insieme una riga di comando da eseguire in remoto

# • Ricava l'indirizzo del server più scarico con una query SNMP rivolta a router (che, si
# ricordi, conserva queste informazione nel file /tmp/bestserver)

# • Avvia una connessione ssh verso tale server a nome dell'utente indicato come primo
# parametro, (eseguendo in remoto il comando specificato dagli altri parametri, se presenti).
# La password verrà quindi richiesta direttamente dal comando ssh.

function usage() {
    echo "usage: $0 <username> <arg1> <arg2> .. <argn>"
}

test $# -lt 1 && usage

bestserver=$(snmpget -v 1 -c public 10.100.0.1 NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"bestserver\" | awk -F 'STRING: ' '{print $2}')

user="$1"
shift

ssh "$user"@"$bestserver" "$@"
