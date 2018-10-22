#!/usr/bin/env bash
VYOS_VERSION=1.1.8
VYOS_URL=https://downloads.vyos.io/release/$VYOS_VERSION/
VYOS_ISO=vyos-$VYOS_VERSION-amd64.iso

if [ !  -f /var/lib/libvirt/images/iso/vyos-auto.iso ]; then
echo "ISO not found, Retrieving VyOS $VYOS_VERSION ISO and modifying for local installations."
wget -cv $VYOS_URL/$VYOS_ISO -O /var/lib/libvirt/images/iso/$VYOS_ISO


mkdir -p /var/lib/libvirt/images/vyos.tmp
mount -o loop /var/lib/libvirt/images/iso/$VYOS_ISO /var/lib/libvirt/images/vyos.tmp
cp -rf /var/lib/libvirt/images/vyos.tmp /var/lib/libvirt/images/vyos_iso

cat << EOF > /var/lib/libvirt/images/vyos_iso/isolinux/live.cfg
label live
	menu label Live
	kernel /live/vmlinuz
	append initrd=/live/initrd.img boot=live config hostname=vyos union=unionfs  quiet console=ttyS0,115200n9 serial

label livefailsafe
	menu label Live (failsafe)
	kernel /live/vmlinuz
	append initrd=/live/initrd.img boot=live config hostname=vyos union=unionfs  noapic noapm nodma nomce nolapic nomodeset nosmp vga=normal console=ttyS0,115200n9 serial

label linux
	kernel /live/vmlinuz
	append initrd=/live/initrd.img boot=live config hostname=vyos union=unionfs  quiet console=ttyS0,115200n9 serial

label linuxfailsafe
	kernel /live/vmlinuz
	append initrd=/live/initrd.img boot=live config hostname=vyos union=unionfs  noapic noapm nodma nomce nolapic nomodeset nosmp vga=normal console=ttyS0,115200n9 serial






#label floppy
#	localboot 0x00

#label disk1
#	localboot 0x80

#label disk2
#	localboot 0x81

#label nextboot
#	localboot -1

EOF
cat << EOF > /var/lib/libvirt/images/vyos_iso/isolinux/isolinux.cfg
serial 0 115200 0
console 0
timeout 50
display boot.txt
prompt 1

F1 f1.txt
F2 f2.txt
F3 f3.txt
F4 f4.txt
F5 f5.txt
F6 f6.txt
F7 f7.txt
F8 f8.txt
F9 f9.txt
F0 f10.txt

default live

label live
	linux /live/vmlinuz
	append console=ttyS0,115200n9 serial console=tty0 quiet initrd=/live/initrd.img boot=live nopersistent noautologin nonetworking nouser hostname=vyos

label live-console
	linux /live/vmlinuz
	append quiet console=ttyS0,115200n9 serial initrd=/live/initrd.img boot=live nopersistent noautologin nonetworking nouser hostname=vyos

label live-serial
	linux /live/vmlinuz
	append console=ttyS0,115200n9 serial quiet initrd=/live/initrd.img boot=live nopersistent noautologin nonetworking nouser hostname=vyos

label live-debug
	linux /live/vmlinuz
	append console=ttyS0,115200n9 serial console=tty0 debug verbose initrd=/live/initrd.img boot=live nopersistent noautologin nonetworking nouser hostname=vyos


EOF
cd /var/lib/libvirt/images/vyos_iso && xorriso \
    -as mkisofs \
    -l -J -R -V "VYOS" \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    -b isolinux/isolinux.bin -c isolinux/boot.cat \
    -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin \
    -o /var/lib/libvirt/images/iso/vyos-auto.iso /var/lib/libvirt/images/vyos_iso
sleep 10
umount /var/lib/libvirt/images/vyos.tmp
rm -rf /var/lib/libvirt/images/vyos.tmp
rm -rf /var/lib/libvirt/images/vyos.iso
rm -rf /var/lib/libvirt/images/vyos_iso
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
        --os-variant ubuntu16.04 \
        --virt-type kvm \
        --connect=qemu:///system \
        --accelerate \
        --vcpus 1 \
        --ram 1024 \
        --network bridge=br0,model=virtio \
        --serial pty \
        --console pty,target_type=serial \
        --disk path=/var/lib/libvirt/images/$1.qcow2,format=qcow2,size=$2,bus=virtio \
        --nographics \
        --cdrom /var/lib/libvirt/images/iso/vyos-auto.iso
