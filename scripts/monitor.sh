#!/bin/bash
# in router1
module(load="imudp")
input(type="imudp" port="514")
local1.=info: /var/log/nfs.log

#controlla il traffico di NFS proveniente dalla porta 2049 del server e scrive sul syslog di un altro router
                        #prende i pacchetti che passano per la porta 2049                                                #legge una riga e la divide ogni in elementi
tcpdump -i eth2 -nlp '((dst net 10.222.222.222.0/24 and dst port 2049) or (src net 10.222.222.0/24 and src port 2049))' 
| while read T P SRC V DST RESTO ; do
  SIP=$(cut -f1-4 -d. <<< $SRC) #taglia l'elemento sorgente per prendere l'indirizzo e lo mette in una variabile
  DIP=$(cut -f1-4 -d. <<< $DST) #taglia l'elemento destinazione per prendere l'indirizzo e lo mette in una variabile
  LEN=$(awk -F 'length ' '{print $2}' <<< $RESTO) #riconosce il pattern con awk e prende la lunghezza
  #fa logging al server remoto delle tre info prese prima
  logger -n 192.168.56.101 -p local1.info "_${SIP}_${DIP}_${LEN}_" < /dev/null
done
