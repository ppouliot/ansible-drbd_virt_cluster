#!/usr/bin/env bash
cat <<EOF > /etc/drbd.d/r1.res
resource r1 {
  device /dev/drbd1 ;
  disk /dev/mapper/vg_drbd-lv_var_lib_libvirt_images;
  meta-disk internal;
  on virt-cl-drbd-0 {
     address 172.20.230.73:7781;
  }
  on virt-cl-drbd-1 {
     address 172.20.230.112:7781;
  }
  syncer {
    rate 6M;
  }
}
EOF
