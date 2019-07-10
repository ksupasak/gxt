require 'socket'
s = UDPSocket.open
s.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

s.bind('', 9610)
20.times do 


  text, sender = s.recvfrom(10000)
  puts sender.inspect 
  puts text.inspect
  puts 
  
end