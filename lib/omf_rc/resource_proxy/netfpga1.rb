# Copyright (c) 2016 Computer Networks and Distributed Systems LABORAtory (LABORA).
# This proxy represents physical host machine.
#
module OmfRc::ResourceProxy::Netfpga
  include OmfRc::ResourceProxyDSL

  register_proxy :netfpga1

  utility :common_tools
  utility :ip

  property :if_name, :default => "eth0"
  property :bit_name, :default => "bit_name"
  property :conf_name, :default => "conf_name"
  property :ip_ec, :default => "ip"
  #
  # Gets the :if_name property
  #
  request :if_name do |netfpga1|
    info 'Request(if_name) called'
    netfpga1.property.if_name
  end

  #
  # Gets the :ip_address of :if_name interface
  #
  request :ip_address do |netfpga1|
    info 'Request(ip_address) called'
    netfpga1.__send__("request_ip_addr")
  end

  #
  # Gets the :hostname
  #
  request :hostname do |netfpga1|
    info 'Request(hostname) called'
    hostname = netfpga1.execute_cmd("cat /etc/hostname").delete("\n")
    hostname
  end

  #
  # Configures the :if_name property
  #
  configure :if_name do |netfpga1, value|
    info 'Configure(if_name) called'
    netfpga1.property.if_name = value
    value
  end

  #
  # Configures the :ip_address of :if_name interface
  #
  configure :ip_address do |netfpga1, ip_address|
    info 'Configure(ip_address) called'
    netfpga1.__send__("configure_ip_addr", ip_address)
    ip_address
  end

  #
  # Configures the :hostname
  #
  configure :hostname do |netfpga1, hostname|
    info 'Configure(hostname) called'  
    netfpga1.execute_cmd("echo #{hostname} > /etc/hostname")
    hostname
  end

  #
  # Set the :bit_name
  #
  configure :bit_name do |netfpga1, value|
    info 'Configure(bit_name) called'
    netfpga1.property.bit_name = value
    netfpga1.property.bit_name
  end

  #
  # Set the :conf_name
  #
  configure :conf_name do |netfpga1, value|
    info 'Configure(conf_name) called'
    netfpga1.property.conf_name = value
    netfpga1.property.conf_name
  end


  #
  # Set the :ip_ec
  #
  configure :ip_ec do |netfpga1, value|
    info 'Configure(ip_ec) called'
    netfpga1.property.ip_ec = value
    netfpga1.property.ip_ec
  end

  #
  # Configure the :upload_bit
  #


  configure :upload_bit do |netfpga1, value|
    info 'Configure(upload_bit) called'
    netfpga1.execute_cmd("scp ec:/root/ec/#{netfpga1.property.bit_name} /tmp").delete("\n")
  value
  end

  #
  # Configure the :upload_conf
  #
  configure :upload_conf do |netfpga1, value|
    info 'Configure(upload_conf) called'
    netfpga1.execute_cmd("scp ec:/root/ec/#{netfpga1.property.conf_name} /tmp").delete("\n")
  value
  end

  #
  # Configure the :run_bit
  #
  configure :run_bit do |netfpga1, value|
    info 'Configure(run_bit) called'
    result=netfpga1.execute_cmd("/usr/local/sbin/cpci_reprogram.pl --all").delete("\n")
    netfpga1.inform(:resultado_comando, {:result => result})
    netfpga1.execute_cmd("nf_download /tmp/#{netfpga1.property.bit_name}").delete("\n")
    netfpga1.execute_cmd("/root/netfpga/projects/selftest/sw/selftest -n >> /tmp/result_netfpga1.txt").delete("\n")
    netfpga1.execute_cmd("scp /tmp/result_netfpga1.txt ec:/root").delete("\n")
  netfpga1.property.bit_name
  end


 # configure :result_FTP do |netfpga1, value|
   # info 'Configure(result_FTP) called'
   # netfpga1.execute_cmd("ifconfig >> /tmp/result_netfpga1.txt").delete("\n")
   # netfpga1.execute_cmd("sshpass -p 'whitebox1asgard' scp /tmp/result_netfpga1.txt whitebox-01@#{netfpga1.property.ip_ec}:#{value}).delete("\
  #  value
 # end
  
  configure :iperf do |netfpga1, value|
    info 'Configure(iperf) called'
    netfpga1.execute_cmd("iperf -c 193.168.88.101 -i 1 >> /tmp/return_iperf.txt").delete("\n")
    value
  end

  
  configure :return_iperf do |netfpga1, value|
    info 'Configure(return_iperf) called'
    netfpga1.execute_cmd("sshpass -p 'whitebox1asgard' scp /tmp/return_iperf.txt whitebox-01@#{netfpga1.property.ip_ec}:#{value}").delete("\n")
    value
  end
end
