# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# We are using a YAML file with all the env variables
require 'yaml'

if File.exist?("vagrant_settings.yml")
   settings = YAML::load_file("vagrant_settings.yml")
else
   puts "Hey, required file vagrant_settings.yml is missing. Please download it here https://github.com/Stratio/sandbox"
   exit
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = settings["sandbox_box"]

  config.vm.hostname="#{settings['stratio_module_name']}.#{settings['sandbox_hostname_suffix']}"

  # Create a private network, which allows host-only access to the machine
  config.vm.network "private_network", type: "dhcp"

  config.vm.post_up_message = "Stratian: your Stratio Sandbox is now up & ready..."

  config.vm.provider "virtualbox" do |vb|
    # Boot with headless mode
    vb.gui = false
    vb.name = "stratio_sandbox_#{settings['stratio_module_name']}"

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.memory = settings['sandbox_memory']
    vb.cpus = settings['sandbox_cpus']
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", settings['sandbox_max_cpu_usage']]
  end

  config.vm.provision "shell", path: "stratio_sandbox_common.sh", args: "#{settings['stratio_env']} #{settings['stratio_module_name']} #{settings['stratio_module_version']} #{settings['stratio_module_github_name']}"

end
