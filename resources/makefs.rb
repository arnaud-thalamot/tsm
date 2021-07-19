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

actions :create, :delete

property :name, String, required: true, name_attribute: true
property :fsname, String, required: false
property :lvname, String, required: false
property :fstype, String, required: false
property :vgname, String, required: false
property :size, Integer, required: false
attr_accessor :lvexist
attr_accessor :fsexist
attr_accessor :mountexist

def initialize(*args)
  super
  @action = :create
end
