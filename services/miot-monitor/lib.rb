
CMS_IP   = 'gexintec.local'
CMS_PORT = 1792  
CMS_SOLUTION = 'miot'

# Drager Configure
VISTA_120_v1_port = 5510
VISTA_120_v2_port = 9500
VISTA_120_v2_boardcast = 9610

# localhost:1792/miot
# pcm-life.com/miot
# cu.pcm-life.com
# pcm-life.com:1792/miot


if ARGV[0]
  
t = ARGV[0].split('/')

CMS_SOLUTION = t[-1] if t.size > 1  

t2 = t[0].split(":")

port = t2[-1] if t2.size > 1 

CMS_HOST = t2[0]

t3 = CMS_HOST.split(".")

CMS_SOLUTION = t3[0] if t3.size > 2

CMS_PATH = "ws/#{CMS_SOLUTION}/Home/index"

CMS_HOST_PORT = "#{CMS_HOST}#{':'+port if port}"

CMS_URI = "wss://#{CMS_HOST_PORT}/#{CMS_PATH}"

  
# path1 = ARGV[0].split("/")
# path  = path1[0].split(':')
# CMS_IP  = path[0]
# CMS_PORT = path[1]
# CMS_SOLUTION = path1[1]
end

# CMS_PATH = "ws/#{CMS_SOLUTION}/Home/index"
# CMS_URI = URI("https://#{CMS_IP}/ws/#{CMS_PATH}")

module MIOT

def self.connect 
  
  connect_url = CMS_URI #"wss://#{CMS_IP}/ws/#{CMS_PATH}"
  puts connect_url
  loop do 
  begin
    
    ssl_context = OpenSSL::SSL::SSLContext.new
    ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE  # ⚠️ Not safe for production
    ssl_context.min_version =  OpenSSL::SSL::TLS1_2_VERSION
    return   WebSocket::Client::Simple.connect connect_url, ssl: ssl_context
  
  rescue Exception => e
    sleep 5
      
    puts "Reconnect in 5 seconds #{e.inspect}"
    
  end
  
end
  
  
end


def self.post_config   
  
  puts "========================= MIOT Configure ======================="
  puts "CMS IP #{CMS_URI}"
  puts "CMS PATH #{CMS_PATH}"
  puts "IP #{HOST_IP}"
  puts "GW #{HOST_NETWORK}"
  puts "BOARDCAST #{HOST_NETWORK_BOARDCAST}"

  
end


end
