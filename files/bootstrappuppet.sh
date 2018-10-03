#!/bin/ash
set -x
sudo echo http://dl-cdn.alpinelinux.org/alpine/edge/main/ >> /etc/apk/repositories
sudo echo http://dl-cdn.alpinelinux.org/alpine/edge/community/ >> /etc/apk/repositories
sudo echo http://dl-cdn.alpinelinux.org/alpine/edge/testing/ >> /etc/apk/repositories
sudo apk update
sudo apk add shadow ruby less bash bind-tools
sudo gem install rdoc puppet r10k hiera-eyaml
sudo /opt/puppetlabs/bin/puppet agent --debug --trace --verbose --test --waitforcert=60 --server=172.20.230.70
#sudo docker pull puppet/facter
#sudo docker pull puppet/puppet-agent
#sudo docker run --rm --privileged --name puppet --hostname %H -v /tmp:/tmp -v /etc:/etc -v /var:/var -v /usr:/usr -v /lib64:/lib64 puppet/puppet-agent agent --verbose --debug --trace --logdest=console --no-daemonize --server=puppet --environment=production --waitforcert=60 --summarize
