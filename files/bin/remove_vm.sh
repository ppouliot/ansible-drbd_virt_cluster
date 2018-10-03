#!/usr/bin/env bash


virsh destroy $1

virsh undefine $1 --remove-all-storage

rm -rf /etc/libvirt/qemu/$1.crm
