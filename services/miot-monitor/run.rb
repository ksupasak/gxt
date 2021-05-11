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
require_relative 'devices/ids-combo-gw'
require_relative 'devices/gps/gps'

require_relative 'devices/nihon_defib_gw'



unless HOST_IP
HOST_IP = IPSocket.getaddress(Socket.gethostname)
end

t = HOST_IP.split('.')
HOST_NETWORK = t[0..2].join(".")+".1"

unless ARGV[3]
HOST_NETWORK_BOARDCAST = t[0..2].join(".")+".255"
else
HOST_NETWORK_BOARDCAST = ARGV[3]
end

select_monitor = ARGV[2]


CMS_URI = URI("https://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}")
MIOT::post_config

$global_position = ""

threads = []
puts ARGV.inspect 

ws = MIOT::connect 

#
# threads << Thread.new {
# Device::monitor_b450_v1(ws)
# }

# threads << Thread.new {
# Device::monitor_vista_120_v1(ws)
# }
# 


unless select_monitor
 threads << Thread.new {
 Device::monitor_iacs_m540(ws)
 }
end

if select_monitor=='nc3a'
  puts 'monitor select = nc3a'
 threads << Thread.new {
 Device::monitor_comen_nc3a(ws)
 }
end

if select_monitor=='ids_serial'
  puts 'monitor select = ids_serial'
 threads << Thread.new {
 Device::monitor_ids_combo(ws)
 }
end


if select_monitor=='nihon_defib'
  puts 'monitor select = nihon_defib'
 threads << Thread.new {
 Device::defib_nihon(ws)
 }
end


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
