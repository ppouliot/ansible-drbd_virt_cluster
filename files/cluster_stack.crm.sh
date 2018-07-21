#!/usr/bin/env bash
cat << EOF > /etc/corosync/cluster_stack.crm 
node 1: virt-cl-drbd-0
node 2: virt-cl-drbd-1 \
	attributes standby=off
primitive dlm ocf:pacemaker:controld \
	op monitor interval=120s
primitive drbd ocf:linbit:drbd \
	params drbd_resource=r0 \
	operations $id=drbd-operations \
	op monitor interval=20 role=Master timeout=20 \
	op monitor interval=30 role=Slave timeout=20
primitive etc_libvirt_qemu Filesystem \
	params device="/dev/drbd0" directory="/etc/libvirt/qemu" fstype=ocfs2 \
	op monitor interval=120s
primitive libvirtd lsb:libvirtd \
	op monitor interval=120s
primitive o2cb lsb:o2cb \
	op monitor interval=120s
primitive var_lib_libvirt_images Filesystem \
	params device="/dev/drbd1" directory="/var/lib/libvirt/images" fstype=ocfs2 \
	op monitor interval=120s
ms ms-drbd drbd \
	meta notify=true master-max=2 interleave=true target-role=Started
clone dlm-clone dlm \
	meta globally-unique=false interleave=true target-role=Started
clone libvirtd-clone libvirtd \
	meta globally-unique=false interleave=true target-role=Started
clone mount-ocfs2-etc_libvirt_qemu etc_libvirt_qemu \
	meta interleave=true ordered=true target-role=Started
clone mount-ocfs2-var_lib_libvirt_images var_lib_libvirt_images \
	meta interleave=true ordered=true target-role=Started
clone o2cb-clone o2cb \
	meta globally-unique=false interleave=true target-role=Started
colocation colo-dlm-drbd inf: dlm-clone ms-drbd:Master
colocation colo-etc_libvirt_qemu inf: mount-ocfs2-etc_libvirt_qemu o2cb-clone
colocation colo-o2cb-dlm inf: o2cb-clone dlm-clone
colocation colo-var_lib_libvirt_images inf: mount-ocfs2-var_lib_libvirt_images o2cb-clone
order order-dlm-o2cb 0: dlm-clone o2cb-clone
order order-drbd-dlm 0: ms-drbd:promote dlm-clone
order order-etc_libvirt_qemu-libvirtd 0: mount-ocfs2-etc_libvirt_qemu libvirtd-clone
order order-o2cb-etc_libvirt_qemu 0: o2cb-clone mount-ocfs2-etc_libvirt_qemu
order order-o2cb-var_lib_libvirt_images 0: o2cb-clone mount-ocfs2-var_lib_libvirt_images
order order-var_lib_libvirt_images-libvirtd 0: mount-ocfs2-var_lib_libvirt_images libvirtd-clone
property cib-bootstrap-options: \
	have-watchdog=false \
	cluster-infrastructure=corosync \
	cluster-name=debian \
	stonith-enabled=false \
	no-quorum-policy=ignore \
EOF
