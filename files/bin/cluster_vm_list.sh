#!/usr/bin/env bash
echo "####################################################"
echo "###       virt-cl-drbd-0 virtual machines        ###"
echo "####################################################"
virsh --connect qemu+ssh://virt-cl-drbd-0/system list
echo 
echo "####################################################"
echo "###       virt-cl-drbd-1 virtual machines        ###"
echo "####################################################"
virsh --connect qemu+ssh://virt-cl-drbd-1/system list
