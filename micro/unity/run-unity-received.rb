require 'socket'

mip = '126.1.138.201'

tip = "172.16.255.255"
mip = "192.168.253.255"

u1 = UDPSocket.new
# UDPSock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
# u1.bind("172.16.255.255", 7000)
u1.bind(mip, 7000)

unity = "\x01\x04\x00\x00\xC0\xA8\xFDd\x00\x00\x03\xDEICU|BED6+\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\t\x00(\a\xD0\x00\f\a\xD0\x00\r\a\xD0\x00\x11\x00\xA0\x00\x1F\x06\x00\x00\x0E\a\xD0\x00*\x00\x04\x00\x1D\x1DL\x00\x1C\v\xBA\x00\x00\x00\x00\x00\x00\x00\x00"


u2 = UDPSocket.new
u2.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
u2.connect(tip,7000)

while(true)
  
data =  u1.recvfrom(100) #=> ["message-to", ["AF_INET", 4913, "localhost", "127.0.0.1"]]
puts data.inspect
l = []
ip = data[1][2]

puts "ip = " +ip
# if ip == '126.1.138.200'
msg = data[0]
msg.gsub!('BED01','BED02')
u2.send data[0], 0
# sleep 5

# end




# 
# data.size.times do |i|
#   l << data[i].ord  
# end
#  puts l.inspect 
#  


end
# 
# 1 4 0 0 126 1 138 193 0 0 0 0 73 67 85 124 67 73 67 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 9 0 2 7 208 0 50 5 1 0 23 4 7 0 7 4 10 0 6 31 70 0 33 4 11 0 27 4 12 0 34 7 208 0 9 7 208 0 0 0 0 0 0 0 0


# require 'socket'
# addr = ['<broadcast>', 33333]# broadcast address
# #addr = ('255.255.255.255', 33333) # broadcast address explicitly [might not work ?]
# #addr = ['127.0.0.255', 33333] # ??
# UDPSock = UDPSocket.new
# UDPSock.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
# data = 'I sent this'
# UDPSock.send(data, 0, addr[0], addr[1])
# UDPSock.close