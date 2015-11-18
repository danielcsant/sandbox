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
       settings = settings.merge(settingslocal)
       puts "--- Local vagrant settings have been applied ---"
    end    

    file = File.new("../pom.xml")
    doc = Document.new(file)
    
    stratio_module_fullname = doc.root.elements['name'].text
    stratio_module_name = stratio_module_fullname.split.last.downcase
    stratio_module_version = doc.root.elements['version'].text
    stratio_banner_name = stratio_module_fullname.split.last  
    
    Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
      config.vm.boot_timeout = 1500
      config.vm.box = "#{stratio_module_fullname} #{stratio_module_version}"
      config.vm.box_url = settings['sandbox_base']
      config.vm.hostname="#{stratio_module_name}.box.stratio.com"    
      
      config.vm.network "public_network",

      config.vm.post_up_message = "Stratian: your #{stratio_module_fullname} Sandbox is now up & ready..."
      config.vm.provider "virtualbox" do |vb|        
        vb.gui = false
        vb.name = "#{stratio_module_fullname} #{stratio_module_version}"
        vb.memory = settings['sandbox_memory']
        vb.cpus = settings['sandbox_cpus']
        vb.customize ["modifyvm", :id, "--cpuexecutioncap", settings['sandbox_max_cpu_usage']]
      end
      
      config.vm.provision "shell", path: "stratio_vagrant_script.sh", args: "#{stratio_module_name} '#{stratio_module_fullname}' #{stratio_module_version} '#{banner}' #{stratio_banner_name}"      
    end
  end
end
