#!/bin/bash

# Si configuri sulle Workstation l'agent SNMP per poter esporre tramite un managed object il numero totale di processi in esecuzione da parte di utenti del gruppo esame.

# Si realizzi uno script monitor.sh che dovrà essere collocato nella cartella /usr/bin  del Manager e avere le seguenti caratteristiche:

# viene lanciato ogni 5 minuti

# interroga in parallelo tutte le workstation potenzialmente attive

# scrive via syslog sul file /var/log/processes.log i risultati (uno per riga) nel formato IPWorkstation_NumeroProcessi

cat /var/lib/misc/dnsmasq.leases | cut -d' ' -f3 | (
    while read workstationIp; do
        proc=$(snmpget -v 1 -c public "$workstationIp" -On NET-SNMP-EXTEND-MIB::nsExtendOutputFull.\"monitoresame\" | awk -F 'STRING: ' '{print $2}')

        logger -p local2.info "$workstationIp"_"$proc"
    done
)
