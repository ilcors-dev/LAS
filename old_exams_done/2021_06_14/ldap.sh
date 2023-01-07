#!/bin/bash

# Su ognuno di due Server (idealmente quelli configurati all'esercizio 1, o se non si è svolto questo, sul server preconfigurato durante il corso e su di un
# suo clone),

# • Installare una directory LDAP per l'autenticazione centralizzata
# • Realizzare uno script ldap.sh che svolga queste operazioni:

# a) Se è presente un parametro di valore "new", devono essere cancellate dalla directory locale tutte le entry sotto ou=People,dc=labammsis, e
# devono essere sostituite col contenuto del file /tmp/dir.backup del Router, prelevato via SSH/SCP

# b) Se non è presente alcun parametro, deve essere fatto un dump in formato LDIF di tutte le entry sotto ou=People,dc=labammsis, e trasferito via
# SSH/SCP nel file /tmp/dir.backup del Router

# c) Se è presente un parametro ma di valore diverso, o più parametri, devono essere loggati via syslog sul file /var/log/ldap.errors del Router

# Nota: i trasferimenti via SSH devono essere automatizzati, e non richiedere password

if [[ "$1" == "new" && -z "$2" ]]; then
    ldapsearch -x -LLL -D cn=admin,dc=labammsis -b ou=People,dc=labammsis -s one -w gennaio.marzo -H ldapi:/// |
        egrep ^dn: | ldapdelete -x -D "cn=admin,dc=labammsis" -w gennaio.marzo -b dc=labammsis -H ldapi:///

    file=$(scp 10.20.20.254:/tmp/dir.backup ./dir.backup)

    ssh 10.20.20.254 "cat /tmp/dir.backup | ldapadd -x -D cn=admin,dc=labammsis -w gennaio.marzo -b dc=labammsis"

    rm dir.backup
elif [[ "$#" -eq "0" ]]; then
    tmp=$(mktemp)

    res=$(ldapsearch -x -LLL -D cn=admin,dc=labammsis -b ou=People,dc=labammsis -s one -w gennaio.marzo -H ldapi:/// >"$tmp")

    scp "$tmp" 10.20.20.254:/tmp/dir.backup

    rm "$tmp"
else
    logger -n 10.20.20.254 -p local1.info "$@"
fi
