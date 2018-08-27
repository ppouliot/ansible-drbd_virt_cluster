#!/usr/bin/env bash
echo "===================================================="
echo "= Hypervisor: virt-cl-drbd-0"
echo "===================================================="
echo
virsh --connect qemu+ssh://virt-cl-drbd-0/system list --all
echo "===================================================="
echo
echo "===================================================="
echo "= Hypervisor: virt-cl-drbd-1"
echo "===================================================="
echo
virsh --connect qemu+ssh://virt-cl-drbd-1/system list --all
echo "===================================================="
