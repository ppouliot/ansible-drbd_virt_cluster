#!/usr/bin/env bash
cat << EOF > /etc/corosync/corosync.conf
totem {
  version: 2

  # How long before declaring a token lost (ms)
  token: 3000

  # How many token retransmits before forming a new configuration
  token_retransmits_before_loss_const: 10

  # How long to wait for join messages in the membership protocol (ms)
  join: 60

  # How long to wait for consensus to be achieved before starting a new round of membership configuration (ms)
  consensus: 5000

  # Turn off the virtual synchrony filter
  vsftype: none

  # Number of messages that may be sent by one processor on receipt of the token
  max_messages: 20

  # Limit generated nodeids to 31-bits (positive signed integers)
  clear_node_high_bit: yes

  # Disable encryption
  secauth: on

  # How many threads to use for encyrption/decryption
  threads: 8

  # This specifies the mode of redundant ring, which may be none, active or passive.
  rrp_mode: none

  cluster_name: drbd
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


logging {
  fileline: off
  to_stderr: yes
  to_logfile: no
  to_syslog: yes
  syslog_facility: daemon
  debug: off
  timestamp: on
  logger_subsys {
    subsys: AMF
    debug: off
    tags: enter|leave|trace1|trace2|trace3|trace4|trace6
  }
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
