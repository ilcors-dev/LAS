#!/bin/bash

# Realizzare su Router1 lo script alert.sh che accetta come parametro un IP di un client e via SNMP
# ricava l'elenco degli utenti che sono stati presenti sul client negli ultimi 20 minuti. L'elenco ottenuto
# deve essere scritto in append sul file /root/active.users, dopo di chè, se un utente compare in tale
# file più di 50 volte, il suo nome deve essere aggiunto al file /root/bad.users

ipRegex=^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$

if [[ $# -ne 1 || ! $1 =~ $ipRegex ]]; then
    echo "Usage: $0 <ip>"
    exit 1
fi

# prende l'output dal MIB, lo parsa e rimpiazza ogni '_' (usato come delimitatore degli utenti) con una blank line
# in modo che il while legga riga-per-riga
snmpget -v 1 -c public "$1" NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"lastactive\" |
    awk -F 'STRING: ' '{print $2}' |
    tr '_' '\n' >>/root/active.users

tmp=$(mktemp)

while IFS= read -r user; do
    # skip processed users!
    test $(cat "$tmp" | grep "$user" | wc -l) -gt "0" && continue

    count=$(cat /root/active.users | grep "$user" | wc -l)
    echo "$user appears $count"

    [[ "$count" -gt 50 ]] && echo "$user" >>/root/bad.users && echo "bad user: $user!"

    echo "$user" >>"$tmp"
done </root/active.users

rm "$tmp"
