#!/bin/bash

#ogni 20 min da 8 a 20 e da lun a ven
#gestito con crontab -e da root
# */20 8-19 * * 1-5 /root/count.sh

#spostare contenuto di nfs.log in nfs.log.last e pulire nfs.log
mv /var/log/nfs.log /var/log/nfs.log.last
#pulisco nfs.log
systemctl restart rsyslog

#dichiaro due array, uno per la lunghezza e uno per il conteggio
declare -A LEN   #conta lunghezza totale
declare -A COUNT #conta pacchetti scambiati

#analizzo il contenuto di nfs.log.last e per ogni IP calcolo la lunghezza tot dei pacchetti e il num totale dei pacchetti
cat /var/log/nfs.log.last | while IFS=_ HEAD S D L TAIL; do
  [[ "$S" =~ "10.111.111." ]] && IP="$S"
  [[ "$D" =~ "10.111.111." ]] && IP="$D"
  ((LEN[$IP] += $L))
  ((COUNT[$IP] += 1))
done

#per ogni macchina che supera i 20MB o scambia 10K pacchetti invoco alert.sh passando l'IP della macchina
#faccio un ciclo sugli array
for C in ${!LEN[$@]}; do
  [[ ${LEN[$C]} -gt 20000000 && ${COUNT[$C]} -gt 10000 ]] && /root/alert.sh $C
done
