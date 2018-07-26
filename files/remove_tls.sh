#!/usr/bin/env bash

ansible drbd-cluster -a 'rm -rf /etc/pki/CA'
ansible drbd-cluster -a 'rm -rf /etc/pki/libvirt'
ansible drbd-cluster -a 'rm -rf /etc/pki/libvirt-vnc'
ansible drbd-cluster -a 'rm -rf /etc/pki/libvirt-spice'
ansible drbd-cluster -a 'rm -rf /etc/pki/qemu'
ansible drbd-cluster -a 'rm -rf /root/ca'
ansible drbd-cluster -a 'rm -rf /root/ca.tgz'
ansible drbd-cluster -a 'rm -rf /etc/skel/.pki'
ansible drbd-cluster -a 'tree /etc/pki'
ansible drbd-cluster -a 'tree /etc/skel'
ansible drbd-cluster -a 'tree /root'
