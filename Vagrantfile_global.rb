require 'rexml/document'
require 'yaml'
include REXML

class Vfg  
  def run()    

    open('vagrant_settings.yml', 'wb') do |file|            
      file << open('https://raw.githubusercontent.com/Stratio/sandbox/cont-delivery/vagrant_settings.yml').read
    end

    open('stratio_vagrant_script.sh', 'wb') do |file|      
      file << open('https://raw.githubusercontent.com/Stratio/sandbox/cont-delivery/stratio_vagrant_script.sh').read
    end

    if File.exist?("./BANNER")
      file = File.open("./BANNER")
      banner = ""
      file.each { |line|
        banner << line
      }
    end    

    settings = YAML::load_file("vagrant_settings.yml")
    if File.exist?("vagrant_settings_l.yml")       
       settingslocal = YAML::load_file("vagrant_settings_l.yml")
       ##Now we merge both hashes to combine all settings
       settings = settings.merge(settingslocal)
       puts "--- Local vagrant settings have been applied ---"
    end    

    file = File.new("../pom.xml")
    doc = Document.new(file)
    
    stratio_module_fullname = doc.root.elements['name'].text
    stratio_module_name = stratio_module_fullname.split.last.downcase
    stratio_module_version = doc.root.elements['version'].text
    stratio_hosts_config = ""
    ip = ""

    #Reading and transposing the hash to fetch ip-hostname duple
    settings['private_hostnames'].each do |mod|      
       mod.each do |x, y|
        stratio_hosts_config << y.to_s << " " << x.to_s << ".box.stratio.com" << "\\n"
      end      
    end   

    
        
    settings['private_hostnames'].each do |mod|      
      if mod["#{stratio_module_name}"]!=nil 
        ip = mod["#{stratio_module_name}"]     
      break
      end
    end

    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      #MODM
      config.vm.box_url = settings['sandbox_base']
      config.vm.hostname="#{stratio_module_name}.box.stratio.com"

      # Create a private network, which allows host-only access to the machine      
      config.vm.network "private_network", ip: ip      

      config.vm.post_up_message = "Stratian: your stratio-#{stratio_module_fullname} Sandbox is now up & ready..."

      config.vm.provider "virtualbox" do |vb|
        # Boot with headless mode
        vb.gui = false
        vb.name = "stratio-#{stratio_module_name}-#{stratio_module_version}"

        # Use VBoxManage to customize the VM. For example to change memory:
        vb.memory = settings['sandbox_memory']
        vb.cpus = settings['sandbox_cpus']
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", settings['sandbox_max_cpu_usage']]
      end
      
      config.vm.provision "shell", path: "stratio_vagrant_script.sh", args: "#{stratio_module_name} '#{stratio_module_fullname}' #{stratio_module_version} '#{stratio_hosts_config}' '#{banner}'"      
    end
  end
end
