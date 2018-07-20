#!/usr/bin/env bash
cat << EOF > /etc/ocfs2/cluster.conf
node: 
  ip_port = 7777
  ip_address = 192.168.1.1
  number = 0
  name = virt-cl-drbd-0
node:
  ip_port = 7777
  ip_address = 192.168.1.2
  number = 1
  name = virt-cl-drbd-1
cluster:
  node_count = 2
  name = ocfs2

EOF
