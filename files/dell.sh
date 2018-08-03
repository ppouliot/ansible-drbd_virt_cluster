#!/usr/bin/env bash

echo 'deb http://linux.dell.com/repo/community/openmanage/910/xenial xenial main' | tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list

sudo gpg --keyserver pool.sks-keyservers.net --recv-key 1285491434D8786F
gpg -a --export 1285491434D8786F | sudo apt-key add -
apt-get update -y
#apt-get install srvadmin-all -y
