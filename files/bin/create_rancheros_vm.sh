#!/usr/bin/env bash

virt-install \
        --name $1 \
        --os-type linux \
        --os-variant ubuntu16.04 \
        --virt-type kvm \
        --connect=qemu:///system \
        --accelerate \
        --vcpus 2 \
        --ram 4096 \
        --network bridge=br0,model=virtio
        --serial pty \
        --console pty,target_type=serial \
        --disk path=/var/lib/libvirt/images/$1.qcow2,format=qcow2,size=$2,bus=virtio \
        --nographics \
        --location  'http://archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64' \
#         --extra-args="
# rancher.state.dev=LABEL=RANCHER_STATE rancher.state.autoformat=[/dev/sda,/dev/vda] rancher.password=password rancher.cloud_init.datasources=['url:http://${HH}/${CF}']" \
        --extra-args "
    console=ttyS0,115200n9 serial
    rancher.state.dev=LABEL=RANCHER_STATE
    rancher.state.autoformat=[/dev/sda,/dev/vda]
#    rancher.password=password
    rancher.cloud_init.datasources=[url:http://i.pxe.to/cloud-config.yml/rancheros-1.4.0-amd64.pxe_installer.sh]" 
