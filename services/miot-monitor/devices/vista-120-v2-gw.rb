require 'socket'
require 'net/http'
require 'json'

module Device



def self.monitor_vista_120_v2 ws

puts "-- Start Vista120 v2 Service"

boardcast = Thread.new {
  
  msg_c = "~\x000\x02\x00\x00j\xF9\xE2\a\x04\a\x01\x05\f\x06CMS\x00\x00\x00\x00\x00HOSPITAL\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x00\x00\x0F\x00\x00\x00\x00\x00\x00\x00x\e\xDA\x03\xF0\x17\xDA\x03\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x1C%\x00\x00\x00\x00\xC0\xA8d\v\xC0\xA8\x02\x9F\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  tip = HOST_NETWORK_BOARDCAST
  puts "Server Start UDP for Vista 120"
  socket = UDPSocket.new
  socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true) 
  
  loop do 
  socket.send msg_c, 0, tip, 9610
  # puts "Server UDP send "
  sleep 1
  end
  
}

boardcast.run



# puts "Server Start"



server = TCPServer.new  VISTA_120_v2_port


#host = GW_IP

#port = GW_PORT
#uri = GW_URI


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

        #hn = '-'
      
    
  
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
        
         token = "\x10\x00\x02\x00\x00\x00\xD5\xA9\xD9\a\b\x0E\x11;&\x05"
           client.write token
           client.flush

        
        
        
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
        
	last = Time.now 
  
  map = {}

	n = 5
	monitor = false
	new_bp_stamp = ''
        line = "-"
        while line.size!=0
       
        
       line = client.recv(40960)
       if station == 'BED12'
         
        # puts "#{line.size} #{'='*30} #{station}"
        
        # puts '====================================================='+line.size.to_s
        #puts line
        # puts
        # buff += line.each_byte.to_a
        
        buff = line.each_byte.to_a  
      
        
        l = line.each_byte.to_a.collect{|i| i.to_i.to_s}
        # l.each_with_index do |i,id| 
        #       if i=='119'
        #         puts "xx #{l.size} #{i}\t#{id}"
        #       end
        #     end
        
        # puts l.join("\t") if l.size==258 or l.size==1448
        
        # puts l.join("\t")
        
        # left = line.size
        
          # if left
       #      buff = buff[left..-1]
       #      left = nil
       #    end
       #
       index = 0 
    
        while index<buff.size
          res = nil
          type = buff[index]
          
          case type
            
            when 20 
              read = 20 + 256
              # puts "Found Peak 255" 
            else
                if type != 0
                    read = type
                    #puts "Found #{read} #{'msg'}" 
                end
            end
          
            # puts "cmd #{type} #{read} #{buff.size}"
       
          
          if index+read <= buff.size
          
           res = buff[index..index+read-1]
           
           if type==138
           # puts res.inspect 
           
           130.times do |i|
             v = res[i+8]
             
             map[i] = {} unless map[i]
             map[i][v] = v unless map[i][v]
               
            if v==200
              puts "spo2 #{i}"
              
            end 
               
           end
           
             
           list = map.keys.collect{|i| [i, map[i].keys] if map[i].keys.size > 1 }.compact
           
           puts list.inspect 
            
             
         end
 
          if type==176 or type==162 or type==144 or type==76 or type==138
            
          #res = buff[index..index+read-1]  

          # puts res.inspect

            if type==176
              s = ''
	            puts "XXX#{res}"
              for i in res[40..60]
                break if i==0
                s+=i.chr 
              end
              hn = s.strip
              puts "HN #{hn} new"
              
            end
            
            
            if type==138
              
            
            # 13/11/2019  
            
              so2 = res[100]/2
              pr = res[112]/2
              bp_hr = res[16]/2
              
              high = "#{res[124]/2}"
              high = "#{res[124]+128}" if res[125]==67
              
              bp = "#{high}/#{res[130]/2}"
              
              
              
              #puts "XXX #{res}"
              # so2 = res[106]/2
              
              
              
              # high = "#{res[124]/2}"
#               high = "#{res[124]+128}" if res[125]==67
#
#
#               bp = "#{high}/#{res[130]/2}"
#
#
#               bp_hr = res[136]/2
#               # pr = res[142]/2
#               # pr = res[118]/2
#
#               pr = res[104]/2
#
                         #       
                         # puts line
                         #           puts
                         #           
                         #              res.each_with_index do |i,ix|
                         #           
                         #                print "#{ix}\t" if ix%10==0 
                         #                print "#{i.to_i.to_s}\t"
                         #                puts if ix%10==9 and ix!=0
                         #           
                         #              end
                         #           
                         #              puts
              
              new_check_stamp = "#{bp}-#{bp_hr}"
             # nx = Time.now 

          #    if check_stamp!=new_check_stamp
         #       now = Time.now 
	#	last = Time.now 
           #     bp_stamp  = format("%02d%02d%02d", now.hour, now.min, now.sec)
          #      check_stamp = new_check_stamp
         #     else
	#	last = Time.now
	      #end
              
	      if check_stamp!=new_check_stamp
                 n = 5
                 monitor = true
		 now = Time.now
                 new_bp_stamp  = format("%02d%02d%02d", now.hour, now.min, now.sec)

	         check_stamp = new_check_stamp
	      else
		if n> 0           
		  n -=1
		   #puts "n=#{n} #{bp} #{bp_stamp}"
	      	elsif n==0 and monitor
		  if bp!='61/61'
		  bp_stamp = new_bp_stamp
		  puts "New BP #{bp} #{bp_stamp}"
                  end
		  monitor = false
	 	end

		end

              puts "HR #{bp_hr}"
              puts "NIBP #{bp}"
              puts "SO2 #{so2}"
              puts "PR #{pr}"
              # 
                       if bp=='61/61' 
                          bp= '-/-'
                          # pr= 0
                          # bp_stamp = nil
                          # so2 = 0

                        end 
              data = {}
              
              data[:hr] = '-'
              data[:rr] = '-'
              data[:spo2] = '-'
              
              if so2 != 61 and pr != 61 

		data[:hr] = pr
		data[:pr] = pr
		data[:spo2] = so2

	      end
	    
	      if false and data[:hr] =='-' and bp_hr != 61
 
	       data[:hr] = bp_hr
               data[:pr] = bp_hr

               end  
             
              data[:bp] = bp
              
              data[:bp_stamp] = bp_stamp

              ref = hn
              bed = station
              name = bed
              stamp = Time.now.to_json
                          
              puts "#{stamp}\t#{station}\t#{data.inspect}"
              
              
              begin            


              # result = Net::HTTP.post_form(uri, 'ip'=>client.peeraddr[-1],'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)


                                   # data[:bp] = bp
                                   # data[:pr] = 60 + rand(60)
                                   # data[:hr] = data[:pr]
                                   # data[:rr] = 18 + rand(4)
                                   # data[:so2] = 90+rand(10)
                                   # data[:bp_stamp] = bp_stamp.strftime("%H%M%S")

              msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG

                           ws.send(msg)



                            rescue Exception=>e
                              puts e.message
                            end

              
              
                    
              # begin            
              #   result = Net::HTTP.post_form(uri, 'ip'=>client.peeraddr[-1],'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)
              # rescue Exception=>e
              #   puts e.message
              # end
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
  
    end
    
    rescue Exception=>e
      puts e.message
      
    end
      
  
    end
        
        puts 'next'    
 
end


end

end
