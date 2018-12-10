# Copyright (c) 2016 Computer Networks and Distributed Systems LABORAtory (LABORA).
# This proxy represents physical host machine.
#
module OmfRc::ResourceProxy::Datacom
  include OmfRc::ResourceProxyDSL

  register_proxy :datacom

  utility :common_tools
  utility :ip

  property :number_vlan, :default => "number_vlan"
  property :port_vlan, :default => "port_vlan"
   
  #
  # Set the :number_vlan
  #
  configure :number_vlan do |datacom, value|
    info 'Configure(number_vlan) called'
    datacom.property.number_vlan = value
    datacom.property.number_vlan
  end

  #
  # Set the :port_vlan
  #
  configure :port_vlan do |datacom, value|
    info 'Configure(port_vlan) called'
    datacom.property.port_vlan = value
    datacom.property.port_vlan
  end

  #
  # Configure the :upload_telnet
  #
  configure :upload_telnet do |datacom, value|
    info 'Configure(upload_telnet) called'
    datacom.execute_cmd("/root/EC/./login.sh #{datacom.property.number_vlan} #{datacom.property.port_vlan}").delete("\n")
  end
end
