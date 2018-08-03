#!/usr/bin/env bash

mkdir /root/ca && cd /root/ca
mkdir -p /root/.pki/libvirt

certtool --generate-privkey > cakey.pem
cat << EOF > /root/ca/ca.info
cn = Virtualization Cluster
ca
cert_signing_key
EOF
certtool --generate-self-signed --load-privkey cakey.pem \
  --template ca.info --outfile cacert.pem
rm -rf ca.info
mkdir -p /etc/pki/CA
mkdir -p /etc/pki/qemu/private
mkdir -p /etc/pki/libvirt/private
mkdir -p /etc/pki/libvirt-vnc
mkdir -p /etc/pki/libvirt-spice
mkdir -p /etc/skel/.pki/libvirt
mkdir -p /etc/skel/.spice

cp cacert.pem /etc/pki/CA/cacert.pem
cp cacert.pem /etc/pki/libvirt/ca-cert.pem
cp cacert.pem /etc/pki/qemu/ca-cert.pem
cp cacert.pem /etc/pki/libvirt-vnc/ca-cert.pem
cp cacert.pem /etc/pki/libvirt-spice/ca-cert.pem
cp cacert.pem /etc/skel/.pki/cacert.pem

rsync -avz -e ssh --delete /etc/pki/ root@virt-cl-drbd-1:/etc/pki/

certtool --generate-privkey > virt-cl-drbd-0-key.pem

cat << EOF > /root/ca/virt-cl-drbd-0.info
organization = Virtualization Cluster
cn = virt-cl-drbd-0.bos1.rakops.com
dns_name = virt-cl-drbd-0
dns_name = virt-cl-drbd-0.bos1.rakops.com
ip_address = 172.20.230.73
ip_address = 192.168.1.1
tls_www_server
encryption_key
signing_key
EOF

certtool --generate-certificate --load-privkey virt-cl-drbd-0-key.pem \
  --load-ca-certificate cacert.pem --load-ca-privkey cakey.pem \
  --template virt-cl-drbd-0.info --outfile virt-cl-drbd-0-cert.pem

cp virt-cl-drbd-0-key.pem /etc/pki/libvirt/private/serverkey.pem
cp virt-cl-drbd-0-key.pem /etc/pki/libvirt/server-key.pem
cp virt-cl-drbd-0-key.pem /etc/pki/qemu/private/serverkey.pem
cp virt-cl-drbd-0-key.pem /etc/pki/qemu/server-key.pem
cp virt-cl-drbd-0-key.pem /etc/pki/libvirt-vnc/server-key.pem
cp virt-cl-drbd-0-key.pem /etc/pki/libvirt-spice/server-key.pem

cp virt-cl-drbd-0-cert.pem /etc/pki/libvirt/servercert.pem
cp virt-cl-drbd-0-cert.pem /etc/pki/libvirt/server-cert.pem
cp virt-cl-drbd-0-cert.pem /etc/pki/qemu/servercert.pem
cp virt-cl-drbd-0-cert.pem /etc/pki/qemu/server-cert.pem
cp virt-cl-drbd-0-cert.pem /etc/pki/libvirt-vnc/server-cert.pem
cp virt-cl-drbd-0-cert.pem /etc/pki/libvirt-spice/server-cert.pem


certtool --generate-privkey > virt-cl-drbd-1-key.pem

cat << EOF > /root/ca/virt-cl-drbd-1.info
organization = Virtualization Cluster
cn = virt-cl-drbd-1.bos1.rakops.com
dns_name = virt-cl-drbd-1
dns_name = virt-cl-drbd-1.bos1.rakops.com
ip_address = 172.20.230.112
ip_address = 192.168.1.2
tls_www_server
encryption_key
signing_key
EOF

certtool --generate-certificate --load-privkey virt-cl-drbd-1-key.pem \
  --load-ca-certificate cacert.pem --load-ca-privkey cakey.pem \
  --template virt-cl-drbd-1.info --outfile virt-cl-drbd-1-cert.pem

scp virt-cl-drbd-1-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt/private/serverkey.pem
scp virt-cl-drbd-1-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt/server-key.pem
scp virt-cl-drbd-1-key.pem root@virt-cl-drbd-1:/etc/pki/qemu/private/serverkey.pem
scp virt-cl-drbd-1-key.pem root@virt-cl-drbd-1:/etc/pki/qemu/server-key.pem
scp virt-cl-drbd-1-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt-vnc/server-key.pem
scp virt-cl-drbd-1-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt-spice/server-key.pem

scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/servercert.pem
scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/server-cert.pem
scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/qemu/servercert.pem
scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/qemu/server-cert.pem
scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt-vnc/server-cert.pem
scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt-spice/server-cert.pem



certtool --generate-privkey > virt-manager-key.pem
cat << EOF > /root/ca/virt-manager.info
country = US
state = Massachusetts
locality = Boston
organization = Virtualization Cluster
cn = virt-manager
tls_www_client
encryption_key
signing_key
EOF

certtool --generate-certificate --load-privkey virt-manager-key.pem \
  --load-ca-certificate cacert.pem --load-ca-privkey cakey.pem \
  --template virt-manager.info --outfile virt-manager-cert.pem

cp virt-manager-key.pem /etc/pki/libvirt/private/
cp virt-manager-key.pem /etc/pki/libvirt/private/clientkey.pem
cp virt-manager-key.pem /etc/pki/libvirt/private/client-key.pem
cp virt-manager-key.pem /etc/pki/qemu/private/
cp virt-manager-key.pem /etc/pki/qemu/private/clientkey.pem
cp virt-manager-key.pem /etc/pki/qemu/private/client-key.pem
cp virt-manager-key.pem /etc/pki/libvirt-vnc/clientkey.pem
cp virt-manager-key.pem /etc/pki/libvirt-spice/clientkey.pem
cp virt-manager-key.pem /etc/skel/.pki/libvirt/clientkey.pem

cp virt-manager-cert.pem /etc/pki/libvirt/
cp virt-manager-cert.pem /etc/pki/libvirt/clientcert.pem
cp virt-manager-cert.pem /etc/pki/libvirt/client-cert.pem
cp virt-manager-cert.pem /etc/pki/qemu/
cp virt-manager-cert.pem /etc/pki/qemu/clientcert.pem
cp virt-manager-cert.pem /etc/pki/libvirt-vnc/clientcert.pem
cp virt-manager-cert.pem /etc/pki/libvirt-spice/clientcert.pem
cp virt-manager-cert.pem /etc/skel/.pki/libvirt/clientcert.pem

rsync -avz -e ssh --delete /etc/skel/.pki root@virt-cl-drbd-1:/etc/skel/

scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt/private/
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt/private/clientkey.pem
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt/private/client-key.pem
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/qemu/private/
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/qemu/private/clientkey.pem
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/qemu/private/client-key.pem
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt-vnc/clientkey.pem
scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt-spice/clientkey.pem

scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/clientcert.pem
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/client-cert.pem
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/qemu/
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/qemu/clientcert.pem
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/qemu/client-cert.pem
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt-vnc/clientcert.pem
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt-spice/clientcert.pem

cd ..
tar -cvzf ca.tgz ca 
rm -rf ca
scp ca.tgz root@virt-cl-drbd-1:~/
