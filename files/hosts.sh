#!/usr/bin/env bash
cat << EOF > /etc/hosts
127.0.0.1	localhost
172.20.230.73	virt-cl-drbd-0
172.20.230.112	virt-cl-drbd-1
192.168.1.1	virt-cl-drbd-data-0
192.168.1.2	virt-cl-drbd-data-1

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
