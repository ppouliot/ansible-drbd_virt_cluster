#!/usr/bin/env bash
echo "Stopping the LibVirt Deamon"
crm resource stop libvirtd-clone
sleep 10
echo "Stopping OCFS2 Filesystem Mounts"
crm resource stop mount-etc_libvirt_qemu
crm resource stop mount-var_lib_libvirt_images
sleep 10
echo "Stopping OCFS2 (O2CB) Services"
crm resource stop o2cb-clone
sleep 10
echo "Stopping Clustered LVM (CLVMD) Services"
crm resource stop clvmd-clone
sleep 10
echo "Stopping DLM-Controld Services"
crm resource stop dlm-clone
sleep 10
echo "Stopping Stonith IPMI Fencing Devices"
crm resource stop p_fence_virt-cl-drbd-0
crm resource stop p_fence_virt-cl-drbd-1
sleep 10
echo "Stopping DRBD Resource (r0/r1) Devices"
crm resource stop ms-drbd-r0
crm resource stop ms-drbd-r1
