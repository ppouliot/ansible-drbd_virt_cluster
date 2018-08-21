# -*- mode: ruby -*-
# vi: set ft=ruby :
#
required_plugins = %w[vagrant-scp vagrant-puppet-install vagrant-vbguest]

return if !Vagrant.plugins_enabled?

plugins_to_install = required_plugins.select { |plugin| !Vagrant.has_plugin? plugin }

if plugins_to_install.any?
    system "vagrant plugin install #{plugins_to_install.join(' ')}"
    exit system 'vagrant up'
end

Vagrant.configure("2") do |config|
    config.vm.synced_folder ".", "/etc/ansible", :mount_options => ['dmode=775','fmode=777']
    config.ssh.insert_key = false
    config.vm.provider "virtualbox" do |v|
        v.customize ["modifyvm", :id, "--memory", "2048"]
        v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        v.linked_clone = true
    end
    config.puppet_install.puppet_version = :latest

    # virt-cl-drbd-1 Definition
    config.vm.define "virt-cl-drbd-1" do |v|
        v.vm.box = "ubuntu/bionic64"
        v.vm.hostname = "virt-cl-drbd-1"
        v.vm.network "private_network", ip: "192.168.1.2"
        v.vm.provider "virtualbox" do |vb|
            file_to_disk0_1 = './drbd1a.vdi'
            unless File.exist?(file_to_disk0_1)
                vb.customize ['createmedium', 'disk', '--filename', file_to_disk0_1, '--variant', 'Fixed', '--size', 2 * 1024]
            end
            vb.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk0_1]
        end
    end

    # virt-cl-drbd-0 Definition
    config.vm.define "virt-cl-drbd-0" do |v|
        v.vm.box = "ubuntu/bionic64"
        v.vm.hostname = "virt-cl-drbd-0"
        v.vm.network "private_network", ip: "192.168.1.1"
        v.vm.provider "virtualbox" do |vb|
            file_to_disk1_1 = './drbd0a.vdi'
            unless File.exist?(file_to_disk1_1)
                vb.customize ['createmedium', 'disk', '--filename', file_to_disk1_1, '--variant', 'Fixed', '--size', 2 * 1024]
            end
            vb.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', file_to_disk1_1]
        end
        v.vm.provision "ansible" do |ansible|
            ansible.verbose = "v"
            ansible.playbook = "site.yml"
        end
        
    end
end
