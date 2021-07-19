########################################################################################################################
#                                                                                                                      #
#                                   TSM attribute for TSCM Cookbook                                                    #
#                                                                                                                      #
#   Language            : Chef/Ruby                                                                                    #
#   Date                : 18.12.2017                                                                                   #
#   Date Last Update    : 31.01.2017                                                                                   #
#   Version             : 0.1                                                                                          #
#   Author              : Arnaud THALAMOT                                                                              #
#                                                                                                                      #
########################################################################################################################

require 'chef/resource'

use_inline_resources

def whyrun_supported?
  true
end

action :install do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      install_tsm_win
    else
      check_prereq
      install_tsm
    end
  end
end

action :configure do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
    else
      configure_tsm
    end
  end
end


action :register do
  converge_by("Create #{@new_resource}") do
    if platform_family?('windows')
      register_node_win
    else
      register_tsm
    end
  end
end

action :uninstall do
  converge_by("Create #{@new_resource}") do
    uninstall_tsm
  end
end

def install_tsm_win
  if ::File.exist?(node['tsm']['alreadyInstalledFile'].to_s)
    Chef::Log.info('tsm is already install, nothing to install for tsm agent')
    Chef::Log.debug('tsm is already install, nothing to install for tsm agent')
  else
    # Create temp directory where we copy/create source files to install tad4d agent
    directory node['tsm']['temp'].to_s do
      action :create
    end
    
    # get tsm agent media to our temp dir
    remote_file node['tsm']['TSMfile_Path'].to_s do
      source node['tsm']['TSMfile_Path'].to_s
      path "#{node['tsm']['temp']}\\#{node['tsm']['TSMfile']}"
      action :create
    end

    media = "#{node['tsm']['temp']}#{node['tsm']['TSMfile']}"

    ruby_block 'unzip-install-file' do
      block do
        Chef::Log.info('unziping the tsm Installer file')
        command = powershell_out "Add-Type -assembly \"system.io.compression.filesystem\"; [io.compression.zipfile]::ExtractToDirectory('C:/tsm_temp/tsm_installer.zip', 'C:/tsm_temp')"
        Chef::Log.debug command.to_s
        action :create
      end
    end

    # Install Visual C++ packages
    Chef::Log.info('Performing visual c++ packages installation...')
    Chef::Log.info('Installing MS 2010 x86 C++')
    execute 'Install MS 2010 x86 C++' do
      cwd "#{node['tsm']['temp']}7.1.4.1-tiv-tsmbac-winx64\\ISSetupPrerequisites\\{270b0954-35ca-4324-bbc6-ba5db9072dad}"
      command '.\vcredist_x86.exe /install /quiet /log C:\\tsm_temp\\vcredistMS10_x86_2.log -wait'
      action :run
    end

    Chef::Log.info('Installing MS 2012 x86 C++')
    execute 'Install MS 2012 x86 C++' do
      cwd "#{node['tsm']['temp']}7.1.4.1-tiv-tsmbac-winx64\\ISSetupPrerequisites\\{BF2F04CD-3D1F-444e-8960-D08EBD285C3F}"
      command '.\vcredist_x86.exe /install /quiet /log C:\\tsm_temp\\vcredistMS12_x86_2.log -wait'
      action :run
    end

    Chef::Log.info('Installing MS 2010 x64 C++')
    execute 'Install MS 2010 x64 C++' do
      cwd "#{node['tsm']['temp']}7.1.4.1-tiv-tsmbac-winx64\\ISSetupPrerequisites\\{7f66a156-bc3b-479d-9703-65db354235cc}"
      command '.\vcredist_x64.exe /install /quiet /log C:\\tsm_temp\\vcredistMS10_x64_2.log -wait'
      action :run
    end

    Chef::Log.info('Installing MS 2012 x64 C++')
    execute 'Install MS 2012 x64 C++' do
      cwd "#{node['tsm']['temp']}7.1.4.1-tiv-tsmbac-winx64\\ISSetupPrerequisites\\{3A3AF437-A9CD-472f-9BC9-8EEDD7505A02}"
      command '.\vcredist_x64.exe /install /quiet /log C:\\tsm_temp\\vcredistMS12_x64_2.log -wait'
      action :run
    end

    # TSM agent installation
    Chef::Log.info('Performing tsm agent installation...')
    execute 'Install tsm Agent' do
      cwd 'C:\\'
      command 'msiexec /i "C:\\tsm_temp\\7.1.4.1-tiv-tsmbac-winx64\\IBM Tivoli Storage Manager Client.msi" RebootYesNo="No" REBOOT="Suppress" ALLUSERS=1 INSTALLDIR="C:\\Program Files\\IBM\\Tivoli\\tsm" ADDLOCAL="BackupArchiveGUI,BackupArchiveWeb,Api64Runtime,AdministrativeCmd" TRANSFORMS=1033.mst /qn /l*v "c:\\tsm_install_log.txt"'
      action :run
    end
  end
end

def check_prereq
  case node['platform']
  when 'redhat'
    Chef::Log.info('Checking prerequisites for TSM agent........')

    # check the node CPU architecture
    ruby_block 'Checking node architecture' do
      block do
        if node['tsm7']['cpu_arch'] == node['tsm7']['supported_arch']
          Chef::Log.info("#{cookbook_name}:#{recipe_name} :Node architecture : #{node['tsm7']['cpu_arch']}")
          Chef::Log.info("#{cookbook_name}:#{recipe_name} :Supported Node architecture")
        else
          Chef::Log.error("#{cookbook_name}:#{recipe_name} :Unsupported Node architecture : #{node['tsm7']['cpu_arch']}")
          Chef::Log.info("#{cookbook_name}:#{recipe_name} :Aborting.........")
          # raise
        end
      end
    end

    # Verify supported RHEL version
    ruby_block 'Check RHEL version ' do
      block do
        rhel_version = node['tsm7']['rhel_version']
        if rhel_version > node['tsm7']['min_rhel_version'].to_i
          Chef::Log.info("#{cookbook_name}:#{recipe_name} : Rhel Version #{rhel_version} is Supported")
        else
          Chef::Log.error("#{cookbook_name}:#{recipe_name} : Rhel Version #{rhel_version} is Not Supported ")
          Chef::Log.info("#{cookbook_name}:#{recipe_name} :Aborting..")
          # raise
        end
      end
    end

    # Verify Hardware requirements - CPU
    ruby_block 'check cpu model' do
      block do
        Chef::Log.info('Checking Hardware requirements........')
        if /(intel|amd|via)/i =~ node['tsm7']['cpu_model_name'].to_s
          Chef::Log.info("Required CPU: < #{node['tsm7']['cpu_model_name']} > present")
          Chef::Log.info("CPU architecture : #{node['tsm7']['cpu_arch']}")
        else
          Chef::Log.error('CPU requirement not met.. Aborting')
          # raise
        end
      end
    end

    # Verify if prerequisite packages are installed
    Chef::Log.info('Checking for prerequisite packages...........')
    ruby_block 'Checking for prerequisite packages' do
      block do
        node['tsm7']['reqpkjs'].each do |pkj|
          pkj_installed = IO.popen("rpm -qa | grep #{pkj}").readlines.join.chomp
          if pkj_installed
            Chef::Log.info("#{pkj} is installed : #{pkj_installed}")
          else
            yum_package "#{pkj}" do
            action :upgrade
          end
        end
      end
    end
  end
end

def install_tsm
  case node['platform']
  when 'redhat'
    Chef::Log.info('Installing TSM client on linux..........')

    #Create TSM opt logical volume 
    # Create dir to mount
    directory '/opt/tivoli/tsm' do
      recursive true
      action :create
    end

    #Create SCM logical volume 
    node['tsm7']['logvols'].each do |logvol|
    lvm_logical_volume logvol['volname'] do
      group   node['tsm7']['volumegroup']
      size    logvol['size']
      filesystem    logvol['fstype']
      mount_point   logvol['mountpoint']
    end
  end
    tempfolder = '/tmp/tsm_temp'

    directory tempfolder.to_s do
      action :create
    end

    # get TSM media to our temp dir
    # ----------------------------------------------------------------
    media = tempfolder + '/' + node['tsm7']['base_package'].to_s

    remote_file media.to_s do
      source node['tsm7']['url_base_package'].to_s
      owner 'root'
      group 'root'
      mode '0755'
      action :create_if_missing
    end

    # Unpack media
    # ----------------------------------------------------------------
    execute 'unpack-media' do
      command 'cd ' + tempfolder.to_s + ' ; ' + ' tar -xf ' + media.to_s
      action :run
      not_if { ::File.exists?("#{media}/#{node['tsm7']['base_package']}") }
    end

    # verify packages if already installed
    yum_list = shell_out('yum list installed > /tmp/packagelist.txt 2>&1')

    # install rpm package for TSM agent
    # ----------------------------------------------------------------
    node['tsm7']['package_rpm'].each do |pkj|
      # node['tsm7']['pkg_list'].each do |pkglist|
        execute 'Install_RPMS' do
          command "rpm -Uvh #{tempfolder}/#{pkj}"
          returns [0, 1]
          action :run	
	      # end
        end
      # end
    end

    directory tempfolder.to_s do
      recursive true
      action :delete
    end

  # installing for aix
  when 'aix'
	
  # creating prerequisite FS
  # create volume group ibmvg as mandatory requirement
  execute 'create-VG-ibmvg' do
    command 'mkvg -f -y ibmvg hdisk1'
    action :run
    returns [0, 1]
    not_if { shell_out('lsvg | grep ibmvg').stdout.chop != '' }
  end
  # required FS
  volumes = [
    { lvname: 'lv_tsm_opt', fstype: 'jfs2', vgname: 'ibmvg', size: 1524, fsname: '/usr/tivoli/tsm/' }
  ]
  # Custom FS creation
  volumes.each do |data|
    ibm_tsm7_makefs "creation of #{data[:fsname]} file system" do
      lvname data[:lvname]
      fsname data[:fsname]
      vgname data[:vgname]
      fstype data[:fstype]
      size data[:size]
    end
  end
  
  Chef::Log.info('Installing TSM client on linux..........')
    tempfolder = '/tmp/tsm_software'

    directory tempfolder.to_s do
      action :create
    end

    # get TSM media to our temp dir
    # ----------------------------------------------------------------
    media = tempfolder.to_s + '/' + node['tsm7']['base_package'].to_s

    remote_file media.to_s do
      source node['tsm7']['url_base_package'].to_s
      owner 'root'
      mode '0755'
      action :create_if_missing
    end

    # Unpack media
    # ----------------------------------------------------------------
    execute 'unpack-media' do
      command 'cd ' + tempfolder.to_s + ' ; ' + ' tar -xf ' + media.to_s
      action :run
      not_if { ::File.exists?("#{media}/#{node['tsm7']['base_package']}") }
    end

    # install rpm package for TSM agent
    # ----------------------------------------------------------------
    node['tsm7']['package_aix'].each do |pkj|
      execute 'Install_Packages' do
        command "installp -acgXd #{tempfolder}/ #{pkj}"
        returns [0, 1]
        not_if{ shell_out("lslpp -l |grep #{pkj}").stdout != '' }
      end
    end

    directory tempfolder.to_s do
      recursive true
      action :delete
    end
  end
end

# Configure the node
# -----------------------------------------------------------------------------------------------------------------------------------
def configure_tsm
  case node['platform']
  when 'redhat'
    Chef::Log.info('Configuring the TSM node .......................')

    template '/opt/tivoli/tsm/client/ba/bin/dsm.sys' do
      source 'dsm.sys.erb'
	  owner 'root'
	  mode '0644'
      variables(
        :servername => node['tsm7']['servername'],
        :commmethod => node['tsm7']['COMMmethod'],
        :tcpport => node['tsm7']['TCPPort'],
        :tcpserveraddress => node['tsm7']['TCPServeraddress'],
        :tcpbuffsize => node['tsm7']['TCPBuffsize'],
        :tcpwindowsize => node['tsm7']['TCPWindowsize'],
        :tcpnodelay => node['tsm7']['TCPNodelay'],
        :largecommbuffer => node['tsm7']['Largecommbuffer'],
        :nodename => node['tsm7']['Nodename'],
        :passwordaccess => node['tsm7']['Passwordaccess'],
        :errorlogname => node['tsm7']['Errorlogname'],
        :schedlogname => node['tsm7']['Schedlogname'],
        :errorlogretention => node['tsm7']['Errorlogretention'],
        :schedlogretention => node['tsm7']['Schedlogretention'],
        :schedmode => node['tsm7']['*Schedmode'],
        :schedmode => node['tsm7']['Schedmode'],
        :queryschedperiod => node['tsm7']['queryschedperiod'],
        :managedservices => node['tsm7']['Managedservices'],
        :resourceutilization => node['tsm7']['Resourceutilization'],
        :inclexcl => node['tsm7']['inclexcl'],
        :httpport => node['tsm7']['Httpport'],
        :tcpclientport => node['tsm7']['Tcpclientport'],
        :tcpclientaddress => node['tsm7']['Tcpclientaddress'],
        :imagegapsize => node['tsm7']['imagegapsize'],
        :snapshotprovideri => node['tsm7']['Snapshotprovideri'],
        :enablelanfree => node['tsm7']['enablelanfree'],
        :lanfreecommmethod => node['tsm7']['LANFREECommmethod'],
        :lanfreetcpport => node['tsm7']['LANFREETCPPort'],
        :lanfreetcpserveraddress => node['tsm7']['LANFREETCPServeraddress'],
        :lanfreeshmport => node['tsm7']['TCPPort']
      )
	  action :create
    end

    template '/opt/tivoli/tsm/client/ba/bin/dsminc.opt' do
      source 'dsminc.opt.erb'
      owner 'root'
      group 'root'
      mode '0755'
      variables(
        :servername => node['tsm7']['servername']
      )
	  action :create
    end

    template '/opt/tivoli/tsm/client/ba/bin/inclexcl.txt' do
      source 'inclexcl.txt.erb'
	  owner 'root'
      group 'root'
      mode '0755'
      action :create
    end

  # configuring for aix
  when 'aix'
    Chef::Log.info('Configuring the TSM node .......................')

    template '/usr/tivoli/tsm/client/ba/bin64/dsm.sys' do
      source 'dsm.sys.erb'
	  owner 'root'
	  mode '0644'
      variables(
        :servername => node['tsm7']['servername'],
        :commmethod => node['tsm7']['COMMmethod'],
        :tcpport => node['tsm7']['TCPPort'],
        :tcpserveraddress => node['tsm7']['TCPServeraddress'],
        :tcpbuffsize => node['tsm7']['TCPBuffsize'],
        :tcpwindowsize => node['tsm7']['TCPWindowsize'],
        :tcpnodelay => node['tsm7']['TCPNodelay'],
        :largecommbuffer => node['tsm7']['Largecommbuffer'],
        :nodename => node['tsm7']['Nodename'],
        :passwordaccess => node['tsm7']['Passwordaccess'],
        :errorlogname => node['tsm7']['Errorlogname'],
        :schedlogname => node['tsm7']['Schedlogname'],
        :errorlogretention => node['tsm7']['Errorlogretention'],
        :schedlogretention => node['tsm7']['Schedlogretention'],
        :schedmode => node['tsm7']['*Schedmode'],
        :schedmode => node['tsm7']['Schedmode'],
        :queryschedperiod => node['tsm7']['queryschedperiod'],
        :managedservices => node['tsm7']['Managedservices'],
        :resourceutilization => node['tsm7']['Resourceutilization'],
        :inclexcl => node['tsm7']['inclexcl'],
        :httpport => node['tsm7']['Httpport'],
        :tcpclientport => node['tsm7']['Tcpclientport'],
        :tcpclientaddress => node['tsm7']['Tcpclientaddress'],
        :imagegapsize => node['tsm7']['imagegapsize'],
        :snapshotprovideri => node['tsm7']['Snapshotprovideri'],
        :enablelanfree => node['tsm7']['enablelanfree'],
        :lanfreecommmethod => node['tsm7']['LANFREECommmethod'],
        :lanfreetcpport => node['tsm7']['LANFREETCPPort'],
        :lanfreetcpserveraddress => node['tsm7']['LANFREETCPServeraddress'],
        :lanfreeshmport => node['tsm7']['TCPPort']
      )
	  action :create
    end

    template '/usr/tivoli/tsm/client/ba/bin64/dsminc.opt' do
      source 'dsminc.opt.erb'
      owner 'root'
      mode '0755'
      variables(
        :servername => node['tsm7']['servername']
      )
	  action :create
    end

    template '/usr/tivoli/tsm/client/ba/bin64/inclexcl.txt' do
      source 'inclexcl.txt.erb'
	  owner 'root'
      mode '0755'
      action :create
    end
  end
end

def register_tsm
  case node['platform']
  when 'redhat'
    # registering tsm client with tsm server--------LINUX
    Chef::Log.info('Registering TSM client .....................')

    # verify if agent is already registered
    verify_registration

    export_command = "export DSM_CONFIG=/opt/tivoli/tsm/client/ba/bin/dsminc.opt"
    register_command = "REGISTER NODE #{node['tsm7']['Nodename']} #{node['tsm7']['Nodename']} comp=CLIENT archdel=YES type=Client backdel=NO keepmp=NO maxnummp=4 clo=#{node['tsm7']['TSM_COS']} dom=DOM_PRD_STD url=http://#{node['tsm7']['Nodename']}:10581 userid=none autofsr=NO vali=NO dataw=ANY datar=ANY sessioninit=CLIENTORSERVER forcep=NO txng=0 hla=#{node['tsm7']['Nodename']} lla=10581"

    execute 'register-tsm-node' do
      command  "#{export_command}; " + "dsmadmc -id=#{node['tsm7']['TSM_ICO_User']} -pa=#{node['tsm7']['TSM_ICO_Pwd']} #{register_command}"
      live_stream true
      returns [0,10]
      action :run
      not_if{ "#{node['tsm7']['reg_status']}" == 'success' }
    end

    execute 'set-password' do
      command "/opt/tivoli/tsm/client/ba/bin/dsmc SET PASSWORD #{node['tsm7']['Nodename']} #{node['tsm7']['Nodename']} -optfile=/opt/tivoli/tsm/client/ba/bin/dsminc.opt"
      action :run
    end

    execute 'start-tsm-service' do
      command "/opt/tivoli/tsm/client/ba/bin/dsmcad -optfile=/opt/tivoli/tsm/client/ba/bin/dsminc.opt"
      action :run
    end

  # registering for aix node
  when 'aix'
	# registering tsm client with tsm server--------LINUX
    Chef::Log.info('Registering TSM client .....................')

    # verify registration
    verify_registration
  
    export_command = "export DSM_CONFIG=/usr/tivoli/tsm/client/ba/bin64/dsminc.opt"
    register_command = "REGISTER NODE #{node['tsm7']['Nodename']} #{node['tsm7']['Nodename']} comp=CLIENT archdel=YES type=Client backdel=YES keepmp=NO maxnummp=4 clo=#{node['tsm7']['TSM_COS']} dom=DOM_PRD_STD url=http://#{node['tsm7']['Nodename']}:10581 userid=none autofsr=NO vali=NO dataw=ANY datar=ANY sessioninit=CLIENTORSERVER forcep=NO txng=0 hla=#{node['tsm7']['Nodename']} lla=10581"

    execute 'register-tsm-node' do
      command  "#{export_command}; " + "dsmadmc -id=#{node['tsm7']['TSM_ICO_User']} -pa=#{node['tsm7']['TSM_ICO_Pwd']} #{register_command}"
      returns [0,10]
      action :run
      not_if{ "#{node['tsm7']['reg_status']}" == 'success' }
    end

    # verify collaction if associated with COL_DEF
    verify_collaction
  
    # Define collacation
    def_coll = "define collocmember COL_DEF #{node['tsm7']['Nodename']}"
    execute 'define-collacation' do
      command "/usr/tivoli/tsm/client/ba/bin64/dsmadmc -id=#{node['tsm7']['TSM_ICO_User']} -pa=#{node['tsm7']['TSM_ICO_Pwd']} " + "#{def_coll}"
      ignore_failure true
      action :run
      not_if { node['tsm7']['coll_status'].to_s == 'exist' }
    end

    # set password
    execute 'set-password' do
      command "/usr/tivoli/tsm/client/ba/bin64/dsmc SET PASSWORD #{node['tsm7']['Nodename']} #{node['tsm7']['Nodename']} -optfile=/usr/tivoli/tsm/client/ba/bin64/dsminc.opt"
      ignore_failure true
      action :run
      not_if{ node['tsm7']['reg_status'].to_s == 'success' }
    end

    execute 'start-tsm-service' do
      command "/usr/tivoli/tsm/client/ba/bin64/dsmcad -optfile=/usr/tivoli/tsm/client/ba/bin64/dsminc.opt"
      action :run
    end

    # Define clientaction, it schedules first server backup
    execute 'schedule-server-backup' do
      command "/usr/tivoli/tsm/client/ba/bin64/dsmadmc -id=#{node['tsm7']['TSM_ICO_User']} -pa=#{node['tsm7']['TSM_ICO_Pwd']} " + "def clienta #{node['tsm7']['Nodename']}"
      ignore_failure true
      action :run
      not_if{ node['tsm7']['reg_status'].to_s == 'success' }
    end

    # add entry in /etc/iniittab for agent to start automatically after rebooting
    ruby_block 'update-inittabfile' do
      Chef::Log.info('Updating /etc/inittab file .................')
      block do
        line = 'cad::once:/usr/tivoli/tsm/client/ba/bin64/dsmcad -optfile=/usr/tivoli/tsm/client/ba/bin64/dsminc.opt &>/dev/null 2>&1'
        file = Chef::Util::FileEdit.new('/etc/inittab')
        file.insert_line_if_no_match(/#{line}/, line)
        file.write_file
      end
      action :create
    end
  end
end

def verify_registration 
  Chef::Log.info('Verifying Registration.......')

  reg_status = shell_out("dsmadmc -id=#{node['tsm7']['TSM_ICO_User']} -pa=#{node['tsm7']['TSM_ICO_Pwd']} 'query node #{node['tsm7']['Nodename']} format=standard'").stdout
  node_name = "#{node['tsm7']['Nodename']}".upcase
  # check if the agent registration exist on server
  if "#{reg_status}".include?("#{node_name}")
    Chef::Log.info('Agent is already registered !!')
    node.default['tsm7']['reg_status'] = 'success'
  else
    Chef::Log.info('Agent is not registered.........Proceed with registration !')
  end
end

def verify_collaction
  Chef::Log.info('Verifying collacation association.....')

  def_coll = "define collocmember COL_DEF #{node['tsm7']['Nodename']}"
  node_name = "#{node['tsm7']['Nodename']}".upcase
  coll = shell_out("/usr/tivoli/tsm/client/ba/bin64/dsmadmc -id=#{node['tsm7']['TSM_ICO_User']} -pa=#{node['tsm7']['TSM_ICO_Pwd']} " + "#{def_coll}").stdout
  if "#{coll}".include?("ANR4884W Node #{node_name} already associated to collocation group COL_DEF")
    node.default['tsm7']['coll_status'] = 'exist'
  else
    Chef::Log.info('Collacation is not associated with group COL_DEF.......Proceed with collacation')
  end
end

def register_node_win
  if node.attribute?('tsm_register')
    Chef::Log.info('TSM agent registered already.')
  else
    # registering the node on the TSM server
    Chef::Log.info('registering the node on the TSM server ..........')
    
    execute 'SetPath_Configuration_File' do
      cwd node['tsm']['baclient'].to_s
      command "SET DSM_CONFIG = #{node['tsm']['baclient']}\\dsm.opt"
      action :run
    end

    # Create TSM_Params_input conf File
    template "#{node['tsm']['temp']}\\TSM_params_input.conf" do
      source 'TSM_params_input_win.conf.erb'
      variables(
        :VM_DC => node['tsm']['VM_DC'],
        :VM_ENV => node['tsm']['VM_ENV']
      )
    end

    directory "#{node['tsm']['baclient']}" do
      mode '777'
      action :create
    end

    # create dsm file
    template "#{node['tsm']['baclient']}\\dsm.opt" do
      source 'dsm_win.opt.erb'
      variables(
        :TSM_Port => node['tsm']['TSM_Port'],
        :VM_Hostname => node['tsm']['hostname'],
        :TSM_IP => node['tsm']['TSM_IP']
      )
    end

    register_cmd = "REGISTER NODE #{node['tsm']['hostname']}  #{node['tsm']['hostname']} comp=CLIENT archdel=YES type=Client backdel=NO keepmp=NO maxnummp=4 clo=#{node['tsm']['TSM_COS']} dom=DOM_PRD_STD url=http://#{node['tsm']['hostname']}:10581 userid=none autofsr=NO vali=NO dataw=ANY datar=ANY sessioninit=CLIENTORSERVER forcep=NO txng=0 hla=#{node['tsm']['hostname']} lla=10581"
    execute 'TSM_Node_Registration' do
      cwd node['tsm']['baclient'].to_s
      command "dsmadmc.exe -id=#{node['tsm']['TSM_ICO_User']} -pa=#{node['tsm']['TSM_ICO_Pwd']} #{register_cmd}"
      action :run
    end
    node.set['tsm']['tsm_register'] = 'success'
    Chef::Log.info('Configuring the TSM node .......................')
    hostname = node['tsm']['hostname']
    execute 'Configure_TSM_Agent' do
      cwd node['tsm']['baclient'].to_s
      command 'dsmc.exe SET PASSWORD' " #{node['tsm']['hostname']} #{node['tsm']['hostname']} " '-optfile="C:\\Program Files\\IBM\\Tivoli\\tsm\\baclient\\dsm.opt"'
      action :run
    end
    # Deleting the Temp file
    directory node['tsm']['temp'].to_s do
      recursive true
      action :delete
    end
  end
end

def uninstall_tsm
  case node['platform']
  when 'redhat'
    Chef::Log.info('Uninstalling TSM agent ................................')

    # Un-install rpm package for TSM asgent

    node['tsm7']['uninstall_package_rpm'].each do |pkj|
      execute 'Un-install_TSM' do
        command "rpm -e #{pkj}"
        returns [0, 1]
      end
    end
  end
end
end
