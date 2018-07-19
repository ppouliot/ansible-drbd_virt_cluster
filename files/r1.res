resource r1 {
  device /dev/drbd1 ;
  disk /dev/mapper/vg_drbd-lv_var_lib_libvirt_images;
  meta-disk internal;
  on virt-cl-drbd-data-0 {
     address 192.168.1.1:7781;
  }
  on virt-cl-drbd-data-1 {
     address 192.168.1.2:7781;
  }
  syncer {
    rate 6M;
  }
}
