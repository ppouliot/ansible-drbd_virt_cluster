#! /usr/bin/env bash

cat << EOF > /etc/netplan/01-netcfg.yml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    eno1:
      dhcp4: no
      dhcp6: no
      addresses: [192.168.0.1/30]
#      gateway4: 172.20.230.65
#      nameservers:
#        addresses: [1.1.1.1,8.8.8.8]
#    eno1:
#      dhcp4: yes
#      dhcp6: no
#      addresses: [172.20.230.73/26]
#      gateway4: 172.20.230.65
#      nameservers:
#        addresses: [1.1.1.1,8.8.8.8]
    eno3:
      dhcp4: no
      dhcp6: no
      addresses: [172.20.230.73/26]
      gateway4: 172.20.230.65
      nameservers:
        addresses: [1.1.1.1,8.8.8.8]
    eno4:
      dhcp4: yes
#      dhcp6: no
#      addresses: [172.20.230.73/26]
#      gateway4: 172.20.230.65
#      nameservers:
#        addresses: [1.1.1.1,8.8.8.8]
EOF
