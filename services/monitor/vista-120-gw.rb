require 'socket'

require 'net/http'
require 'json'





boardcast = Thread.new {
  
  msg_c = "~\x000\x02\x00\x00j\xF9\xE2\a\x04\a\x01\x05\f\x06CMS\x00\x00\x00\x00\x00HOSPITAL\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x0F\x00\x00\x00\x00\x00\x00\x00x\e\xDA\x03\xF0\x17\xDA\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1C%\x00\x00\x00\x00\xC0\xA8d\v\xC0\xA8\x02\x9F\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  tip = "192.168.2.255"
  puts "Server Start UDP"
  socket = UDPSocket.new
  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) 
  
  # socket.bind("127.0.0.1", 9610)
  loop do 
  socket.send msg_c, 0, tip, 9610
  
  # x = socket.recvfrom(1000)
  # puts "Server UDP send "
  sleep 1
  end
  
}

boardcast.run



# rboardcast = Thread.new {
# server = TCPServer.new  9500
# 
#  Thread.fork(server.accept) do |client|
#   puts "Server Start rTCP"
#  while true
#   line = client.recv(40960)
#   puts line.inspect 
#  end
# 
# end
# }
# rboardcast.run




puts "Server Start"



server = TCPServer.new  9500

# host = 'gexintec.com'
host = '127.0.0.1'
port = 1792


  uri = URI("http://#{host}:#{port}/monitor/Sense/sense")

# sim = TCPSocket.new '191.1.1.101', 2250


list = [{:n1=>6},
        {:n2=>256},
        {:n3=>256},
        {:n4=>128},
        {:n5=>248},
        {:n6=>256},
        {:n7=>36},
        {:n8=>256},
        {:n9=>6},
        ]

        hn = '-'
        
loop do 
        # puts 'start accept'
        #       client = server.accept
        
        
        
        Thread.fork(server.accept) do |client|
        # hn = '-'
        puts 'start accept'
        
        
        begin
        #               client = server.accept
        
        puts client
        puts client.peeraddr.inspect 
        
        station = "BED"+format("%02d",client.peeraddr[-1].split(".")[-1])
        
        puts 'start accepted'
        # puts client.methods.sort 
        
        buff = []
        index = 0 
        left = nil
        
            hn = ''
            so2 = 0
            bp = ''
            bp_hr = 0
            pr = 0 
        
        
        while true
        line = client.recv(40960)
        
        #puts "#{line.size} #{'='*30}"
        
        # puts '====================================================='+line.size.to_s
        #puts line
        # puts
        buff+= line.each_byte.to_a
        
        
        l = line.each_byte.to_a.collect{|i| i.to_i.to_s}  
        # l.each_with_index do |i,id| 
        #       if i=='119'
        #         puts "xx #{l.size} #{i}\t#{id}"
        #       end
        #     end
        
        # puts l.join("\t") if l.size==258 or l.size==1448
        
        # left = line.size
        
          if left
            buff = buff[left..-1]
            left = nil
          end
        
    
        while index<buff.size
          res = nil
          type = buff[index]
          
          case type
          when 20 
          
          read = 20 + 256
          
          #puts "Found Peak 255" 
          
          else
          if type != 0
          read = type
          #puts "Found #{read} #{'msg'}" 
          
          end
          end
          
          if index+read <= buff.size
          
          res = buff[index..index+read]
          if type==176 or type==162
            
            
            if type==176
              s = ''
              for i in res[40..60]
                break if i==0
                s+=i.chr 
              end
              hn = s.strip
              puts "HN #{hn} new"
              
            end
               # puts line
                # puts
                # 
                #    res.each_with_index do |i,ix|
                # 
                #      print "#{ix}\t" if ix%10==0 
                #      print "#{i.to_i.to_s}\t"
                #      puts if ix%10==9 and ix!=0
                # 
                #    end
                # 
                #    puts
            
            if type==162
              
              so2 = res[106]/2
              bp = "#{res[124]/2}/#{res[130]/2}"
              bp_hr = res[136]/2
              pr = res[142]/2
              
              # puts "HN #{hn}"
              # puts "NIBP #{bp}"
              # puts "SO2 #{so2}"
              # puts "PR #{pr}"
              # 
              
              data = {}
              
              data[:hr] = pr
              data[:rr] = 20
              data[:so2] = so2
              data[:pr] = pr
              data[:bp] = bp

              ref = hn
              bed = station
              name = bed
              stamp = Time.now.to_json
                          
              puts "#{stamp}\t#{station}\t#{data.inspect}"            
              begin            
                result = Net::HTTP.post_form(uri, 'ip'=>client.peeraddr[-1],'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)
              rescue Exception=>e
                puts e.message
              end
            end
            
          
            

          end
        
          else

          end
          index+=read
          
        end
        
        if index==buff.size
          index = 0 
          buff=[]
        end
      
        
      end
      
    rescue Exception=>e
      puts e
      
    end
      
    end
        
        puts 'next'    
 
end
