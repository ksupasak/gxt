# require 'socket'               # Get sockets from stdlib
#
# server = TCPServer.open(2000)  # Socket to listen on port 2000
# loop {                         # Servers run forever
#   client = server.accept       # Wait for a client to connect
#   method, path = client.gets.split                    # In this case, method = "POST" and path = "/"
#   headers = {}
#   while line = client.gets.split(' ', 2)              # Collect HTTP headers
#     break if line[0] == ""                            # Blank line means no more headers
#     headers[line[0].chop] = line[1].strip             # Hash headers by type
#     # puts line
#   end
#   data = client.read(headers["Content-Length"].to_i)  # Read the POST data as specified in the header
#
#   puts data                                           # Do what you want with the POST data
#
#   client.puts(Time.now.ctime)  # Send the time to the client
#   client.puts "Closing the connection. Bye!"
#   client.close                 # Disconnect from the client
# }


require 'socket'        # Sockets are in standard library

hostname = '192.168.1.202'
port = 9002

msg = <<MSG
\vMSH|^~\\&|NealTime Wave Test Client|HIS Send TEST|NealTime Wave Data Server|RCV TEST|20160331113440||OML^O21^OML_O21|20160331113440|P|2.4|||NE|AL||ASCII||\rPID|||111|||||\rORC|RE\rTQ1|1|||||||\rOBR|1|||WAVE^ECGI^ECGII^ECGIII^ECGaVR^ECGaVL^ECGaVF^ECGV1^ECGV2^ECGV3^ECGV4^ECGV5^ECGV6^RESP^RESPIMP^SPO2IRAC^SPO2IRACIRDC^ART1^ART2^CO2^CVP^PAP|||20201102095020|20201102095040|||||||||||||||||A\r\u001C\r
MSG

puts msg.size

s = TCPSocket.open(hostname, port)
puts 'connect'
s.puts msg
s.puts 

puts 'sent'

# content =  s.read
# puts content
#
#
# out = File.open('out.txt','w')
# out.write content
# out.close

lines = s.readlines
puts 'read'

for i in lines 
  t = i.split("|")
  for j in t
    
    k = j.split("^")
    
  if k[0] == 'HL7Gateway'
    
    puts k.inspect 
    
    
    content = k[4]
    
    out = File.open('out.mwf','w')
    out.write Base64.decode64(content)
    out.close
    
  end
  
end
end




#
# while line = s.gets     # Read lines from the socket
#    puts line.chop       # And print with platform line terminator
# end
s.close                 # Close the socket when done