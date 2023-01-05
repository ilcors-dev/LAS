#!/bin/bash
vagrant ssh-config >ssh.conf

mkdir -p examfiles/router1/attivita0
mkdir -p examfiles/router2/attivita0

scp -pr -F ssh.conf router1:/etc/network/interfaces.d/eth1_cfg ./examfiles/router1/attivita0/eth1_cfg
scp -pr -F ssh.conf router1:/etc/network/interfaces.d/eth2_cfg ./examfiles/router1/attivita0/eth2_cfg
scp -pr -F ssh.conf router1:/etc/dnsmasq.d/dnsmasq.conf ./examfiles/router1/attivita0/dnsmasq.conf
scp -pr -F ssh.conf router1:/etc/sysctl.conf ./examfiles/router1/attivita0/sysctl.conf
# altri files...

scp -pr -F ssh.conf router2:/etc/network/interfaces.d/eth1_cfg ./examfiles/router2/attivita0/eth1_cfg
scp -pr -F ssh.conf router2:/etc/network/interfaces.d/eth2_cfg ./examfiles/router2/attivita0/eth2_cfg
scp -pr -F ssh.conf router2:/etc/dnsmasq.d/dnsmasq.conf ./examfiles/router2/attivita0/dnsmasq.conf
scp -pr -F ssh.conf router2:/etc/sysctl.conf ./examfiles/router2/attivita0/sysctl.conf
# altri files...

tar cf examfiles.tar examfiles
