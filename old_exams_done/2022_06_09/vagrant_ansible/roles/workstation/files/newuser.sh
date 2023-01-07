#!/bin/bash

# Si realizzi uno script newuser.sh che dovrà essere reso disponibile nella cartella /usr/bin di tutte le Workstation, e avere le seguenti caratteristiche:
# Deve poter essere eseguito solo dall'amministratore di sistema.
# Riceve come unico parametro sulla riga di comando lo username di un utente da creare.
# Chiede interattivamente all'amministratore la password.
# Invia via syslog al Manager queste informazioni, perché vengano scritte sul file /var/log/requests.log

test $# -eq 0 && echo "Usage: $0 username" && exit 1

# check if user exists
id $1 &>/dev/null

if [ $? -eq 0 ]; then
    echo "User $1 already exists"
else
    echo "Creating user $1"
    echo "Please enter password for user $1"
    read -s password

    # send syslog message
    logger -p local1.info -n 172.16.1.1 "$1_$password"
fi
