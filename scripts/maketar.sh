#!/bin/bash
# per ogni file che modifico inserisco una riga nel formato:
#mkdir -p #<path-nella-forma-richiesta>
#scp -F /home/umberto/Scrivania/LabAmm/<nome-dir-della-VM>/ssh.conf default:<path-file-sulla-VM> <path-nella-macchina-host>
#esempio reale:
#mkdir -p Client/attivita1/etc/network/ #<path-nella-forma-richiesta>
#scp -F /home/umberto/Scrivania/LabAmm/R1/ssh.conf default:/etc/network/interfaces Client/attivita1/etc/network/

# creo un archivio tar dei file
# devo essere nella dir indicata
tar cf esame.tar *
# l'archivio viene creato nella directory indicata nel comando
