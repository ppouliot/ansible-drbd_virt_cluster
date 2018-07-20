#!/bin/bash

SERVER_KEY=server-key.pem

# creating a key for our ca
if [ ! -e ca-key.pem ]; then
 openssl genrsa -des3 -out ca-key.pem 1024
fi
# creating a ca
if [ ! -e ca-cert.pem ]; then
 openssl req -new -x509 -days 1095 -key ca-key.pem -out ca-cert.pem  -subj "/C=MA/L=Stoneham/O=Cluster/CN=Cluster CA"
fi
# create server key
if [ ! -e $SERVER_KEY ]; then
 openssl genrsa -out $SERVER_KEY 1024
fi
# create a certificate signing request (csr)
if [ ! -e server-key.csr ]; then
 openssl req -new -key $SERVER_KEY -out server-key.csr -subj "/C=MA/L=Stoneham/O=Cluster/CN=clustered server"
fi
# signing our server certificate with this ca
if [ ! -e server-cert.pem ]; then
 openssl x509 -req -days 1095 -in server-key.csr -CA ca-cert.pem -CAkey ca-key.pem -set_serial 01 -out server-cert.pem
fi

# now create a key that doesn't require a passphrase
openssl rsa -in $SERVER_KEY -out $SERVER_KEY.insecure
mv $SERVER_KEY $SERVER_KEY.secure
mv $SERVER_KEY.insecure $SERVER_KEY

# show the results (no other effect)
openssl rsa -noout -text -in $SERVER_KEY
openssl rsa -noout -text -in ca-key.pem
openssl req -noout -text -in server-key.csr
openssl x509 -noout -text -in server-cert.pem
openssl x509 -noout -text -in ca-cert.pem

# copy *.pem file to /etc/pki/libvirt-spice
if [[ ! -d "/etc/pki/libvirt-spice" ]] 
then
 mkdir -p /etc/pki/libvirt-spice
fi
cp ./*.pem /etc/pki/libvirt-spice

# echo --host-subject
echo "your --host-subject is" \"`openssl x509 -noout -text -in server-cert.pem | grep Subject: | cut -f 10- -d " "`\"

echo "copy ca-cert.pem to %APPDATA%\spicec\spice_truststore.pem or ~/.spice/spice_truststore.pem in your clients"
