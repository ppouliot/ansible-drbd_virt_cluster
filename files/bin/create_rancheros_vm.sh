#!/usr/bin/env bash
RANCHEROS_VERSION=1.4.0
RANCHEROSISO=https://github.com/rancher/os/releases/download/v$RANCHEROS_VERSION/rancheros.iso
if [ !  -f /var/lib/libvirt/images/iso/rancheros-auto.iso ]; then
echo "ISO not found, Retrieving RancherOS $RANCHEROS_VERSION ISO and modifying for local installations."
wget -cv $RANCHEROSISO -O /var/lib/libvirt/images/rancheros.iso
mkdir -p /var/lib/libvirt/images/ros.tmp
mount -o loop /var/lib/libvirt/images/rancheros.iso /var/lib/libvirt/images/ros.tmp
cp -rf /var/lib/libvirt/images/ros.tmp /var/lib/libvirt/images/ros_iso
cat << EOF > /var/lib/libvirt/images/ros_iso/boot/global.cfg
APPEND rancher.autologin=tty1 rancher.autologin=ttyS0 rancher.autologin=ttyS1 rancher.autologin=ttyS1 console=tty1 console=ttyS0,115200n9 serial console=ttyS1 printk.devkmsg=on panic=10 rancher.cloud_init.datasources=[url:http://i.pxe.to/cloud-config.yml/rancheros-1.4.0-amd64.pxe_installer.sh]
EOF
cd /var/lib/libvirt/images/ros_iso && xorriso \
    -as mkisofs \
    -l -J -R -V "RANCHEROS" \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -o /var/lib/libvirt/images/iso/rancheros-auto.iso /var/lib/libvirt/images/ros_iso
sleep 10
umount /var/lib/libvirt/images/ros.tmp
rm -rf /var/lib/libvirt/images/ros.tmp
rm -rf /var/lib/libvirt/images/rancheros.iso
rm -rf /var/lib/libvirt/images/ros_iso
fi
virt-install \
        --name $1 \
        --os-type linux \
        --os-variant ubuntu16.04 \
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
        --cdrom /var/lib/libvirt/images/iso/rancheros-auto.iso

#    --extra-args="
#    console=ttyS0,115200n9 serial
#    rancher.state.dev=LABEL=RANCHER_STATE
#    rancher.state.autoformat=[/dev/sda,/dev/vda]
#    rancher.password=rancher
#    rancher.cloud_init.datasources=[url:http://i.pxe.to/cloud-config.yml/rancheros-1.4.0-amd64.pxe_installer.sh]" 
