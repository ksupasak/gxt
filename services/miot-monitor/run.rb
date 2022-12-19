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
require_relative 'devices/xovic_hl7_gw'

require_relative 'devices/unity'




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


# threads << Thread.new {
# Device::monitor_b450_v1(ws)
# }

# threads << Thread.new {
# Device::monitor_vista_120_v1(ws)
# }
#
# sleep 1
# # puts 'send'
# #
# ws.send("WS.Select name=local\n[\"Monitor.StartBP device_id=*\"]")
# #
#  ws.on :message do |msg|
#
#    puts msg.data
#
#  end
# #
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


if select_monitor=='carescape'
  puts 'monitor select = carescape'
 threads << Thread.new {
 # Device::monitor_comen_nc3a(ws)
 Device::monitor_b450_v1(ws)
 }
end

if select_monitor=='nc3a_live'
  puts 'monitor select = nc3a live'
 threads << Thread.new {
 Device::monitor_comen_nc3a_live(ws)
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


if select_monitor=='xovic_hl7'
  puts 'monitor select = xovic_hl7'
 threads << Thread.new {
 Device::monitor_xovic_hl7_live(ws)
 }
end


if select_monitor=='unity'
  puts 'monitor select = unity'
 threads << Thread.new {
 Device::monitor_unity(ws)
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

#
for i in threads
  i.join
end
