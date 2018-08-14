#!/usr/bin/env bash
cat << EOF > /etc/corosync/service.d/pcmk
service {
  # Load the Pacemaker Cluster Resource Manager
  name: pacemaker
  ver: 1
}
EOF
