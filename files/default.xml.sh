#!/usr/bin/env bash
cat << EOF > /etc/libvirt/qemu/networks/default.xml
<!-- Bridge Configured by Ansible OCFS must be mounted to get to this file --!>
<network>
  <name>default</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
<!--
Begin Original /etc/libvirt/qemu/networks/default.xml

WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh net-edit default
or other application using the libvirt API.

<network>
  <name>default</name>
  <uuid>ed02ec20-6fda-440e-8be2-1870e01a31f1</uuid>
  <forward mode='nat'/>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:c4:d5:e6'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.2' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
-->
EOF
