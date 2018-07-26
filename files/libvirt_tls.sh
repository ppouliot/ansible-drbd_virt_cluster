#!/usr/bin/env bash
mkdir /root/ca && cd /root/ca
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
mkdir -p /etc/pki/libvirt/private
cp cacert.pem /etc/pki/CA/cacert.pem
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
cp virt-cl-drbd-0-cert.pem /etc/pki/libvirt/servercert.pem


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
scp virt-cl-drbd-1-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/servercert.pem



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
cp virt-manager-cert.pem /etc/pki/libvirt/

scp virt-manager-key.pem root@virt-cl-drbd-1:/etc/pki/libvirt/private/
scp virt-manager-cert.pem root@virt-cl-drbd-1:/etc/pki/libvirt/
