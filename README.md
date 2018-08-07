# ansible-drbd_virt_cluster

A Traditional 2 Node Linux HA Virtualization cluster using DRBD/CLVM/OCFS2/Corosync/Pacemaker with IPMI fencing on Ubuntu 18.04

## Description

This is for building, and configuring a traditional two node Linux highly available KVM virtualization cluster using the following technologies to provide a managed shared storage infrastructure and highly avaiable virtual machine instances.

  1. **DRBD** - Distributed Replicated Block Device.   Each node is cross connected over a 10G (eno1) interface which is configured for a /30 subnet.  This will be used as the primary interface for storage replication across the DRBD nodes.

  1. **CLVM** - Cluster LVM.  LVM is enabled for clustering and the /dev/DRBD0 device is used as a physical in the CLVM volume group.

  1. **OCFS2** - Oracle Clustered Filesystem (Version 2).  OCFS2 provides a shared file system which enables each node to both read and write to the filesystem on the DRBD0 device at the same time.   The O2CB cluster resource provides the necessary locking to prevent contention between nodes.   The ocfs2 filesystems are mounted at /etc/libvirt/qemu for providing a shared location for virtual machine (qemu/KVM) xml configuration files, and /var/lib/libvirt/images for the qcow2 file backed virtual machines operating within the cluster.

  1. **Corosync** - Corosync is the component of the linux-ha stack that provides the communication mechinism for the cluster and quorum.

  1. **Pacemaker** - Pacemaker provides the misc cluster resource definitions for the different resources types used in the cluster.

  1. **Stonith** - Stonith(Shoot The Other Node In The Head).  Stonith is a fencing mechnism for preventing split brain scenerios and for split brain recovery. In our case we configure the cluster to use the physical nodes IPMI interfaces to forcefully fence (reboot) the node to prevent storage corruption.

## Additionall Technologies Used

  1. **KVM/Libvirt/QEMU** -  The standard KVM/Libvirt/QEMU stack is used for providing virtualization.  Virtualization networking is provided by a LACP bond on network interfaces ens3 and ens4. Virtualization management and VM egress traffic is places upon a br0 which resised on top of the bonded interface (bond0).  Virtual Machine deployment are configured for lights out management, meaning all VM console operations when deployed using the provided scripts are configured for serial communications.  This ensure virtual machine consoles are accessable when managing the physical hypervisor hosts over ssh.  (This is currently only privided for CentOS 7, Ubuntu 18.0LTS, CoreOS and RancherOS, as well as generic PXE via the create_*_vm.sh scripts here: [./files/bin](./files/bin) ." )

  1. **Munin** - Munin provides a light weight monitoring infrastructure to gain performance visualization across the cluster.  It is currently hosted upon a virtual ip across the cluster, the cluster resource can be migrated across both nodes should one of the nodes be need to be taken down.   It's hosted via the a location config of the default nginx site configured on each hypervisor host in the cluster.

## Basic Cluster Operations
## Cluster Operations
## Resources

### Linux HA Reference

* [http://www.linux-ha.com/wiki/Documentation](http://www.linux-ha.com/wiki/Documentation)

### Netplan

* [https://netplan.io/examples#bonding](https://netplan.io/examples#bonding)

### DRBD Active/Active

* [https://mihaiush.wordpress.com/2013/06/10/debian-wheezy-drbd-primaryprimary-corosync-clvm-ocfs2/](https://mihaiush.wordpress.com/2013/06/10/debian-wheezy-drbd-primaryprimary-corosync-clvm-ocfs2/)

#### DRBD Recovery

* [https://www.recitalsoftware.com/blogs/29-howto-resolve-drbd-split-brain-recovery-manually](https://www.recitalsoftware.com/blogs/29-howto-resolve-drbd-split-brain-recovery-manually)


### CLVM

* [https://support.hpe.com/hpsc/doc/public/display?docId=mmr_kc-0110251](https://support.hpe.com/hpsc/doc/public/display?docId=mmr_kc-0110251)

### Stonith

* [https://www.suse.com/documentation/sle-ha-12/singlehtml/book_sleha/book_sleha.html#sec.ha.config.crm.resources](https://www.suse.com/documentation/sle-ha-12/singlehtml/book_sleha/book_sleha.html#sec.ha.config.crm.resources)
* [https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/8/html/director_installation_and_usage/sect-fencing_the_controller_nodes](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/8/html/director_installation_and_usage/sect-fencing_the_controller_nodes)

### Pacemaker

* [https://wiki.clusterlabs.org/wiki/Pacemaker](https://wiki.clusterlabs.org/wiki/Pacemaker)
* [https://github.com/ClusterLabs/pacemaker/blob/master/doc/pcs-crmsh-quick-ref.md](https://github.com/ClusterLabs/pacemaker/blob/master/doc/pcs-crmsh-quick-ref.md)

### LibVirt/QEMU

#### virt-install pxe

* [https://zacloudbuilder.wordpress.com/2013/07/22/using-virt-install-to-do-a-pxe-based-installation/](https://zacloudbuilder.wordpress.com/2013/07/22/using-virt-install-to-do-a-pxe-based-installation/)

#### virt-install serial console

[https://www.reddit.com/r/linuxadmin/comments/5g7tkw/virtinstall_pxe_stuck_at_domain_installation/](https://www.reddit.com/r/linuxadmin/comments/5g7tkw/virtinstall_pxe_stuck_at_domain_installation/)
