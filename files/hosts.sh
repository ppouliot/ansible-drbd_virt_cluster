#!/usr/bin/env bash
cat << EOF > /etc/hosts
127.0.0.1	localhost
172.20.230.73	virt-cl-drbd-0
172.20.230.112	virt-cl-drbd-1
192.168.1.1	virt-cl-drbd-data-0
192.168.1.2	virt-cl-drbd-data-1
172.20.230.138	virt-cl-drbd-ipmi-0
172.20.230.140	virt-cl-drbd-ipmi-1
# 172.20.230.66	virt-cl-drbd-virt0
# 172.20.230.67	virt-cl-drbd-virt1
172.20.230.105	puppet
172.20.230.67	awx
172.20.230.86	ipam1
172.20.230.98 	ipam2
172.20.230.91	quartermaster
172.20.230.100	jenkins


# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
