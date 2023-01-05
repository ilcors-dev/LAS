#!/bin/bash

# ricava l'elenco degli utenti che sono stati presenti sul client negli ultimi 20 minuti

for i in {1..20}; do
    /usr/bin/last -p -${i}min
done | awk '{ print $1 }' | sort -u | xargs | tr ' ' '_'

# xargs rimuove any blank lines trovate nel file
# tr ' ' '_' sostituisce ogni spazio con un '_' così da rendere più facile il parsing dall'output di SNMP
