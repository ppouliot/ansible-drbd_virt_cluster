#!/usr/bin/env bash
echo 
echo "==================================================================="
echo "= *** Cluster CIB View of Virtual Machines Running on Cluster *** ="
echo "==================================================================="
crm resource show |grep vm_
echo "==================================================================="
echo 
echo "===================================================="
echo "= Hypervisor View On: virt-cl-drbd-0"
echo "===================================================="
echo
virsh --connect qemu+ssh://virt-cl-drbd-0/system list --all
echo "===================================================="
echo
echo "===================================================="
echo "= Hypervisor View On: virt-cl-drbd-1"
echo "===================================================="
echo
virsh --connect qemu+ssh://virt-cl-drbd-1/system list --all
echo "===================================================="
