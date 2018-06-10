require 'socket'
require 'net/http'
require 'json'

module Device



def self.monitor_vista_120_v1

puts "-- Start Vista120 v2 Service"

# boardcast = Thread.new {
#   
#   msg_c = "~\x000\x02\x00\x00j\xF9\xE2\a\x04\a\x01\x05\f\x06CMS\x00\x00\x00\x00\x00HOSPITAL\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x0F\x00\x00\x00\x00\x00\x00\x00x\e\xDA\x03\xF0\x17\xDA\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1C%\x00\x00\x00\x00\xC0\xA8d\v\xC0\xA8\x02\x9F\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
#   tip = HOST_NETWORK_BOARDCAST
#   puts "Server Start UDP for Vista 120"
#   socket = UDPSocket.new
#   socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) 
#   
#   loop do 
#   socket.send msg_c, 0, tip, 9610
#   # puts "Server UDP send "
#   sleep 1
#   end
#   
# }
# 
# boardcast.run



# puts "Server Start"



server = TCPServer.new  VISTA_120_v1_port


host = GW_IP
port = GW_PORT
uri = GW_URI


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
        bp_stamp = ''
        check_stamp = nil
        
        while true
        line = client.recv(40960)
        
        # puts "#{line.size} #{'='*30}"
        
        # puts '====================================================='+line.size.to_s
               # puts line
        # puts
        index = 0 
        
        
        l = line.each_byte.to_a.collect{|i| i.to_i}  
        # l.each_with_index do |i,id| 
        #                if i=='119'
        #                  puts "xx #{l.size} #{i}\t#{id}"
        #                end
        #              end
        # puts l.join("\t")
      
        # puts l.join("\t") if l.size==258 or l.size==1448
        
        # left = line.size
        
        type = line.size
        
        res = nil
        # puts " Type : #{type} index : #{index}"
        
     # 48.51.58.67.76.95.104.112.118.126.133.139.145.147.147.142.140.136.133.130.129.127.127.127.127.127.127.127.127.127.127.127.127.127.127.127.127.127.127.127.126.126.125.125.124.123.122.121.120.119.28.0.53.18.12.0.88.0.115.0.77.0.110.0.60.0.2.0.160.0.90.0.2.0.90.0.50.0.2.0.20.1.53.18.13.0.19.19.18.18.18.18.17.17.17.17.17.16.16.16.15.15.15.15.14.14.14.13.13.13.13.13.12.12.12.12.11.10.10.9.9.9.9.9.9.9.9.8.8.8.8.8.8.8.8.7.7.7.7.7.7.7.7.7.7.7.7.7.7.7.8.8.8.8.8.9.9.9.10.10.10.10.11.12.13.14.15.16.17.18.19.20.21.22.23.24.25.28.29.31.33.35.36.37.39.40.42.46.48.50.52.54.56.58.59.60.62.65.66.68.70
        if type==252 or type==242
           puts line
           hn = line[55..70].strip
           puts "#{hn} #{hn.size}"
        end    
        if type==1448
          
              # puts l[-10..-1]
              sys = l[1158]
              dia = l[1160]
              
              
              bp = "#{sys}/#{dia}"

              data = {}

              data[:hr] = l[646]

              data[:rr] = l[648]
              data[:so2] = l[-6]
              data[:pr] = l[646]
              data[:bp] = bp
              
              
              
             new_check_stamp = "#{bp}-#{data[:pr]}"
             
             if check_stamp!=new_check_stamp
               now = Time.now 
               bp_stamp  = format("%02d%02d%02d", now.hour, now.min, now.sec)
               
               check_stamp = new_check_stamp
             end
              
              
              data[:bp_stamp] = bp_stamp

              ref = hn
              bed = station
              name = bed
              stamp = Time.now.to_json
              
              
                          
              puts "#{stamp}\t#{station}\t#{data.inspect}\t#{hn}"            
              begin            
              result = Net::HTTP.post_form(uri, 'ip'=>client.peeraddr[-1],'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)
              rescue Exception=>e
              puts e.message
              end
                      
                              
              
              #     
              #   
              #     
              # 
              #   end
              # 
              #   else
              # 
              #   end
              #   index+=read
              #   
              # end
              # 
              # if index==buff.size
              #   index = 0 
              #   buff=[]
              # end
              #       
        
        end
        
      end
      
    rescue Exception=>e
      puts e
      
    end
      
    end
        
        puts 'next'    
 
end


end

end

  # so2 = res[106]/2
  #          
  #          high = "#{res[124]/2}"
  #          high = "#{res[124]+128}" if res[125]==67
  #          
  #          
  #          bp = "#{high}/#{res[130]/2}"
  #          
  #          
  #          bp_hr = res[136]/2
  #          # pr = res[142]/2
  #          pr = res[118]/2
  #          
  #                     #       
  #                     # puts line
  #                     #           puts
  #                     #           
  #                     #              res.each_with_index do |i,ix|
  #                     #           
  #                     #                print "#{ix}\t" if ix%10==0 
  #                     #                print "#{i.to_i.to_s}\t"
  #                     #                puts if ix%10==9 and ix!=0
  #                     #           
  #                     #              end
  #                     #           
  #                     #              puts
  #          
  #          new_check_stamp = "#{bp}-#{bp_hr}"
  #          
  #          if check_stamp!=new_check_stamp
  #            now = Time.now 
  #            bp_stamp  = format("%02d%02d%02d", now.hour, now.min, now.sec)
  #            check_stamp = new_check_stamp
  #          end
  #          
  #          
  #          # puts "HN #{hn}"
  #          # puts "NIBP #{bp}"
  #          # puts "SO2 #{so2}"
  #          # puts "PR #{pr}"
  #          # 
  #                   if bp=='61/61' 
  #                      bp= '-/-'
  #                      # pr= 0
  #                      # bp_stamp = nil
  #                      # so2 = 0
  # 
  #                    end