

require 'net/http'


require 'socket'

s = TCPSocket.new 'localhost', 8081
s.puts "Hello world"
puts s.gets
s.puts "/quit/i"

# while line = s.gets # Read lines from socket
#   puts line         # and print them
# end

s.close