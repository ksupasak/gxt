

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


CMS_IP   = 'gexintec.local'
CMS_PORT = 1792  
CMS_SOLUTION = 'miot'

# Drager Configure
VISTA_120_v1_port = 5510
VISTA_120_v2_port = 9500
VISTA_120_v2_boardcast = 9610


if ARGV[0]
path1 = ARGV[0].split("/")
path  = path1[0].split(':')
CMS_IP  = path[0]
CMS_PORT = path[1]
CMS_SOLUTION = path1[1]
end

CMS_PATH = "#{CMS_SOLUTION}/Home/index"
CMS_URI = URI("https://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}")

module MIOT

def self.connect 
  
  connect_url = "wss://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}"
  puts connect_url
  loop do 
  begin
    
    return   WebSocket::Client::Simple.connect connect_url
  
  rescue Exception => e
    sleep 5
      
    puts "Reconnect in 5 seconds #{e.inspect}"
    
  end
  
end
  
  
end


def self.post_config   
  
  puts "========================= MIOT Configure ======================="
  puts "CMS IP #{CMS_IP}"
  puts "CMS PORT #{CMS_PORT}"
  puts "CMS URI #{CMS_URI}"
  puts "IP #{HOST_IP}"
  puts "GW #{HOST_NETWORK}"
  puts "BOARDCAST #{HOST_NETWORK_BOARDCAST}"

  
end


end
