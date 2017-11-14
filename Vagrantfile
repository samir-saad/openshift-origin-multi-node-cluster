require 'yaml'

$provisioned = false

commonConfig = YAML.load_file('common-config.yml')
machinesConfig = YAML.load_file('machines-config.yml')

## Load Windows Ansible Util
ansible_windows = File.expand_path('../util/ansible_windows', __FILE__)
load ansible_windows if File.exists?(ansible_windows)

## Load Network Util
network = File.expand_path('../util/network', __FILE__)
load network if File.exists?(network)

## Load Provisioning Util
provisioning = File.expand_path('../util/provisioning', __FILE__)
load provisioning if File.exists?(provisioning)

## Load Storage Controller Util
storage_controller = File.expand_path('../util/storage_controller', __FILE__)
load storage_controller if File.exists?(storage_controller)


Vagrant.configure("2") do |config|

  commonFolders       = commonConfig['synced_folders']
  commonDisks         = commonConfig['disks']
  commonProvisions    = commonConfig['provisions']

  #config.vbguest.auto_update = false
  ## Disable default folder synch
  config.vm.synced_folder '.', '/vagrant', disabled: true
  
  machinesConfig.each do |machine|
    name              = machine['name']
    hostname          = machine['name'] + '.' + commonConfig['domain']
    ip                = machine['ip']
    box               = machine['box'] ||= commonConfig['box']
    memory            = machine['memory'] ||= commonConfig['memory.default']
    cpus              = machine['cpus'] ||= commonConfig['cpus.default']
    machineFolders    = machine['synced_folders']
    machineDisks      = machine['disks']
    machineProvisions = machine['provisions']
    
	$provisioned = File.exist?(".vagrant/machines/#{name}/virtualbox/action_provision")
	
    ## Configure node
    config.vm.define name do |cfg|

       cfg.vm.box = box
       cfg.vm.hostname = hostname

       ## Comment public network to disable bridge
       ## Bridged network --> cfg.vm.network :public_network
       ## cfg.vm.network :private_network, ip: ip
       cfg.vm.network :private_network, network_options(machine)
       
	   cfg.vm.provision "shell",
         inline: "sudo mkdir -p /vagrant; sudo chown vagrant:vagrant /vagrant"
	
       ## Sync folders
       sync_folders(cfg.vm, commonFolders)
       sync_folders(cfg.vm, machineFolders)
       
       cfg.ssh.forward_agent = true

       cfg.vm.provider "virtualbox" do |vb|
         vb.name = hostname
         vb.gui = false
         vb.memory = memory
         vb.cpus = cpus

         ## Create and attach disks to machine
         create_disks(vb, commonDisks)
         create_disks(vb, machineDisks)
       end

       ## provisioning
       run_provisions(cfg, commonProvisions, hostname, ip)
       run_provisions(cfg, machineProvisions, hostname, ip)
       
    end
  end
end
