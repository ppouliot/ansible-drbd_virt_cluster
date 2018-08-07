# ansible-drbd_virt_cluster

A Traditional 2 Node Linux HA Virtualization cluster using DRBD/CLVM/OCFS2/Corosync/Pacemaker with IPMI fencing on Ubuntu 18.04


## Resources

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

* [https://zacloudbuilder.wordpress.com/2013/07/22/using-virt-install-to-do-a-pxe-based-installation/](https://zacloudbuilder.wordpress.com/2013/07/22/using-virt-install-to-do-a-pxe-based-installation/)
