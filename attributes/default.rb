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

when 'windows'
  # TSM installer file
  default['tsm']['TSMfile'] = 'tsm_installer.zip'
  # Temp file where we copy the TSM installer
  default['tsm']['temp'] = 'C:\\tsm_temp\\'
  # Installed Path for TSM agent
  default['tsm']['InstalledPath'] = 'C:\\tsm_images\\'
  # Path for TSM agent installed
  default['tsm']['alreadyInstalledFile'] = 'C:\\Program Files\\IBM\\Tivoli\\tsm\\config'
  # Remote location for TSM setup file
  default['tsm']['TSMfile_Path'] = 'http://10.0.0.1/windows2012R2/tsm/tsm_installer.zip '
  # Location of the dsm.log file
  default['tsm']['dsmfile_Path'] = 'C:\\Program Files\\IBM\\Tivoli\\tsm\\config'
  # The original hostname of the machine
  default['tsm']['hostname'] = node['hostname'].downcase
  # Value for TSM_COS
  default['tsm']['TSM_COS'] = 'COS_WIN_STD'
  # TSM ICO Usename
  default['tsm']['TSM_ICO_User'] = 'username'
  # TSM ICO Password
  default['tsm']['TSM_ICO_Pwd'] = 'password'
  # Path for baclient
  default['tsm']['baclient'] = 'C:\\Program Files\\IBM\\Tivoli\\tsm\\baclient'
  # Parameters for TSM_params_input conf file
  default['tsm']['VM_DC'] = 'DC2'
  default['tsm']['VM_ENV'] = 'NO_PROD'
  # TSM service name
  default['tsm']['serviceName'] = ''


  if node['tsm']['VM_DC'].to_s == 'DC2'
    RNumber = rand(0..1).ceil
    if RNumber == 0 then
      # Value for TSM HostName
      default['tsm']['TSM_HostName'] = 'hostname1'
      # Value for the TSM Port
      default['tsm']['TSM_Port'] = '1500'
      # Value for TSM IP
      default['tsm']['TSM_IP'] = '10.0.0.1'
    else
      # Value for TSM HostName
      default['tsm']['TSM_HostName'] = 'hostname2'
      # Value for the TSM Port
      default['tsm']['TSM_Port'] = '1500'
      # Value for TSM I
      default['tsm']['TSM_IP'] = '10.0.0.1'
    end
  end
end
