#!/usr/bin/env bash

echo "Starting DRBD Resource (r0/r1) Devices"
crm resource start ms-drbd-r0
crm resource start ms-drbd-r1
sleep 20

echo "Starting Stonith IPMI Fencing Devices"
crm resource start p_fence_virt-cl-drbd-0
crm resource start p_fence_virt-cl-drbd-1
sleep 20

echo "Starting DLM-Controld Services"
crm resource start dlm-clone
sleep 20

echo "Starting Clustered LVM (CLVMD) Services"
crm resource start clvmd-clone
sleep 20

echo "Starting OCFS2 (O2CB) Services"
crm resource start o2cb-clone
sleep 20

echo "Starting OCFS2 Filesystem Mounts"
crm resource start mount-etc_libvirt_qemu
crm resource start mount-var_lib_libvirt_images
sleep 20

echo "Starting the LibVirt Deamon"
crm resource start libvirtd-clone
sleep 20
