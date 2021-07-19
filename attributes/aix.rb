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

case node['platform']
when 'aix'

  	# prereqs
	default['tsm7']['reqpkjs'] = ['acl' , 'device-mapper-libs']
	default['tsm7']['user'] = "root"
    default['tsm7']['cpu_model_name'] = node['cpu']['0']['model_name']
    default['tsm7']['cpu_arch'] = node['kernel']['machine']

	# node details
	default['tsm7']['rhel_version']	= node['platform_version'].to_f
	default['tsm7']['min_rhel_version']	= 5
	default['tsm7']['supported_arch'] = 'x86_64'

	# TSM package
	# default['tsm7']['tsm_pkj_path'] = '/tsm/v71/base/linux'
	default['tsm7']['base_package'] = '7.1.2.0-TIV-TSMBAC-AIX.tar'
	# url to download tsm binary
	default['tsm7']['url_base_package'] = 'https://client.com/ibm/aix7/tsm/7.1.2.0-TIV-TSMBAC-AIX.tar'

	# TSM input configuration file for datacenters
	default['tsm7']['input_params'] = '/tmp/TSM_params_input.conf'


	default['tsm7']['package_aix'] = [ 'GSKit8.gskcrypt64.ppc.rte', 'GSKit8.gskssl64.ppc.rte', 'tivoli.tsm.client.api.64bit', 'tivoli.tsm.client.ba.64bit', 'tivoli.tsm.filepath.rte', 'tivoli.tsm.client.jbb.64bit']
    default['tsm7']['uninstall_package_rpm'] = [ 'gskcrypt', 'gskssl6', 'TIVsm-API64', 'TIVsm-BA']

	# TSM agent service file
	default['tsm7']['tsm_init']	= 'dsm-sched.conf'

	# host details
	default['tsm7']['Linux_NODEPASSWORD'] = ''

	# TSM Admin Details
	default['tsm7']['tsm_admin'] = 'admin'
	default['tsm7']['tsm_admin_psw'] = 'admin'
    default['tsm7']['nodename']	= node['hostname']
    default['tsm7']['userid']  = 'none'
	default['tsm7']['contact'] = "ICO Team" 
	
	# attributes for /etc/yum.conf file
    default['tsm7']['cachedir'] = '/var/cache/yum'
    default['tsm7']['keepcache'] = 0
    default['tsm7']['debuglevel'] = 3
    default['tsm7']['logfile'] = '/var/log/yum.log'
    default['tsm7']['distroverpkg'] = 'redhat-release'
    default['tsm7']['tolerant'] = 1
    default['tsm7']['exactarch'] = 1
    default['tsm7']['obsoletes'] = 1
    default['tsm7']['gpgcheck'] = 1
    default['tsm7']['plugins'] = 0
    default['tsm7']['exclude'] = 'kernel*'
    default['tsm7']['tsflags'] = 'repackage'
    default['tsm7']['metadata_expire'] = '1h'
	default['tsm']['VM_DC'] = 'DC2'
	
	# attributes to configure TSM node file dsm.sys
	if node['tsm']['VM_DC'].to_s == 'DC2'
      RNumber = Random.new
      R_number = RNumber.to_s % '10'
      if R_number.to_s < '1'
        default['tsm7']['servername'] = 'rltia00007'
        default['tsm7']['TCPPort'] = '1500'
        default['tsm7']['TCPServeraddress'] = '10.99.144.46'
      else
        default['tsm7']['servername'] = 'rltia00008'
        default['tsm7']['TCPPort'] = '1500'
        default['tsm7']['TCPServeraddress'] = '10.99.144.47'
      end
    end

    default['tsm7']['COMMmethod'] = 'tcpip'
    default['tsm7']['TCPBuffsize'] = 32
    default['tsm7']['TCPWindowsize'] = 64
    default['tsm7']['TCPNodelay'] = 'yes'
    default['tsm7']['Largecommbuffer'] = 'yes'
    default['tsm7']['Nodename'] = node['hostname'] + '.client.com'
    default['tsm7']['Passwordaccess'] = 'generate'
    default['tsm7']['Errorlogname'] = '/production/home/tsm/log/dsmerror.log'
    default['tsm7']['Schedlogname'] = '/production/home/tsm/log/dsmsched.log'
    default['tsm7']['Errorlogretention'] = 7
    default['tsm7']['Schedlogretention'] = 7
    # default['tsm7']['*Schedmode'] = 'prompted'
    default['tsm7']['Schedmode'] = 'polling'
    default['tsm7']['queryschedperiod'] = 1
    default['tsm7']['Managedservices'] = 'schedule webclient'
    default['tsm7']['Resourceutilization'] = 5
    default['tsm7']['inclexcl'] = '/usr/tivoli/tsm/client/ba/bin64/inclexcl.txt'
    default['tsm7']['Httpport'] = '10581'
    default['tsm7']['Tcpclientport'] = '10581'
    default['tsm7']['Tcpclientaddress'] = node['hostname']
    default['tsm7']['imagegapsize'] = 0
    default['tsm7']['Snapshotprovideri'] = 'None'
    default['tsm7']['enablelanfree'] = 'no'
    default['tsm7']['LANFREECommmethod'] = 'tcpip'
    default['tsm7']['LANFREETCPPort'] = '10621'
    default['tsm7']['LANFREETCPServeraddress'] = 'localhost'
    default['tsm7']['LANFREESHMPort'] = '10611'
	
	default['tsm7']['TSM_ICO_User'] = 'username'
	default['tsm7']['TSM_ICO_Pwd'] = 'password'
	default['tsm7']['TSM_COS'] = 'COS_LNX_STD'

    default['tsm7']['reg_status'] = ''
    default['tsm7']['coll_status'] = ''

end
