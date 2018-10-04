# ansible-drbd_virt_cluster

A Traditional 2 Node Linux HA Virtualization cluster using DRBD/CLVM/OCFS2/Corosync/Pacemaker with IPMI fencing on Ubuntu 18.04

## Description

This is for building, and configuring a traditional two node Linux highly available KVM virtualization cluster using the following technologies to provide a managed shared storage infrastructure and highly avaiable virtual machine instances. Currently this is a work in progress.  Removing any comments an running the site.yml should in theory produce the a working cluster stack.  Slight moficiations may apply.

  1. **DRBD** - Distributed Replicated Block Device.   Each node is cross connected over a 10G (eno1) interface which is configured for a /30 subnet.  This will be used as the primary interface for storage replication across the DRBD nodes.

  1. **DLM** - Distributed Locking Manager.  Criticial for cluster operations  and split brain prevention.

  1. **CLVM** - Cluster LVM.  LVM is enabled for clustering and the /dev/DRBD0 device is used as a physical in the CLVM volume group.

  1. **OCFS2** - Oracle Clustered Filesystem (Version 2).  OCFS2 provides a shared file system which enables each node to both read and write to the filesystem on the DRBD0 device at the same time.   The O2CB cluster resource provides the necessary locking to prevent contention between nodes.   The ocfs2 filesystems are mounted at /etc/libvirt/qemu for providing a shared location for virtual machine (qemu/KVM) xml configuration files, and /var/lib/libvirt/images for the qcow2 file backed virtual machines operating within the cluster.

  1. **Corosync** - Corosync is the component of the linux-ha stack that provides the communication mechinism for the cluster and quorum.

  1. **Pacemaker** - Pacemaker provides the misc cluster resource definitions for the different resources types used in the cluster.

  1. **Stonith** - Stonith(Shoot The Other Node In The Head).  Stonith is a fencing mechnism for preventing split brain scenerios and for split brain recovery. In our case we configure the cluster to use the physical nodes IPMI interfaces to forcefully fence (reboot) the node to prevent storage corruption.

## Additional Technologies Used

  1. **KVM/Libvirt/QEMU** -  The standard KVM/Libvirt/QEMU stack is used for providing virtualization.  Virtualization networking is provided by a LACP bond on network interfaces ens3 and ens4. Virtualization management and VM egress traffic is places upon a br0 which resised on top of the bonded interface (bond0).  Virtual Machine deployment are configured for lights out management, meaning all VM console operations when deployed using the provided scripts are configured for serial communications.  This ensure virtual machine consoles are accessable when managing the physical hypervisor hosts over ssh.  (This is currently only privided for CentOS 7, Ubuntu 18.0LTS, CoreOS and RancherOS, as well as generic PXE via the create_*_vm.sh scripts here: [./files/bin](./files/bin) ." )

  1. **Munin** - Munin provides a light weight monitoring infrastructure to gain performance visualization across the cluster.  It is currently hosted upon a virtual ip across the cluster, the cluster resource can be migrated across both nodes should one of the nodes be need to be taken down.   It's hosted via the a location config of the default nginx site configured on each hypervisor host in the cluster.


## Basic Cluster Operations

* **To edit the running CRM CIB**

```
root@virt-cl-drbd-0:~# crm configure edit
```

* **Check running cluster resources status (crm_mon -1)**

  Removing the '-1' from the crm_mon command will keep the status running in the forground.  This is useful for watching as you start the cluster resources.

```
root@virt-cl-drbd-0:~# crm_mon -1
Stack: corosync
Current DC: virt-cl-drbd-1 (version 1.1.18-2b07d5c5a9) - partition with quorum
Last updated: Tue Aug  7 09:47:15 2018
Last change: Tue Aug  7 09:47:13 2018 by root via cibadmin on virt-cl-drbd-0

2 nodes configured
26 resources configured

Online: [ virt-cl-drbd-0 virt-cl-drbd-1 ]

Active resources:

 p_fence_virt-cl-drbd-0	(stonith:fence_ipmilan):	Started virt-cl-drbd-1
 p_fence_virt-cl-drbd-1	(stonith:fence_ipmilan):	Started virt-cl-drbd-0
 Resource Group: g_vip_nginx
     p_virtual_ip	(ocf::heartbeat:IPaddr2):	Started virt-cl-drbd-0
     p_nginx	(ocf::heartbeat:nginx):	Started virt-cl-drbd-0
 Master/Slave Set: ms-drbd0 [p_drbd_r0]
     Masters: [ virt-cl-drbd-0 virt-cl-drbd-1 ]
 Clone Set: hasi-clone [g_hasi]
     Started: [ virt-cl-drbd-0 virt-cl-drbd-1 ]
 vm_ipam1	(ocf::heartbeat:VirtualDomain):	Started virt-cl-drbd-1
 vm_ipam2	(ocf::heartbeat:VirtualDomain):	Started virt-cl-drbd-0
 vm_jenkins	(ocf::heartbeat:VirtualDomain):	Started virt-cl-drbd-0
 vm_quartermaster	(ocf::heartbeat:VirtualDomain):	Started virt-cl-drbd-1
 vm_awx	(ocf::heartbeat:VirtualDomain):	Started virt-cl-drbd-1
 vm_puppetmaster	(ocf::heartbeat:VirtualDomain):	Started virt-cl-drbd-0
```

* **Check running cluster resources status (drbdadm status)**

```
root@virt-cl-drbd-0:~# drbdadm status
r0 role:Primary
  disk:UpToDate
  virt-cl-drbd-1 role:Primary
    peer-disk:UpToDate
```

* **Show all configured cluster resources including thier state (crm resource show)**

```
root@virt-cl-drbd-0:~# crm resource show
 p_fence_virt-cl-drbd-0	(stonith:fence_ipmilan):	Started
 p_fence_virt-cl-drbd-1	(stonith:fence_ipmilan):	Started
 Resource Group: g_vip_nginx
     p_virtual_ip	(ocf::heartbeat:IPaddr2):	Started
     p_nginx	(ocf::heartbeat:nginx):	Started
 Master/Slave Set: ms-drbd0 [p_drbd_r0]
     Masters: [ virt-cl-drbd-0 virt-cl-drbd-1 ]
 Clone Set: hasi-clone [g_hasi]
     Started: [ virt-cl-drbd-0 virt-cl-drbd-1 ]
 vm_ipam1	(ocf::heartbeat:VirtualDomain):	Started
 vm_ipam2	(ocf::heartbeat:VirtualDomain):	Started
 vm_jenkins	(ocf::heartbeat:VirtualDomain):	Started
 vm_quartermaster	(ocf::heartbeat:VirtualDomain):	Started
 vm_awx	(ocf::heartbeat:VirtualDomain):	Started
 vm_puppetmaster	(ocf::heartbeat:VirtualDomain):	Started
```

## Virtal Machine Management Usefull Commands

* **List on the locally connected hypervisor**

```
virsh list
```

* **List VMs on the remote hypervisor node**

```
virsh --connect virsh+ssh://virt-cl-drbd-1/system list
```

* **To connect to a vm on the current hypervisor node**

```
virsh console vm_ipam1
```

* **To connect to a vm on the remote hypervisor node**

```
virsh --connect virsh+ssh://virt-cl-drbd-1/system console vm_ipam2
```

* **To live migrate a cluster manganaged resource**

```
root@virt-cl-drbd-0:~# crm resource migrate vm_puppetmaster force
INFO: Move constraint created for vm_puppetmaster
```

* **To Automatically create a CentOS 7 vm named vm_centos with a 40gb harddrive image** 
```
root@virt-cl-drbd-0:~# ./bin/create_centos_vm.sh vm_centos 40
```

* **To Automatically add a CentOS 7 vm named vm_centos as a cluster managed resource after creation using the command abovea** 
```
root@virt-cl-drbd-0:~# crm configure < /etc/libvirt/qemu/vm_centos.crm
```

* **To Automatically create a Ubuntu 18.04LTS vm named vm_ubuntu with a 40gb harddrive image** 
```
root@virt-cl-drbd-0:~# ./bin/create_centos_vm.sh vm_centos 40
```

* **To Automatically add a Ubuntu 18.04LTS  vm named vm_ubuntu as a cluster managed resource after creation using the command above** 
```
root@virt-cl-drbd-0:~# crm configure < /etc/libvirt/qemu/vm_ubuntu.crm
```

* **To Automatically create a RancherOS 1.4.0 vm named vm_ros with a 40gb harddrive image** 
```
root@virt-cl-drbd-0:~# ./bin/create_rancheros_vm.sh vm_ros 40
```

* **To Automatically add a RancherOS 1.4.0  vm named vm_ubuntu as a cluster managed resource after creation using the command above** 
```
root@virt-cl-drbd-0:~# crm configure < /etc/libvirt/qemu/vm_ros.crm
```

* **To Automatically create a CoreOS Alpha vm named vm_coreos with a 40gb harddrive image** 
```
root@virt-cl-drbd-0:~# ./bin/create_rancheros_vm.sh vm_coreos 40
```

* **To Automatically add a CoreOS Alpha  vm named vm_coreos as a cluster managed resource after creation using the command above** 
```
root@virt-cl-drbd-0:~# crm configure < /etc/libvirt/qemu/vm_coreos.crm
```
* **To remove a Virtual Machine definition and delete it's associated storage**
```
root@virt-cl-drbd-0:~# virsh undefine --remove-all-storage myvm
```
* **Recover from Cluster fencing loop or split brain**

  * Ensure pacemaker is started and run:

  ```
  crm configure edit
  ```

  * Using vi commands search and replace "Started" with "Stopped"

  ```
  :s/Started/Stopped/g
  ```

  * Save the changes.
  * Repeat on Other node if necessary.
  * Start the ms-drbd0 resource to begin resync.

  ```
  crm resource start ms-drbd0
  ```

  * Watch the progress complete will change from Secondary/Secondary to Primary/Primary when complete.

  ```
  watch drbdadm status
  ```

  * When drbd is Primary/Primary you may bring up the rest of the cluster stack

  ```
  crm resource start hasi-clone
  crm resource start g_vip_nginx
  crm resource start p_fence_virt-cl-drbd-0
  crm resource start p_fence_virt-cl-drbd-1
  ```

  * When all cluster resources are succesfully started you may then start the virtual machine resources.  For example:

   ```
   crm resource start vm_ipam1
   ```

## Referrences

### Linux HA Reference

* [http://www.linux-ha.com/wiki/Documentation](http://www.linux-ha.com/wiki/Documentation)

### Netplan

* [https://netplan.io/examples](https://netplan.io/examples)
* [https://netplan.io/examples#bonding](https://netplan.io/examples#bonding)
* [https://netplan.io/examples#bridging](https://netplan.io/examples#bridging)

### DRBD (Active/Active)

* [https://docs.linbit.com/docs/users-guide-9.0/#](https://docs.linbit.com/docs/users-guide-9.0/#)
* [https://wiki.evolix.org/HowtoDRBD](https://wiki.evolix.org/HowtoDRBD)
* [https://mihaiush.wordpress.com/2013/06/10/debian-wheezy-drbd-primaryprimary-corosync-clvm-ocfs2/](https://mihaiush.wordpress.com/2013/06/10/debian-wheezy-drbd-primaryprimary-corosync-clvm-ocfs2/)
* [https://icicimov.github.io/blog/high-availability/Clustering-with-Pacemaker-DRBD-and-GFS2-on-Bare-Metal-servers-in-SoftLayer/](https://icicimov.github.io/blog/high-availability/Clustering-with-Pacemaker-DRBD-and-GFS2-on-Bare-Metal-servers-in-SoftLayer/)
* [https://www.askbjoernhansen.com/2007/04/](https://www.askbjoernhansen.com/2007/04/)
* [https://www.ibm.com/developerworks/library/l-drbd/index.html](https://www.ibm.com/developerworks/library/l-drbd/index.html)
* [https://www.alteeve.com/w/Anvil!_Tutorial_3](https://www.alteeve.com/w/Anvil!_Tutorial_3)

  #### DRBD Architecture

  ![DRBD Architecture](https://www.ibm.com/developerworks/library/l-drbd/figure4.gif)

  #### DRBD Recovery

  * [https://www.recitalsoftware.com/blogs/29-howto-resolve-drbd-split-brain-recovery-manually](https://www.recitalsoftware.com/blogs/29-howto-resolve-drbd-split-brain-recovery-manually)
  * [https://stackoverflow.com/questions/36334744/drbd-how-to-initialize-primary-without-any-secondary-server-available](https://stackoverflow.com/questions/36334744/drbd-how-to-initialize-primary-without-any-secondary-server-available)
  * [https://serverfault.com/questions/452693/drbd-status-uptodate-diskless](https://serverfault.com/questions/452693/drbd-status-uptodate-diskless)

  #### DRBD Performance Tunning
  
  * [https://serverfault.com/questions/740311/drbd-terrible-sync-performance-on-10gige/740370](https://serverfault.com/questions/740311/drbd-terrible-sync-performance-on-10gige/740370)
  * [https://wiki.mikejung.biz/DRBD](https://wiki.mikejung.biz/DRBD)

### DLM
* [https://www.redhat.com/archives/linux-cluster/2015-September/msg00005.html](https://www.redhat.com/archives/linux-cluster/2015-September/msg00005.html)
### OCFS2
* [https://wiki.gentoo.org/wiki/DRBD_with_OCFS2#DRBD_Configuration](https://wiki.gentoo.org/wiki/DRBD_with_OCFS2#DRBD_Configuration)

### CLVM

* [https://support.hpe.com/hpsc/doc/public/display?docId=mmr_kc-0110251](https://support.hpe.com/hpsc/doc/public/display?docId=mmr_kc-0110251)
* [https://susedoc.github.io/doc-sleha/SLEHA12SP2/SLE-HA-guide/html/cha.ha.clvm.html#](https://susedoc.github.io/doc-sleha/SLEHA12SP2/SLE-HA-guide/html/cha.ha.clvm.html#)
* [https://www.suse.com/documentation/sle_ha/book_sleha/data/sec_ha_clvm_config.html](https://www.suse.com/documentation/sle_ha/book_sleha/data/sec_ha_clvm_config.html)

### Stonith

* [https://www.suse.com/documentation/sle-ha-12/singlehtml/book_sleha/book_sleha.html#sec.ha.config.crm.resources](https://www.suse.com/documentation/sle-ha-12/singlehtml/book_sleha/book_sleha.html#sec.ha.config.crm.resources)
* [https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/8/html/director_installation_and_usage/sect-fencing_the_controller_nodes](https://access.redhat.com/documentation/en-us/red_hat_openstack_platform/8/html/director_installation_and_usage/sect-fencing_the_controller_nodes)

### Pacemaker

* [https://wiki.clusterlabs.org/wiki/Pacemaker](https://wiki.clusterlabs.org/wiki/Pacemaker)
* [https://github.com/ClusterLabs/pacemaker/blob/master/doc/pcs-crmsh-quick-ref.md](https://github.com/ClusterLabs/pacemaker/blob/master/doc/pcs-crmsh-quick-ref.md)
* [https://www.unixarena.com/2016/01/rhel7-configuring-gfs2-on-pacemakercorosync-cluster.html/](https://www.unixarena.com/2016/01/rhel7-configuring-gfs2-on-pacemakercorosync-cluster.html/)
* [https://github.com/ClusterLabs/resource-agents/blob/d9b418a733bb82c33d6367823b777da33178862a/heartbeat/nginx#L217-L268](https://github.com/ClusterLabs/resource-agents/blob/d9b418a733bb82c33d6367823b777da33178862a/heartbeat/nginx#L217-L268)
* [https://www.howtoforge.com/tutorial/how-to-set-up-nginx-high-availability-with-pacemaker-corosync-and-crmsh-on-ubuntu-1604/](https://www.howtoforge.com/tutorial/how-to-set-up-nginx-high-availability-with-pacemaker-corosync-and-crmsh-on-ubuntu-1604/)

  #### Pacemaker Architecture

  ![Pacemaker Architecture](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/images/pcmk-internals.png)
  
  ![Pacemaker Active/Active](https://clusterlabs.org/pacemaker/doc/en-US/Pacemaker/1.1/html/Pacemaker_Explained/images/pcmk-active-active.png)

### LibVirt/QEMU

* [https://www.greglangford.co.uk/installing-coreos-kvm-using-virt-install/](https://www.greglangford.co.uk/installing-coreos-kvm-using-virt-install/)
* [https://zacloudbuilder.wordpress.com/2013/07/22/using-virt-install-to-do-a-pxe-based-installation/](https://zacloudbuilder.wordpress.com/2013/07/22/using-virt-install-to-do-a-pxe-based-installation/)
* [https://www.reddit.com/r/linuxadmin/comments/5g7tkw/virtinstall_pxe_stuck_at_domain_installation/](https://www.reddit.com/r/linuxadmin/comments/5g7tkw/virtinstall_pxe_stuck_at_domain_installation/)
* [https://blog.scottlowe.org/2015/05/11/using-pxe-with-virt-install/](https://blog.scottlowe.org/2015/05/11/using-pxe-with-virt-install/)

### Dell OpenManager

* [http://linux.dell.com](http://linux.dell.com)
* [http://linux.dell.com/repo/community/ubuntu/](http://linux.dell.com/repo/community/ubuntu/)
* [https://linux.dell.com/repo/hardware/DSU_16.04.00/](https://linux.dell.com/repo/hardware/DSU_16.04.00/)
* [http://linux.dell.com/repo/community/openmanage/](http://linux.dell.com/repo/community/openmanage/)
* [https://wiki.ubuntu.com/DellBIOS](https://wiki.ubuntu.com/DellBIOS)
* [https://linux.dell.com/repo/community/debian/](https://linux.dell.com/repo/community/debian/)

### Munin

* [http://guide.munin-monitoring.org/en/latest/architecture/index.html#munin-node](http://guide.munin-monitoring.org/en/latest/architecture/index.html#munin-node)
* [https://www.unixmen.com/how-to-install-configure-munin-master-ubuntu/](https://www.unixmen.com/how-to-install-configure-munin-master-ubuntu/)
* [https://www.howtoforge.com/tutorial/server-monitoring-with-munin-and-monit-on-ubuntu-16-04-lts/](https://www.howtoforge.com/tutorial/server-monitoring-with-munin-and-monit-on-ubuntu-16-04-lts/)
* [http://www.linuxls.com/fatal-munin_readconfig_partdatafile-missing-file/](http://www.linuxls.com/fatal-munin_readconfig_partdatafile-missing-file/)
* [https://git.coop/webarch/discourse/blob/33be54a6863b23683b77e8baefeccdfc7ebf0090/roles/munin-node/tasks/main.yml](https://git.coop/webarch/discourse/blob/33be54a6863b23683b77e8baefeccdfc7ebf0090/roles/munin-node/tasks/main.yml)
* [https://forge.puppet.com/ssm/munin](https://forge.puppet.com/ssm/munin)
* [http://grokbase.com/t/sf/munin-users/106834qnr4/service-mysql-exited-with-status-255-0](http://grokbase.com/t/sf/munin-users/106834qnr4/service-mysql-exited-with-status-255-0)
* [http://guide.munin-monitoring.org/en/stable-2.0/example/webserver/nginx.html](http://guide.munin-monitoring.org/en/stable-2.0/example/webserver/nginx.html)
* [http://guide.munin-monitoring.org/en/latest/tutorial/troubleshooting.html](http://guide.munin-monitoring.org/en/latest/tutorial/troubleshooting.html)
* [http://munin-monitoring.org/wiki/munin-node-configure](http://munin-monitoring.org/wiki/munin-node-configure)
* [https://lzone.de/cheat-sheet/Monitoring](https://lzone.de/cheat-sheet/Monitoring)
* [https://bugs.launchpad.net/ubuntu/+source/net-snmp/+bug/1384122](https://bugs.launchpad.net/ubuntu/+source/net-snmp/+bug/1384122)
* [http://lists.linbit.com/pipermail/drbd-user/2011-November/017131.html](http://lists.linbit.com/pipermail/drbd-user/2011-November/017131.html)
* [https://github.com/MikeQG/munin-libvirt-plugins](https://github.com/MikeQG/munin-libvirt-plugins)
* [http://virtuallyhyper.com/2013/03/monitor-different-systems-with-munin/](http://virtuallyhyper.com/2013/03/monitor-different-systems-with-munin/)

#### Munin Architecture
  ![Munin Architecture](http://guide.munin-monitoring.org/en/latest/_images/Munin-Architecture1.png)

### Workflow
* [https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow)
