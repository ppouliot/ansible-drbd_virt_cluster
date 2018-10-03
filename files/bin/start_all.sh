#!/usr/bin/env bash
set -x
crm resource start ms-drbd0
sleep 120
crm resource start hasi-clone
sleep 30
crm resource start p_fence_virt-cl-drbd-0
crm resource start p_fence_virt-cl-drbd-1
crm resource start vm_ipam1
crm resource start vm_ipam2
crm resource start vm_puppetmaster
crm resource start vm_quartermaster
crm resource start vm_jenkins
crm resource start vm_awx
crm resource start vm_maas
crm resource start vm_ros1
crm resource start vm_ros2
crm resource start vm_ros3
crm resource start vm_ros4
crm resource start vm_ros5
crm resource start vm_ros6
crm resource start vm_ros7


