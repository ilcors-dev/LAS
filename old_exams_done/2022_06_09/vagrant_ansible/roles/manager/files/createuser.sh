#!/bin/bash

tail -f /var/log/requests.log | (
    while read line; do
        echo $line
        USRNAME=$(echo "$line" | cut -d'_' -f1)
        PASSWD=$(echo "$line" | cut -d'_' -f2)

        printf "dn: uid=$USRNAME,ou=Esame,dc=labammsis
objectClass: top
objectClass: account
objectClass: posixAccount
objectClass: shadowAccount
cn: $USRNAME
uid: $USRNAME
uidNumber: 16859
gidNumber: 100
homeDirectory: /tmp
loginShell: /bin/bash
gecos: $USRNAME
userPassword: $PASSWD
shadowLastChange: 0
shadowMax: 0
shadowWarning: 0\n" >/tmp/"$USRNAME".ldif

        ldapadd -x -D cn=admin,dc=labammsis -w gennaio.marzo -H ldapi:/// -f /tmp/"$USRNAME".ldif
    done
)
