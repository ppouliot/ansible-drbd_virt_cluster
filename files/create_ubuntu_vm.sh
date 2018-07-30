#!/usr/bin/env bash
virt-install \
        --name $1 \
        --os-type linux \
        --os-variant ubuntu16.04 \
        --virt-type kvm \
        --connect=qemu:///system \
        --vcpus 2 \
        --ram 4096 \
        --network bridge=br0 \
        --serial pty \
        --console pty,target_type=serial \
        --disk path=/var/lib/libvirt/images/$1.qcow2,format=qcow2,size=40,bus=virtio \
        --nographics \
        --location  'http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64' \
        --extra-args "
    console=ttyS0,115200n9 serial
    auto=true
    priority=critical
    interface=auto
    language=en
    country=JP
    locale=en_US.UTF-8
    console-setup/layoutcode=jp
    console-setup/ask_detect=false
    preseed/url=http://i.pxe.to/preseed/ubuntu-18.04-amd64.preseed
" \
        --network network=default,model=virtio
