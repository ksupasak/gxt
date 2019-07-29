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

unless HOST_IP
HOST_IP = IPSocket.getaddress(Socket.gethostname)
end

t = HOST_IP.split('.')
HOST_NETWORK = t[0..2].join(".")+".1"
HOST_NETWORK_BOARDCAST = t[0..2].join(".")+".255"
 
CMS_URI = URI("http://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}")
MIOT::post_config



threads = []


ws = MIOT::connect 


# threads << Thread.new {
# Device::monitor_b450_v1(ws)
# }

# threads << Thread.new {
# Device::monitor_vista_120_v1(ws)
# }
# 
threads << Thread.new {
Device::monitor_iacs_m540(ws)
}
# 
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


for i in threads
  
  i.run
  
end

for i in threads
  i.join
end
