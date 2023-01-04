#/!bin/bash

# Realizzare su Router1 lo script check.sh che accetta come parametro un IP di un client e via SNMP ricava l'elenco degli utenti che sono
#stati presenti sul client negli ultimi 15 minuti. L'elenco ottenuto deve essere scritto in append sul file /root/users.warning, dopo di chè,
#se un utente compare nel file più di 10 volte, il suo nome deve essere aggiunto al file /root/users.abuse

#in /etc/snmp/snmpd.conf inserisco:
# extend-sh lastusers for i in {1..15} ; do last -p -${i}min ;
# done | awk '{ print $1 }' | sort -u

# richiesta snmpget
snmpget -Oqv -v 1 -c public "$1" NET-SNMP-EXTENDMIB::nsExtendOutputFull.\"lastusers\" >>/root/active.users
sort /root/active.users | uniq -c | while read COUNT USR; do
  if [[ "$COUNT" -ge 10 ]]; then
    echo "$USR" >>/root/bad.users
  fi
done
