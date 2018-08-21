#!/usr/bin/env bash
cat << EOF > /etc/corosync/cluster_stack.crm 
node 1: virt-cl-drbd-0 \
	attributes standby=off
node 2: virt-cl-drbd-1 \
	attributes standby=off
primitive p_dlm ocf:pacemaker:controld \
	op monitor interval=120 timeout=30 \
	op start interval=0 timeout=90 \
	op stop interval=0 timeout=100
primitive p_drbd_r0 ocf:linbit:drbd \
	params drbd_resource=r0 \
	op monitor interval=50 role=Master timeout=20 \
	op monitor interval=60 role=Slave timeout=20 \
	op start interval=0 timeout=240 \
	op stop interval=0 timeout=100
primitive p_drbd_r1 ocf:linbit:drbd \
	params drbd_resource=r1 \
	op monitor interval=20 role=Master timeout=20 \
	op monitor interval=30 role=Slave timeout=20 \
	op start interval=0 timeout=240 \
	op stop interval=0 timeout=100
primitive p_etc_libvirt_qemu Filesystem \
	params device="/dev/drbd0" directory="/etc/libvirt/qemu" fstype=ocfs2 \
	op monitor interval=120s
primitive p_fence_virt-cl-drbd-0 stonith:fence_ipmilan \
	params pcmk_host_list=virt-cl-drbd-0 ipaddr=172.20.230.138 action=reboot login=root passwd=calvin lanplus=1 cipher=1 delay=5 \
	op monitor interval=60s \
	meta target-role=Started
primitive p_fence_virt-cl-drbd-1 stonith:fence_ipmilan \
	params pcmk_host_list=virt-cl-drbd-1 ipaddr=172.20.230.140 action=reboot login=root passwd=calvin lanplus=1 cipher=1 delay=5 \
	op monitor interval=60s \
	meta target-role=Started
primitive p_libvirtd lsb:libvirtd \
	op monitor interval=120s
primitive p_nginx nginx \
	params configfile="/etc/nginx/nginx.conf" \
	op monitor interval=10 timeout=60 \
	op start interval=0 timeout=40 \
	op stop interval=0 timeout=60
primitive p_o2cb lsb:o2cb \
	op monitor interval=120s
primitive p_var_lib_libvirt_images Filesystem \
	params device="/dev/drbd1" directory="/var/lib/libvirt/images" fstype=ocfs2 \
	op monitor interval=120s
primitive p_virtual_ip IPaddr2 \
	params ip=172.20.230.66 cidr_netmask=32 \
	op monitor interval=10s \
	meta migration-threshold=10
group nginx-balanced p_virtual_ip p_nginx \
	meta target-role=Started
ms ms-drbd-r0 p_drbd_r0 \
	meta notify=true master-max=2 clone-max=2 interleave=true target-role=Started
ms ms-drbd-r1 p_drbd_r1 \
	meta notify=true master-max=2 clone-max=2 interleave=true target-role=Started
clone dlm-clone p_dlm \
	meta globally-unique=false interleave=true target-role=Started
clone libvirtd-clone p_libvirtd \
	meta globally-unique=false interleave=true target-role=Started
clone mount-etc_libvirt_qemu p_etc_libvirt_qemu \
	meta interleave=true ordered=true target-role=Started
clone mount-var_lib_libvirt_images p_var_lib_libvirt_images \
	meta interleave=true ordered=true target-role=Started
clone o2cb-clone p_o2cb \
	meta globally-unique=false interleave=true target-role=Started
colocation colo-dlm-drbd-r0 inf: dlm-clone ms-drbd-r0:Master
colocation colo-dlm-drbd-r1 inf: dlm-clone ms-drbd-r1:Master
colocation colo-etc_libvirt_qemu inf: mount-etc_libvirt_qemu o2cb-clone
colocation colo-o2cb-dlm inf: o2cb-clone dlm-clone
colocation colo-var_lib_libvirt_images inf: mount-var_lib_libvirt_images o2cb-clone
location l_fence_virt-cl-drbd-0 p_fence_virt-cl-drbd-0 -inf: virt-cl-drbd-0
location l_fence_virt-cl-drbd-1 p_fence_virt-cl-drbd-1 -inf: virt-cl-drbd-1
order order-dlm-o2cb 0: dlm-clone o2cb-clone
order order-drbd-r0-ha_infra 0: ms-drbd-r0:promote dlm-clone
order order-drbd-r1-ha_infra 0: ms-drbd-r1:promote dlm-clone
order order-etc_libvirt_qemu-libvirtd 0: mount-etc_libvirt_qemu libvirtd-clone
order order-o2cb-etc_libvirt_qemu 0: o2cb-clone mount-etc_libvirt_qemu
order order-o2cb-var_lib_libvirt_images 0: o2cb-clone mount-var_lib_libvirt_images
order order-var_lib_libvirt_images-libvirtd 0: mount-var_lib_libvirt_images libvirtd-clone
property cib-bootstrap-options: \
	have-watchdog=false \
	cluster-infrastructure=corosync \
	cluster-name=debian \
	stonith-enabled=true \
	no-quorum-policy=ignore \
commit
EOF
