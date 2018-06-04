# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/xenial64"

  config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8983, host: 8090, host_ip: "127.0.0.1"  
  config.vm.network "private_network", ip: "192.168.100.100"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "4096"
  end

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "deploy/master.yml"
    ansible.inventory_path = "deploy/development"
    ansible.force_remote_user = true
    ansible.limit = "all"
  end

end
