require 'net/http'
require_relative 'conf'
require_relative 'devices/vista-120-gw'
require_relative 'devices/vista-120-v1-gw'
require_relative 'devices/b450-gw'


puts HOST_IP

threads = []


threads << Thread.new {
Device::monitor_vista_120_v1()
}


threads << Thread.new {
Device::monitor_b450_v1()
}


threads << Thread.new {
Device::monitor_vista_120_v2()
}


for i in threads
  
  i.run
  
end

for i in threads
  i.join
end
