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

# This recipe will perform installation of tsm agent, post-install configuration and registering the tsm client
case node['platform']
when 'windows'
  ibm_tsm7_tsmagent 'install-register-tsm-agent' do
    action [:install, :register]
  end

when 'redhat'
  ibm_tsm7_tsmagent 'install-register-tsm-agent' do
    action [:install, :configure, :register]
  end

when 'aix'
  ibm_tsm7_tsmagent 'install-register-tsm-agent' do
    action [:install, :configure, :register]
  end
end

node.set['tsm']['status'] = 'success'
