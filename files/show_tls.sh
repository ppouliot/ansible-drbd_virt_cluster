#!/usr/bin/env bash

ansible drbd-cluster -a 'tree /etc/pki'
ansible drbd-cluster -a 'tree /etc/skel/.pki'
ansible drbd-cluster -a 'tree /root'
