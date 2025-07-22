require 'socket'


while true
  
begin   

s = TCPSocket.new 'localhost', 5001

content = File.open("1.octet-stream").read

puts 'start sim hl7'



while true# Read lines from socket


  t = s.write content
  s.flush
  
  puts 'send '+t.to_s
  
  sleep 5


end

 rescue Exception => e
  
   sleep 3
   puts e.message
    puts e.backtrace
   puts 'reconnect...'
   
 end


end
