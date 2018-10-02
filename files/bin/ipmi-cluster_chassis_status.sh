#!/usr/bin/env bash
for i in 0 1
do
  echo "######### virt-cl-drbd-$i #########"
  echo " "
  ipmitool -Hvirt-cl-drbd-ipmi-$i -Uroot -Pcalvin -I lanplus chassis status
  echo " "
  if [ $i == 0 ]; then
    echo "**********************************"
  else
    echo "##################################"
  fi
  echo " "
done
