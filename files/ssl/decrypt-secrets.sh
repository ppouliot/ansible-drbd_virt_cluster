#! /usr/bin/env bash
CA_PASSWD=$1
openssl enc -pass pass:${CA_PASSWD} -d -aes256 -in secrets.tar.enc | tar xz -C . 