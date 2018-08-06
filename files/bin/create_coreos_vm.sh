#!/usr/bin/env bash
if [ !  -f /var/lib/libvirt/images/iso/coreos_production_pxe.vmlinuz ]; then
wget -cv https://alpha.release.core-os.net/amd64-usr/current/coreos_production_pxe.vmlinuz -O /var/lib/libvirt/images/iso/coreos_production_pxe.vmlinuz
fi

if [ !  -f /var/lib/libvirt/images/iso/coreos_production_pxe_image.cpio.gz ]; then
wget -cv https://alpha.release.core-os.net/amd64-usr/current/coreos_production_pxe_image.cpio.gz -O /var/lib/libvirt/images/iso/coreos_production_pxe_image.cpio.gz
fi

virt-install \
        --name $1 \
        --os-type linux \
        --os-variant virtio26 \
        --virt-type kvm \
        --connect=qemu:///system \
        --accelerate \
        --vcpus 2 \
        --ram 4096 \
        --network bridge=br0,model=virtio \
        --serial pty \
        --console pty,target_type=serial \
        --disk path=/var/lib/libvirt/images/$1.qcow2,format=qcow2,size=$2,bus=virtio \
        --nographics \
        --boot kernel=/var/lib/libvirt/images/iso/coreos_production_pxe.vmlinuz,initrd=/var/lib/libvirt/images/iso/coreos_production_pxe_image.cpio.gz,kernel_args=console="ttyS0,115200n9 serial coreos.autologin=ttyS0 cloud-config-url=http://i.pxe.to/cloud-config.yml/coreos-alpha-amd64.pxe_installer.sh"
