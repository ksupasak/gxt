require 'socket'







# Raspberry PI GW Monitor Devices
# HOST_IP = '192.168.1.51'
# HOST_NETWORK = '192.168.1.1'
# HOST_NETWORK_BOARDCAST = '192.168.1.255'

# test 120S
# HOST_IP = '192.168.88.253'
# HOST_NETWORK = '192.168.88.1'
# HOST_NETWORK_BOARDCAST = '192.168.88.255'


# HOST_IP = 'localhost'

host_ip = ARGV[1]

unless host_ip
  list = Socket.ip_address_list.select{|i| i.ipv4?}.collect(&:ip_address)
  host_ip = list[1] #IPSocket.getaddress(Socket.gethostname)
end
HOST_IP = host_ip

 puts HOST_IP

 
 
  

# HIS Data GW
GW_HIS_IP = 'his.gw'
GW_HIS_PORT = 9292
