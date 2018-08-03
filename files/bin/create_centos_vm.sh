#!/usr/bin/env bash
virt-install \
        --name $1 \
        --os-type linux \
        --os-variant rhel7 \
        --virt-type kvm \
        --connect=qemu:///system \
        --vcpus 2 \
        --ram 4096 \
        --network bridge=br0,model=virtio \
        --serial pty \
        --console pty,target_type=serial \
        --disk path=/var/lib/libvirt/images/$1.qcow2,format=qcow2,size=$2,bus=virtio \
        --nographics \
        --location  'http://mirror.centos.org/centos-7/7/os/x86_64/' \
        --extra-args "
    console=ttyS0,115200n9 serial
    ksdevice=eth0 ks=http://i.pxe.to/kickstart/centos-7.4.1708-x86_64.kickstart"
