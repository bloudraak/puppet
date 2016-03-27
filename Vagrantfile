# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    config.vm.box = "puppetlabs/centos-7.2-64-nocm"
    config.vm.box_check_update = true
    
    config.vm.provider "vmware_fusion" do |v|
		v.vmx["memsize"] = "2048"
		v.vmx["numvcpus"] = "1"
	end

    config.vm.provision "shell", inline: <<-SHELL
        sudo yum update -y
        sudo yum install -y wget
        sudo yum install -y net-tools
    SHELL
end
