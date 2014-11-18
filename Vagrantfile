# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# We are using a YAML file with all the env variables
require 'yaml'

settings = YAML::load_file("vagrant_settings.yml")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = settings['sandbox_box']

  config.vm.hostname="#{settings['stratio_module_name']}.#{settings['sandbox_hostname_suffix']}"


  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: settings['sandbox_network_ip']

  config.vm.post_up_message = "Stratian: your Stratio Sandbox is now up & ready..."

  config.vm.provider "virtualbox" do |vb|
    # Don't boot with headless mode
    vb.gui = false
    vb.name = "stratio_sandbox_#{settings['stratio_module_name']}"
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", settings['sandbox_memory']]
    vb.customize ["modifyvm", :id, "--cpus", settings['sandbox_cpus']]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", settings['sandbox_max_cpu_usage']]
  end

  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  config.vm.provision :shell, :inline => "STRATIO_ENV=#{settings['stratio_env']} STRATIO_MODULE_VERSION=#{settings['stratio_module_version']} STRATIO_MODULE_GITHUB_NAME=#{settings['stratio_module_github_name']} bash /vagrant/stratio_sandbox_common.sh"

end
