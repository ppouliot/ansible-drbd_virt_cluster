#!/usr/bin/env bash
if [ !  -f /var/lib/libvirt/images/iso/flatcar_production_pxe.vmlinuz ]; then
wget -cv https://alpha.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe.vmlinuz -O /var/lib/libvirt/images/iso/flatcar_production_pxe.vmlinuz
fi

if [ !  -f /var/lib/libvirt/images/iso/flatcar_production_pxe_image.cpio.gz ]; then
wget -cv https://alpha.release.flatcar-linux.net/amd64-usr/current/flatcar_production_pxe_image.cpio.gz -O /var/lib/libvirt/images/iso/flatcar_production_pxe_image.cpio.gz
fi

cat << EOF > /etc/libvirt/qemu/$1.crm
primitive $1 VirtualDomain \
        params config="/etc/libvirt/qemu/$1.xml" hypervisor="qemu:///system" migration_transport=ssh \
        meta allow-migrate=true is-managed="true" target-role=Started \
        op start timeout=120s interval=0 \
        op stop timeout=120s interval=0 \
        op monitor timeout=30 interval=10 depth=0 \
        utilization cpu=2 hv_memory=4096
commit
EOF

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
        --boot kernel=/var/lib/libvirt/images/iso/flatcar_production_pxe.vmlinuz,initrd=/var/lib/libvirt/images/iso/flatcar_production_pxe_image.cpio.gz,kernel_args=console="ttyS0,115200n9 serial flatcar.autologin=ttyS0 cloud-config-url=http://i.pxe.to/cloud-config.yml/flatcar-alpha-amd64.pxe_installer.sh"
