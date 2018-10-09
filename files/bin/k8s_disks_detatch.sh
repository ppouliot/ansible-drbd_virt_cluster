#!/usr/bin/env bash
virsh --connect qemu+ssh://virt-cl-drbd-0/system detach-disk vm_ros1 /var/lib/libvirt/images/glusterfs1.qcow2
virsh --connect qemu+ssh://virt-cl-drbd-0/system detach-disk vm_ros2 /var/lib/libvirt/images/glusterfs2.qcow2
virsh --connect qemu+ssh://virt-cl-drbd-0/system detach-disk vm_ros3 /var/lib/libvirt/images/glusterfs3.qcow2
virsh --connect qemu+ssh://virt-cl-drbd-1/system detach-disk vm_ros4 /var/lib/libvirt/images/glusterfs4.qcow2
virsh --connect qemu+ssh://virt-cl-drbd-0/system detach-disk vm_ros5 /var/lib/libvirt/images/glusterfs5.qcow2
rm -rf /var/lib/libvirt/images/glusterfs*.qcow2
ls -lah /var/lib/libvirt/images/*.qcow2

