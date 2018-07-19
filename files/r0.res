resource r0 {
  device /dev/drbd0;
  disk /dev/mapper/vg_drbd-lv_etc_libvirt_qemu;
  meta-disk internal;
  on virt-cl-drbd-data-0 {
     address 192.168.1.1:7780;
  }
  on virt-cl-drbd-data-1 {
     address 192.168.1.2:7780;
  }
  syncer {
    rate 6M;
  }
}
