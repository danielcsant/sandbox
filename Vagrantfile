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

captures = settings['stratio_module_repository'].match(/((git@|https:\/\/)([\w\.@]+)(\/|:))([\w,\-,\_]+)\/([\w,\-,\_]+)\/([\w,\-,\_]+)\/((.*))/)    

module_owner   = captures[5]
module_name    = captures[6]
module_branch  = captures[8]

if settings['stratio_module_version'].to_s == ''
	module_version = captures[8].gsub("release/", "").gsub("x", "0")
else 
	module_version = settings['stratio_module_version']	
end


if module_owner != "Stratio"
  puts "Hey, you are trying to install something out of Stratio repositories. Check the settings: #{settings['stratio_module_version']}"                                                                   
  exit 
end


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = settings["sandbox_box"]

  config.vm.hostname="#{settings['stratio_module_name']}.stratio.com"

  # Create a private network, which allows host-only access to the machine
  config.vm.network "private_network", type: "dhcp"

  config.vm.post_up_message = "Stratian: your Stratio Sandbox is now up & ready..."

  config.vm.provider "virtualbox" do |vb|
    # Boot with headless mode
    vb.gui = false
    vb.name = "stratio-sandbox-#{module_name}"

    # Use VBoxManage to customize the VM. For example to change memory:
    vb.memory = settings['sandbox_memory']
    vb.cpus = settings['sandbox_cpus']
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", settings['sandbox_max_cpu_usage']]
  end

  config.vm.provision "shell", path: "stratio_sandbox_common.sh", args: "#{settings['stratio_env']} #{module_name} #{module_branch} #{module_version}"

end
