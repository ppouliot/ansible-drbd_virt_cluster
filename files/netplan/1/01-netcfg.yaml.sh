#!/usr/bin/env bash
cat << EOF > /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
#    eno1:
#      dhcp4: yes
    eno2:
      dhcp4: no
      dhcp6: no
      addresses: [192.168.1.2/30]
    eno3:
      dhcp4: no
      dhcp6: no
      addresses: [172.20.230.112/26]
      gateway4: 172.20.230.65
      nameservers:
        addresses: [1.1.1.1,8.8.8.8]
#    eno4:
#      dhcp4: yes

# BOND(LACP 802.3AD)/BOND Pier
#    eno1:
#      dhcp4: no
#      optional: true
#    eno2:
#      dhcp4: no
#      optional: true
#    eno3:
#      dhcp4: no
#    eno4:
#      dhcp4: no
#  bonds:
#    bond0:
#      interfaces: [eno3, eno4]
#      addresses: [172.20.230.112/26]
#      gateway4: 172.20.230.65
#      nameservers:
#        addresses: [1.1.1.1,8.8.8.8]
#      parameters:
#        mode: 802.3ad
#        mii-monitor-interval: 1
# BOND(LACP balance-rr)
#    bond1:
#      interfaces: [eno1, eno2]
#      addresses: [192.168.1.2/30]
#      parameters:
#        mode: balance-rr
#        mii-monitor-interval: 1

EOF
