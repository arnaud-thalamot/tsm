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

actions :install, :register, :configure, :uninstall

def initialize(*args)
  super
  @action = :install
end

