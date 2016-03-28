# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
    config.vm.box = "puppetlabs/centos-7.2-64-nocm"
    config.vm.box_check_update = true
    config.vm.hostname = "puppet.example.com"
    
    config.vm.provider "vmware_fusion" do |v|
		v.vmx["memsize"] = "4096"
		v.vmx["numvcpus"] = "2"
	end
   
    config.vm.provision "shell", inline: <<-SHELL

    SHELL
end
