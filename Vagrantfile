# -*- mode: ruby -*-
# vi: set ft=ruby :
#
required_plugins = %w(vagrant-scp vagrant-puppet-install vagrant-vbguest)

plugins_to_install = required_plugins.select { |plugin| not Vagrant.has_plugin? plugin }
if not plugins_to_install.empty?
  puts "Installing plugins: #{plugins_to_install.join(' ')}"
  if system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exec "vagrant #{ARGV.join(' ')}"
  else
    abort "Installation of one or more plugins has failed. Aborting."
  end
end

Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/etc/ansible", :mount_options => ['dmode=775','fmode=777']
  config.vm.provider "virtualbox" do |v|
      unless File.exist?('./drbd0.img')
        v.customize ['createhd', '--filename', disk, '--variant', 'Fixed', '--size', 2 * 1024]
      end
      unless File.exist?('./drbd1.img')
        v.customize ['createhd', '--filename', disk, '--variant', 'Fixed', '--size', 2 * 1024]
      end
    end
    v.customize ["modifyvm", :id, "--memory", "2048"]
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.linked_clone = true
    v.ssh.insert_key = false
  end
  config.puppet_install.puppet_version = :latest

  # virt-cl-drbd-1 Definition
  config.vm.define "virt-cl-drbd-1" do |v|
    v.vm.box = "ubuntu/bionic64"
    v.vm.hostname = "virt-cl-drbd-1"
    v.vm.network "private_network", ip: "192.168.1.2"
    v.vm.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './drbd1.img']
  end

  # virt-cl-drbd-0 Definition
  config.vm.define "virt-cl-drbd-0" do |v|
    v.vm.box = "ubuntu/bionic64"
    v.vm.hostname = "virt-cl-drbd-0"
    v.vm.network "private_network", ip: "192.168.1.1"
    v.vm.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', './drbd0.img']
    v.vm.provision "ansible" do |ansible|
      ansible.verbose = "v"
      ansible.playbook = "site.yml"
    end
  end
