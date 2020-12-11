require 'net/http'



require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
# require 'em-http-server'





require_relative 'lib'
require_relative 'conf'
require_relative 'devices/vista-120-v2-gw'
require_relative 'devices/vista-120-v1-gw'
require_relative 'devices/vista-120-S-gw'
require_relative 'devices/vista-120-S-v2-gw'

require_relative 'devices/iacs-m540-gw'
require_relative 'devices/b450-gw'

require_relative 'devices/comen-nc3a-gw'

require_relative 'devices/gps/gps'


unless HOST_IP
HOST_IP = IPSocket.getaddress(Socket.gethostname)
end

t = HOST_IP.split('.')
HOST_NETWORK = t[0..2].join(".")+".1"

unless ARGV[2]
HOST_NETWORK_BOARDCAST = t[0..2].join(".")+".255"
else
HOST_NETWORK_BOARDCAST = ARGV[2]
end

CMS_URI = URI("https://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}")
MIOT::post_config

$global_position = ""

threads = []


ws = MIOT::connect 

#
# threads << Thread.new {
# Device::monitor_b450_v1(ws)
# }

# threads << Thread.new {
# Device::monitor_vista_120_v1(ws)
# }
# 
 # threads << Thread.new {
 # Device::monitor_iacs_m540(ws)
 # }
 
 threads << Thread.new {
 Device::monitor_comen_nc3a(ws)
 }
 

# threads << Thread.new {
# Device::monitor_vista_120_v2(ws)
# }
#
#  
# threads << Thread.new {
# Device::monitor_vista_120_s(ws)
# }
# 
# threads << Thread.new {
# Device::monitor_vista_120_s_v2(ws)
# }
# threads << Thread.new {
# Device::gps_cms_server(ws)
# }
# threads << Thread.new {
# Device::gps_test_server(ws)
# }

for i in threads  
  i.run
end

for i in threads
  i.join
end
