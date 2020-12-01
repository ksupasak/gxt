# tcp_server.rb
require 'socket'
server = TCPServer.new 80
puts 'Start Server ...'
while session = server.accept
  
  
  while line = session.gets # Read lines from socket
    puts line  
           # and print them
      break    
  end
    
  session.close
  
end