require 'socket'
require 'timeout'

module Device
  
  
def self.monitor_b450_v1()

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
network_addr = "202.114.4.255"
network_addr = "192.168.2.255"
network_addr = HOST_NETWORK_BOARDCAST


# host = "192.168.1.146"

host = GW_IP
port = GW_PORT


host = ARGV[0] if ARGV[0]
network_addr = ARGV[1] if ARGV[1]

@config = {:network=>network_addr, :gw=>true, :host=>host, :port=>port}


# looking for all monitor
require 'socket'

monitors = {}


threads = []

# Thread 0 : for checking monitor status  ====================

threads << Thread.new do 

central = UDPSocket.new
central.bind(network_addr, 7000)

now = Time.now 

while(true)
  
data =  central.recvfrom(100) 


ip = data[1][2]

msg = data[0]
bed_name = msg[12..27].to_s
patient_name = msg[28..42].to_s

n = Time.now

name = "#{bed_name.strip.split("|").join("-")}"

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


