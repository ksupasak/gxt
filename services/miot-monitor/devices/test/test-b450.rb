




require 'socket'
s = UDPSocket.open
s.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)

s.bind('', 7000)
20.times do 


  text, sender = s.recvfrom(10000)
  puts sender.inspect 
  puts text.inspect
  puts 
  
end
