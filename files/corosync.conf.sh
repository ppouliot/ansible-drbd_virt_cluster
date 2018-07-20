#!/usr/bin/env bash
cat << EOF > /etc/corosync/corosync.conf
totem {
  version: 2
  cluster_name: drbd
  secauth: off
  transport: udpu
  interface: {
    member {
      memberaddr: 192.168.1.1
    }
    member {
      memberaddr: 192.168.1.2
    }
    ringnumber: 0		
    binnetaddr: 192.168.1.3
    broadcast: yes
    mcastport: 5405
  }
}

amf {
  mode: disabled
}

aisexec {
  user: root
  group: root
}

nodelist {
  node {
    ring0_addr: 192.168.1.1
    name: virt-cl-drbd-0
    nodeid: 1
  }
  node {
    ring0_addr: 192.168.1.2
    name: virt-cl-drbd-1
    nodeid: 2
  }
}
quorum {
  provider: corosync_votequorum
  two_node: 1
}
EOF
