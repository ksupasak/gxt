require 'socket'
require 'timeout'

module Device
  
  
def self.monitor_b450_v1(ws)

puts "-- Start B450 Service"
# Services 
# username biomed
# password Change Me
# Tab Configure > Network 
# Wired Interfaces
# MC Network
# Static Ip : 126.1.138.200 -> monitor
# Netmask : 255.255.0.0
# Save


require_relative 'lib'

# network address
# network_addr = "202.114.4.255"
# network_addr = "192.168.2.255"
network_addr = "172.16.255.255" # HOST_NETWORK_BOARDCAST
network_addr = "192.168.1.255" # HOST_NETWORK_BOARDCAST

 
# host = "192.168.1.146"

host = CMS_IP
port = CMS_PORT


host = ARGV[0] if ARGV[0]
network_addr = ARGV[1] if ARGV[1]


@config = {:network=>HOST_NETWORK_BOARDCAST, :gw=>true, :host=>host, :port=>port}


# looking for all monitor
require 'socket'

monitors = {}


threads = []

# Thread 0 : for checking monitor status  ====================


threads << Thread.new do 

monitor_boardcast = UDPSocket.new
monitor_boardcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

now = Time.now 

while(true)

# msg = "\x01\x04\x00\x00\xC0\xA8\x01\nb\n@{OT|BED3\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x01\a\xD0\x00\x1F\x05\x00\x00\x11\x02\"\x00\x13\a\xD0\x00\f\a\xD0\x00\r\a\xD0\x00\x1C\a\xD0\x00\x0E\a\xD0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

msg = "\x01\x04\x00\x00\xAC\x0FW+_\x11\xB2\x81X|CSCS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\a\x00\x02\a\xD0\x002\a\x01\x00\x17\x04\x01\x00\a\x04\x04\x00!\x04\x05\x00\"\a\xD0\x00\t\a\xD0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

tx = msg.bytes
tx[5] = 16
tx[7] = 39
tx = tx.collect{|i| i.chr}.join


monitor_boardcast.send tx, 0, HOST_NETWORK_BOARDCAST, 7000
puts 'ack'


sleep 5

end

end


threads << Thread.new do 

central = UDPSocket.new
central.bind(HOST_NETWORK_BOARDCAST, 7000)

now = Time.now 

while(true)
  
data =  central.recvfrom(100) 

# puts data.inspect 

ip = data[1][2]

if ip != HOST_IP

msg = data[0]
bed_name = msg[12..27].to_s
patient_name = msg[28..42].to_s

n = Time.now

name = "#{bed_name.strip.split("|").join("-")}"
puts name
if monitors[ip] 

puts "#{n - now} Monitor #{name} at #{ip} alive."
monitors[ip][:update]=n
if monitors[ip][:vital].status == nil
  monitors[ip][:vital] = get_vital_sign(ip, name) 
end


else
  
puts "#{n - now} Monitor #{name} at #{ip} register."
t = get_vital_sign(ip,name) 
monitors[ip] = {:name => name, :ip=> ip, :update=>n, :vital=>t}


# threads << t
  
end

end


end



end


# Thread 1 : for checking monitor leave  ====================

threads << Thread.new do 
now = Time.now 
while(true)
  
  n = Time.now
  begin
  monitors.each_pair do |ip,i| 
      if n - i[:update] > 20
        name = i[:name]
        puts "#{n - i[:update]} Monitor #{name} at #{ip} has left."
        i[:vital].exit
        monitors.delete ip
      end
  end
rescue Exception=>e
  puts e.inspect 
  puts e.backtrace.join("\n") 
end
  # puts "check.."
  sleep(1)

end

 puts "Finish"
end

# while threads.size==0
  
threads.each { |thr| thr.join }


# end

end

end


