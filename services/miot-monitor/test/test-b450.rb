require 'socket'
require 'timeout'
network_addr = "172.16.255.255" # HOST_NETWORK_BOARDCAST

threads = []

discovery_msg = "\x01\x04\x00\x00\xAC\x10W*_\x0F\x04jX|E4CC0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\a\x00\x01\a\xD0\x00\x1F\x02\x00\x00\x11\x02 \x00\x13\a\xD0\x00\f\a\xD0\x00\r\a\xD0\x00\x1C\a\xD0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\xCA\x00)\x00\x06\x00\x00\x00\x00\x00\x00ICU|B288A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
msg_c = "\x00\x00\x00\x00\x00\x00\xAC\x10W+\x00\x00\x00\xC9\x00\x01\x00\x00\x00\x00\x00\x01\x00\x00X|CSCS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x04\xE2\xB9\x85\x8B"

msg_monitor = "\x01\x04\x00\x00\xAC\x10W*_\x0F\vXX|E4CC0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\a\x00\x01\a\xD0\x00\x1F\x02\x00\x00\x11\x02 \x00\x13\a\xD0\x00\f\a\xD0\x00\r\a\xD0\x00\x1C\a\xD0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"

activation_monitor = "\x00\x00\x00\x00\x00\x00\xAC\x10W+\x00\x00\x00\xCA\x00\"\x00\x00\x00\x00\x00\x00\x00\x00X|CSCS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
gw_ip = "172.15.87.39"
gw_monitor_ip =  "172.16.87.39"
server_ip = "172.15.87.43"
monitor_ip = "172.16.87.42"
server_network = "172.15.255.255" # HOST_NETWORK_BOARDCAST

monitor_network = "172.16.255.255"
#. get board case from monitor sent central

threads << Thread.new do

monitor_boardcast = UDPSocket.new
monitor_boardcast.bind(monitor_network, 7000)
server_boardcast = UDPSocket.new
server_boardcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

while(true)

data =  monitor_boardcast.recvfrom(200)
if data[1][2] != "172.16.87.39"
# puts 'recieve from monitor 7000'
# puts data.inspect
tx = data[0].bytes
tx[5] = 15
tx[7] = 39
tx = tx.collect{|i| i.chr}.join
# puts tx.bytes.join(", ")

# u2.send msg_c, 0, tip,2000

server_boardcast.send tx, 0, server_network, 7000
# puts 'send to central'
# puts
# puts
end
end
end



threads << Thread.new do

server_boardcast = UDPSocket.new
server_boardcast.bind(server_network, 7000)
monitor_boardcast = UDPSocket.new
monitor_boardcast.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

while(true)

data =  server_boardcast.recvfrom(200)
# puts 'recieve from central boardcast 7000'
# puts data.inspect

tx = data[0].bytes
tx[5] = 16
tx[7] = 39
tx = tx.collect{|i| i.chr}.join
# puts tx.bytes.join(", ")

# u2.send msg_c, 0, tip,2000

monitor_boardcast.send tx, 0, monitor_network, 7000
# puts 'send to monitor boardcast'
# puts
# puts
end

end


monitor_channel = UDPSocket.new

server_channel = UDPSocket.new
server_channel.bind(gw_ip, 2000)



threads << Thread.new do



# monitor_channel.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)


while(true)

data =  server_channel.recvfrom(200)
# puts 'recieve from central 2000'
# puts data.inspect
# puts data[0].bytes.join(", ")

tx = data[0].bytes
tx[7] = 16
tx[9] = 39
tx = tx.collect{|i| i.chr}.join
# puts tx.bytes.join(", ")
# u2.send msg_c, 0, tip,2000

monitor_channel.send tx, 0, monitor_ip, 2000
# puts 'send to monitor'
# puts
# puts


data =  server_channel.recvfrom(200)
# puts 'recieve from central 2000'
# puts data.inspect
#
# puts data[0].bytes.join(", ")
# u2.send msg_c, 0, tip,2000
tx = data[0].bytes
tx[7] = 16
tx[9] = 39
tx = tx.collect{|i| i.chr}.join
# puts tx.bytes.join(", ")

monitor_channel.send tx, 0, monitor_ip, 2000
# puts 'send to monitor'
# puts
# puts



end

end



threads << Thread.new do

# monitor_channel = UDPSocket.new
# monitor_channel.bind(gw_monitor_ip, 2011)

# server_channel = UDPSocket.new
# monitor_channel.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)


while(true)

data =  monitor_channel.recvfrom(2048)
# puts 'recieve from monitor 2011'
# puts data.inspect
# puts data[0].bytes.join(", ")

tx = data[0]

if data[1][1]==2007
tx = data[0].bytes
tx[1] = 15
tx[3] = 39

spo2 = tx[207].ord
pr = tx[209].ord
sys = tx[141].ord
dia = tx[143].ord
hour = tx[150].ord
min = tx[149].ord

puts "SPO2 = #{spo2}"
puts "PR = #{pr}"
puts "SYS = #{sys}"
puts "DIA = #{dia}"
puts "HH = #{hour}"
puts "MM = #{min}"
puts

tx = tx.collect{|i| i.chr}.join
# puts tx.bytes.join(", ")
end

server_channel.send tx, 0, server_ip, 2011
# puts 'send to monitor'
# puts



end

end




#
# threads << Thread.new do
#
#
# socket = UDPSocket.new
# tip = "172.16.87.42"
# # socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
#
#
#
# #
# # central = UDPSocket.new
# # central.bind("172.16.87.39", 2000)
#
# now = Time.now
#
# while(true)
# # puts 'got resend'
# #
# # data =  central.recvfrom(200)
# # puts data.inspect
#
# # u2.send msg_c, 0, tip,2000
# puts 'resend active'
#
# socket.send activation_monitor, 0, tip, 2000
#
#  sleep(2)
#
# end
#
# end
#




#===============================================================================================


# threads << Thread.new do
#
#
# socket = UDPSocket.new
# tip = "172.16.87.42"
# socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
#
# now = Time.now
#
# while(true)
#
# # data =  central.recvfrom(200)
# # puts data.inspect
#
# # u2.send msg_c, 0, tip,2000
# puts 'send'
#
# socket.send msg_monitor, 0, network_addr, 7000
#
#  sleep(2)
#
# end
#
# end

#===============================================================================================

# threads << Thread.new do
#
#
# socket = UDPSocket.new
# tip = "172.16.87.42"
# # socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
#
#
#
#
# central = UDPSocket.new
# central.bind("172.16.87.39", 2000)
#
# now = Time.now
#
# while(true)
# puts 'got resend'
#
# data =  central.recvfrom(200)
# puts "data1 "+data.inspect
#
# # socket.send msg_c, 0, tip,2000
# # puts 'resend 1'
#
# data =  central.recvfrom(200)
# puts "data2 "+data.inspect
#
# # socket.send msg_c, 0, tip,2000
# # puts 'resend 2'
#
#
#
# # socket.send data[0], 0, tip, 2000
#
# # data =  socket.recvfrom(200)
# # puts "xxx vv "+data.inspect
# # puts 'xxxx'
#  sleep(2)
#
# end
#
# end

#===============================================================================================

#
# threads << Thread.new do
# socket = UDPSocket.new
# central = UDPSocket.new
# central.bind(network_addr, 7000)
#
# now = Time.now
#
# while(true)
#
# data =  central.recvfrom(200)
# puts data.inspect
#
# if data[1][2] == "172.16.87.42"
#
# m1 = "\x00\x00\x00\x00\x00\x00\xAC\x10W+\x00\x00\x00\xCA\x00!\x00\x00\x00\x00\x00\x00\x00\x00X|CSCS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
# m2 = "\x00\x00\x00\x00\x00\x00\xAC\x10W+\x00\x00\x00\xCA\x00\"\x00\x00\x00\x00\x00\x00\x00\x00X|CSCS\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
#
# socket.send m1, 0, tip, 2000
# sleep 1
# socket.send m2, 0, tip, 2000
#
#
# end
#
# end
#
# end

threads.each do |t| t.join

end