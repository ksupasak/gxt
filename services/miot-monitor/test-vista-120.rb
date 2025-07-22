require 'socket'

require 'net/http'
require 'json'
require 'timeout'



HOST_NETWORK_BOARDCAST = '192.168.88.255'


boardcast = Thread.new {
  
  # msg_c = "~\x000\x02\x00\x00j\xF9\xE2\a\x04\a\x01\x05\f\x06CMS\x00\x00\x00\x00\x00HOSPITAL\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x0F\x00\x00\x00\x00\x00\x00\x00x\e\xDA\x03\xF0\x17\xDA\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1C%\x00\x00\x00\x00\xC0\xA8d\v\xC0\xA8\x02\x9F\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  # tip = "192.168.2.255"
  # puts "Server Start UDP"
  # socket = UDPSocket.new
  # socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) 
  # 
  # # socket.bind("127.0.0.1", 9610)
  # loop do 
  # socket.send msg_c, 0, tip, 9610
  # 
  # # x = socket.recvfrom(1000)
  # puts "Server UDP send "
  # sleep 1
  # end
  # 
  network_addr = HOST_NETWORK_BOARDCAST
  
  central = UDPSocket.new
  central.bind(network_addr, 9610)
  
   
  
    while(true)

    data =  central.recvfrom(200) 


    ip = data[1][2]

    msg = data[0]
  
   end
}

boardcast.run


# 16
# 0
# 2
# 0
# 0
# 0
# 197
# 174
# 217
# 7
# 8
# 14
# 17
# 54
# 54
# 5
# 
# 16
# 0
# 2
# 0
# 0
# 0
# 213
# 173
# 217
# 7
# 8
# 14
# 17
# 55
# 38
# 5
# 

server = TCPServer.new  9500
  while true

       
        puts 'start accept'
        #       client = server.accept
        Thread.fork(server.accept) do |client|
        
          
        # 
        puts 'start accept 2 '
           puts client
           
            puts client.peeraddr.inspect
            
            cms = TCPSocket.open( "192.168.88.254", 9500 )
            while true
              begin
              request = client.recv(4096)
              puts "REQ #{request.size} #{request}"
              cms.write request
              if request.size == 0 
              client.close
              break 
              end
               # cms.flush
               #               puts 'write....'
               #               cms.flush
               #               puts 'flush'
               # response = cms.recv(4096)
               #                puts "REP #{response.size} #{response}"
               #                
               #                puts response.each_byte.inspect
               #                
               #                puts "======"
               
               client.write token
               client.flush
               cms.close
               
               
            rescue Exception=>e
              puts e
            end
            end
        end
        
end

