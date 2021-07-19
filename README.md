# tsm7 Cookbook

The tsm7 cookbook will perform silent installation of visual c++ packages and tsm7 agent version 7.1 on the node and register the node for TSM agent. It performs post-install configuration for the tsm7 agent.

Requirements

- Storage : 2 GB
- RAM : 2 GB
- Versions
  - Chef Development Kit Version: 0.17.17
  - Chef-client version: 12.13.37
  - Kitchen version: 1.11.1


Platforms

    RHEL-7/Winodws 2012

Chef

    Chef 11+

Cookbooks

    none

Resources/Providers

- tsmagent
  This tsmagent resource/provider performs the following :-
  
  For Winodws Platform:
  1. Creates necessary directories for 
     - copying the tsm agent Native installer
  2. Extracting the tsm installer to fetch the required setup file for installation
  3. Install the tsm v 7.1 from temporary directory.
  4. Register the node for TSM agent.
  5. configure the TSM agent.
  6. Delete the temporary directory containing the files used during installation.
  7. uninstall the tsm agent.

Example

1. tsmagent 'install-tsm-agent' do
  action :install, :register, :configure
end   

Actions

    :install - installs and configures the TSM agent
    :Register - Register the node for TSM agent.
    :Configure - configute the TSM agent.


Recipes

    install_tsm:: The recipe installs the required version of tsmagent for windows platform.

2. tsmagent 'uninstall-tsm-agent' do
  action :uninstall
end   

Actions

    :uninstall - uninstall the tsm agent


Recipes

    uninstall_tsm7:: The recipe uninstalls the required version of tsm agent for windows platform.

Attributes

Below attributes are specific to windows platform:

default['tsm']['TSMfile'] = 'tsm_installer.zip'      # TSM installer native file
  default['tsm']['temp'] = 'C:\\tsm_temp\\'          # Temp file where we copy the TSM installer
  default['tsm']['InstalledPath'] = 'C:\\tsm_images\\'     # Installed Path for TSM agent
  default['tsm']['alreadyInstalledFile'] = 'C:\\IBM\IEM\\BESClient.exe'    # Path for TSM agent installed
  default['tsm']['TSMfile_Path'] = 'https://pulp.cma-cgm.com/ibm/windows2012R2/tsm_installer.zip '    # Remote location for TSM setup file
  default['tsm']['dsmfile_Path'] = 'C:\\Program Files\\IBM\\Tivoli\\tsm\\baclient'    # Location of the dsm.log file
  default['tsm']['hostname'] = node['hostname'].downcase      # The original hostname of the machine
  default['tsm']['TSM_COS'] = 'COS_WIN_STD'            # Value for TSM_COS
  default['tsm']['baclient'] = "C:\\Program Files\\IBM\\Tivoli\\tsm\\baclient"       # Path for baclient
  default['tsm']['VM_DC'] = "DC2"                     # Parameters for TSM_params_input conf file
  default['tsm']['VM_ENV'] = "NO_PROD"
  default['tsm']['TSM_HostName'] = "rltia00008"     # Value for TSM HostName
  default['tsm']['TSM_Port'] = "1500"               # Value for the TSM Port
  default['tsm']['TSM_IP'] = "10.99.144.47"         # Value for TSM IP