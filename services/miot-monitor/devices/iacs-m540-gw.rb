require 'socket'
require 'net/http'
require 'json'
require "ipaddr"
require_relative 'config/m540_cfg'
require_relative 'iacs-lib'




# BIND_ADDR_LOCAL = "191.1.1.5"

# BIND_ADDR_LOCAL = "172.28.5.151"

# BIND_ADDR_LOCAL = "10.50.0.193"


# M540 data on this port


module Device


  def self.add_monitor socket, ip
  
 
 # M540_MULTICAST_ADDR = "224.0.1.10"  # to receive data
 #
 # M540_BIND_ADDR_LOCAL = "10.50.0.5"
 
 mip = "224.0.1.#{ip.split(".")[-1]}"



 membership = IPAddr.new(mip).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton
 

 puts 'Start Receive Data : ' + ip
 socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
 # socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)


end


def self.etabular data, cols = 20 , out = STDOUT


     data.each_with_index do |i,index|

       out.print "#{index}," if index % cols == 0

       out.print "#{i},"

       out.puts if index % cols == cols -1

     end

 out.puts 

   end

     def self.start_monitor socket, ws, queue
     
    #========================================================================================
    #========================================================================================
    #========================================================================================
    
    # M540_MULTICAST_ADDR = "224.0.1.10"  # to receive data
    #
    # M540_BIND_ADDR_LOCAL = "10.50.0.5"
    
  # mip = "224.0.1.#{ip.split(".")[-1]}"

   

    # membership = IPAddr.new(mip).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton
    #
    #
    # puts 'Start Sent Data : ' + ip
    # socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
    # socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)

    # open port
    socket.bind('0.0.0.0', M540_PORT)


    # host = GW_IP
    # port = GW_PORT
    # uri = GW_URI

  

    station_msg = nil
cout = {}

 
mout = {}
#    %w{622 886 1060 1406 1428}.each do |i|
#    eout = File.open('out-'+i+'.txt','w')  
#   mout[i.to_i] = eout
#end
    
    lbuff = {}
    vs =  {}
    
    devices = {}
    


	    


    response = true

    while true do
  
      begin
  
        message, info = socket.recvfrom(4096)
        l = message.each_byte.to_a.collect{|i| i.to_i}  
          
          device_id = info[2]
          
          devices[device_id] = {:name=>device_id.gsub('.','-'),:id=>device_id,:wbuff=>[],:vs=>{},:lbuff=>{}} unless devices[device_id] 
          device = devices[device_id]
          vs = device[:vs]
          lbuff = device[:lbuff]
          wbuff = device[:wbuff]
          # lead data package
	
	
	
	
	
	
	
	       map = IACS::parser l
	
		
	 m = map
#	puts device_id
	  if false and  device_id =='191.1.2.10'
		map.keys.sort.each do |i|
			#puts i
			puts "#{i}\t#{map[i].inspect.to_s if map[i].inspect.size<10}"
		end 
		puts
	end


        vs[:hr] = m['6-9-0-0-9'] if m['6-9-0-0-9']
        vs[:hr] = m['1-4-0-0-26'] if m['1-4-0-0-26']
        vs[:hr] = m['1-4-0-1-26'] if m['1-4-0-1-26']
        vs[:hr] = m['1-112-0-1-2'] if m['1-112-0-1-2'] and  m['1-112-0-1-2'] > 10

	vs[:hr] = '-' unless vs[:hr]
     
  	vs[:pr] = m['25-14-0-0-28'] if m['25-14-0-0-28']
        vs[:pr] = m['25-14-0-1-28'] if m['25-14-0-1-28']   
        vs[:pr] = m['25-255-0-0-28'] if m['25-255-0-0-28'] and m['25-255-0-0-28'] >10
       # vs[:pr] = m['30-7-0-0-9'] if m['30-7-0-0-9'] and ( m['30-7-0-0-9'] - vs[:hr] ).abs < (vs[:pr]-vs[:hr]).abs

          vs[:pr] = '-' unless vs[:pr]
        
	      
	        vs[:spo2] = m['25-5-0-0-26'] if m['25-5-0-0-26']   
       #   vs[:spo2] = m['25-5-0-1-26'] if m['25-5-0-1-26']
          vs[:spo2] = m['1-3-1-0-30'] if m['1-3-1-0-30'] and m['1-3-1-0-30'] > 10 
          vs[:spo2] = m['1-191-0-1-2'] if m['1-191-0-1-2'] and m['1-191-0-1-2']>10
          vs[:spo2] = '-' unless vs[:spo2]
      
            vs[:rr] = m['94-120-0-0-66'] if m['94-120-0-0-66']
            vs[:rr_pmean] = (m['94-113-0-0-66']/10.0).round if m['94-113-0-0-66']
            vs[:rr_pip] = (m['94-123-0-0-27']/10.0).round if m['94-123-0-0-27']
            vs[:vte] = m['94-125-0-0-66']
       
            
	          bp_sys = vs[:bp_sys]
            bp_dia = vs[:bp_dia]

	  
            
    	  bp_sys = (m['30-9-0-0-9']/10.0).round if m['30-9-0-0-9']
	      bp_sys = (m['1-2-0-0-28']/10.0).round if m['1-2-0-0-28']
        bp_sys = (m['1-2-1-0-28']/10.0).round if m['1-2-1-0-28']
        bp_sys = (m['1-1-0-0-26']/10.0).round if m['1-1-0-0-26'] and m['1-1-0-0-26'] > 10

		    bp_dia = (m['30-9-0-1-9']/10.0).round if m['30-9-0-1-9']
        bp_dia = (m['30-8-0-0-9']/10.0).round if m['30-8-0-0-9']
        bp_dia = (m['30-8-0-1-9']/10.0).round if m['30-8-0-1-9']


	    vs[:bp_sys] = bp_sys
	    vs[:bp_dia] = bp_dia
		
	    vs[:bp_mean] = (m['30-7-0-0-9']/10.0).round if m['30-7-0-0-9']
            
            vs[:bp] = "#{bp_sys}/#{bp_dia}"
            



	#	puts map.keys.sort.inspect

	      t = 14
	
  	      lx = %w{6-1 25-22 1-2 1-3 1-4 1-37 1-40 1-43 1-45 1-46 1-48 95-54 95-55 95-57}
  	          
              now = Time.now 
              stamp = now.to_json
              bp_stamp = now

              ref = '-'
	            
	            
    	        lx.each_with_index do |j, jindex|
	                

                  wave = map[j]
			
		 #puts wave.inspect if j=='6-1'

                  lbuff[jindex] = [] unless lbuff[jindex]
			
		if wave
                  lbuff[jindex] += wave 

                  end
              
              end
	#	puts "#{lbuff.collect{|c| c[1].size}.join(",")}"

              if lbuff[2].size>=200        

#          puts "#{lbuff.collect{|c| c[1].size}.join(" ")}"
                  data = {}

                  data[:leads] = {}
              
                  (t+1).times do |j|

                      data[:leads][j] = lbuff[j].shift(200) if lbuff[j]

                  end

              
                  # data[:wave] = wbuff.shift(25)
                  #data[:wave] =  data[:leads][0]
                  
                  data.merge! vs


                  # data[:temp] = '-'
                  # data[:rr] = '-' 

                  data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
              
                  name = device[:name]

            
              #   puts data.inspect  if device_id=='191.1.2.2'
                    
              msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'msg'=>station_msg, 'data'=>data}.to_json}
MSG
	t = Time.now.to_f
	 
	 
	            queue << msg
            	#  response = ws.send(msg)

  #puts "#{device_id} #{name} PR=#{data[:pr]} SpO2=#{data[:spo2]} BP=#{data[:bp]} HR=#{data[:hr]} at #{(Time.now.to_f-t)*1000}"


              # puts "Send #{now} #{response.inspect} #{name}"

                  if response == nil

                  ws = MIOT::connect 


                  end


              end

	
	
	
	
	
	
	
	
	
      	  if  device_id=='191.1.2.12' #and false         
       #       puts "#{info.inspect }\t#{l[30..35].collect{|i| i.to_s}.join("\t")}\t#{message.size}" 
          end
    
         if false
          outk ="#{device_id}_#{l[33].to_i}_#{message.size}"
          unless eout = mout[outk]
          eout = File.open(File.join('/home/user/Desktop/devices/',"#{outk}.txt"),'w')
          mout[outk] = eout
          end
          x =94
          etabular l, x, mout[outk]
          end
    
    
          
    #==================================================== Name Data
    
           if false and message.size==302
             
             # tabular l 
             
             tags = []
             8.times do |i|
                tags << l[97+i*2]
             end
             station_name = tags.collect{|i| i.chr}.join.strip
             
             tags = []
             
             30.times do |i|
               
               break if l[133+i*2]==0
               tags << l[133+i*2]
                
             end
             msg = tags.collect{|i| i.chr}.join.strip
             
             name = station_name
             device[:name] = name
             
             
             station_msg = msg
             # puts station_name
             #
             # puts msg
             
             
           end
#==================================================== Normal Data
          


          if false and  l[33].to_i == 14 and l.size ==1406#and l[35].to_i >= 210 #or message.size==1298
            # puts message.size
            # tabular l
            

	              m = {}
		            size = 37
                size.times do |i|
		            if 46+(i+1)*36< l.size
                line =  l[46+i*36..46+(i+1)*36]        
                #puts line.join(",")
                k = line[12..16].join("-")
                a = line[28]
                b = line[29]
                v = a*256+b
                v = -256*(256-a)+b if a>200
		            m[k] = v 

                #  puts "#{k} #{v}"
                end

                end

                 
            vs[:hr] = l[39] if l[39]!=4
            vs[:pr] = l[291]
            vs[:spo2] = l[255]
		
            #vs[:hr] = l[507];            
	          #vs[:spo2] = l[723]

            if l[291]=4 and l[255] == 4
               vs[:pr] = vs[:spo2] = '-'
            end
            
            bp_sys = l[326]*256+l[327]
            bp_dia = l[362]*256+l[363]
            
  	          bp_dia = l[629]+l[629-1]*256



            vs[:pr] = m['25-14-0-0-28']
            vs[:spo2] = m['30-9-0-0-9']
            vs[:hr] = m['1-4-0-0-26']
            vs[:rr] = m['94-120-0-0-66']
            vs[:rr_pmean] = (m['94-113-0-0-66']/10.0).round
            vs[:rr_pip] = (m['94-123-0-0-27']/10.0).round
            vs[:vte] = m['94-125-0-0-66']
            vs[:cvp] = (m['25-5-0-1-26']/10.0).round 
            bp_sys = m['1-2-1-0-28']
            bp_dia = m['30-8-0-0-9']
            bp_mean = m['30-7-0-0-9']
            vs[:bp_mean] = (bp_mean/10.0).round
            vs[:bp] = "#{(bp_sys/10.0).round}/#{(bp_dia/10.0).round}"
    
           end



          
#=========================================================== # Lead Data
           
          if false and l[33].to_i ==  12 and message.size>0 #and l[49].to_i != 110# and l[19].to_i != 174
     
            t = 14

	          lx = %w{6-1 25-22 1-2 1-3 1-4 1-37 1-40 1-43 1-45 1-46 1-48 95-54 95-55 95-57}


#             tabular l
           
            now = Time.now 
            stamp = now.to_json
            bp_stamp = now
            
            ref = '-'
            
	   pos = 56
            
            t.times do |j|
      if pos<l.size        
 	 size = l[pos]

# puts "#{j} #{size}"
			
              wave = []
              

		k = "#{l[pos-2]}-#{l[pos-1]}"
		
		size.times do |i|
                
                v = (pos+2)+i*2
        	#v -= 6 if j>1
                
                a = l[v]
                b = l[v+1]
                
                x = a*256+b
                x = -256*(256-a)+b if a>200
       
                wave << x
                
              end
             
	           pos+=size*2+14

		         jx = lx.index(k)

              lbuff[jx] = [] unless lbuff[jx]
	
#puts sampling
             # wbuff += wave.collect{|x| (50-(x.to_f/1024)*50).to_i} if j==0
	       lbuff[jx] += wave
              
              end
            end
              
#           puts lbuff[2].size
                
      if lbuff[2].size>=200        
            
            
            data = {}
            
            
            
            data[:leads] = {}
            (t+1).times do |j|
              
               data[:leads][j] = lbuff[j].shift(200) if lbuff[j]
              
            end

	 data[:wave] = wbuff.shift(25)


        data.merge! vs

        
        data[:temp] = '-'
       # data[:rr] = '-' 
        
        data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
        name = device[:name]
         

       # puts "#{device_id} #{name} PR=#{data[:pr]} SpO2=#{data[:spo2]} BP=#{data[:bp]} HR=#{data[:hr]}"

     #   puts data.inspect  if device_id=='191.1.2.2'      
       msg = <<MSG
Data.Sensing device_id=#{name}
 #{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'msg'=>station_msg, 'data'=>data}.to_json}
MSG
	response = nil
      #response = ws.send(msg)
      # puts "Send #{now} #{response.inspect} #{name}"
      
      if response == nil
        
       ws = MIOT::connect 
        
        
      end
 
      
    end
    
    
    
  end
          
    
  
  
  rescue Exception=>e
   
     puts e.inspect
    puts e.backtrace
	puts "Device ID #{device_id}"      
  end
  
    end
  
end


  def self.monitor_iacs_m540 ws

    puts "-- Start IACS M540 Service"


    name = 'Bed01'

    def tabular data, cols = 20 , out = STDOUT

 
      data.each_with_index do |i,index|
    
        out.print "#{index}.\t" if index % cols == 0
    
        out.print "#{i}\t"
    
        out.puts if index % cols == cols -1
    
      end
  
    end

    def variant_detection tmp, data
  
  
  # tmp = stmp[k]
  
  result = []
  
  
  
  data.each_with_index do |i,index|
     
     count = 0 
     list = []
     
     for j in tmp
        if j[index]!=data[index]
          count +=1
          
        end
        list << j[index]
     end
     
     if count > 1
       list << data[index]
       u = list.uniq
        puts "variant\t#{index}\t#{u.size}\t#{u.join(",")}#{}\t"
     end

   end
  
   tmp << data
  
   # tmp.delete_at(0) if tmp.size==20
   # puts
    end
 
 
    def self.demo ws


lead_idx = 0
leads =  [0,0,0,0,0,0]

  100.times do |x|
    begin
    puts 'Start Receive Dataf'

    ref = '1234'
    name = 'Bed04'
     now = Time.now
     stamp = now.to_json

     bp_stamp = now
     data = {}

     wave = []


     lead_template = [700, 876, 880, 588, 304, 40, -168, -216, -204, -120, -76, -96, -92, -76, -76, -88, -84, -76, -84, -72, -72, -72, -80, -68, -76, -80, -68, -64, -72, -64, -60, -68, -72, -60, -60, -48, -16, 16, 52, 80, 124, 160, 196, 220, 240, 260, 284, 300, 312, 316, 320, 320, 320, 312, 300, 276, 264, 236, 200, 152, 108, 68, 20, -32, -68, -96, -124, -132, -144, -148, -136, -128, -124, -120, -120, -124, -116, -116, -112, -112, -112, -112, -112, -108, -104, -104, -104, -104, -100, -84, -80, -72, -68, -64, -60, -52, -48, -44, -40, -36, -36, -36, -36, -20, 8, 48, 88, 116, 128, 140, 152, 148, 144, 128, 112, 84, 60, 24, -20, -48, -56, -60, -52, -48, -48, -48, -48, -48, -48, -44, -44, -44, -44, -44, -44, -44, -64, -108, -140, -100, 80, 340, 604, 824]

     w = 2
     rps =32
     s = 4

     max = 1024
     min = -1024

     rps.times do |i|
  
       # y = Math.sin(300*w/rps*i*Math::PI/180)*rand()*50+50
     #   wave << format("%.3f",y).to_f
     #
      wave <<  50-(lead_template[lead_idx*s].to_f / 1024) *50
      lead_idx += 1
      lead_idx = 0 if lead_idx*s > lead_template.size
 
       # period += rand(10)
     end


     rps2 = 64
     s2 = 2

     # puts wave

     data[:wave] = wave
 

     data[:leads] = {} unless data[:leads]


     6.times do |x|
  
       # data[:leads][x] = [] unless data[:leads][x] 
  
       id = leads[x]
       wave = []
  
       rps2.times do |i|
  

        # wave <<  50-(lead_template[id*s2].to_f / 1024) *50
        wave << lead_template[id*s2] if lead_template[id*s2] 
        id += 1
        id = 0 if id*s2 > lead_template.size
 
         # period += rand(10)
       end
       data[:leads][x] = wave
  
       leads[x] = id
  
     end 
 


     data[:bp] = '120/90'
     data[:pr] = 60 + rand(60)
     data[:hr] = data[:pr]
     data[:rr] = 18 + rand(4)
     data[:temp] = 36 + rand(4)
     data[:spo2] = 90+rand(10)
     data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
    # puts msg

    puts 'Start Sent Data '+msg

     ws.send(msg)

   rescue Exception=>e
     puts e.inspect
   end

   sleep(1)

 end
 
 
end

# self.demo ws
  

  
     
     #========================================================================================
     #========================================================================================
     #========================================================================================
     
     
    
     socket = UDPSocket.new
      
     
   thread =  Thread.new {
      
     
     dis_socket = UDPSocket.new

     membership = IPAddr.new(M540_DIS_MULTICAST_ADDR).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton


    puts 'Start Sent Data'
    dis_socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)


    # open port
    dis_socket.bind('0.0.0.0', M540_DIS_PORT)
    
    
    

    puts 'Start Monitor Discovery'
    
      
    ip_map = {}
    
    
    while true do

      begin

        message, info = dis_socket.recvfrom(4096)
        l = message.each_byte.to_a.collect{|i| i.to_i}  
       
  
       
        ip = info[2]
       
         
        unless ip_map[ip]
          
          # k = fork{
          puts "add new monitor #{ip}"
            add_monitor socket, ip
          
               
          # }
          
          ip_map[ip] = true
          
        
        end

      rescue Exception=>e
        puts e.inspect
    
      end
  
    end
     
       }
       
       thread.run
       
       
       # puts 'xxxxxxxx'
       
       
       pt_thread =  Thread.new {
         
         
     
         dis_socket = UDPSocket.new

         membership = IPAddr.new(M540_PT_MULTICAST_ADDR).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton


        puts 'Start Sent Data'
        dis_socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)


        # open port
        dis_socket.bind('0.0.0.0', M540_PT_PORT)
        
         
      
        ip_map = {}
    
    
        while true do

          begin

            message, info = dis_socket.recvfrom(4096)
            l = message.each_byte.to_a.collect{|i| i.to_i}  
       
            # tabular l, 20
           

          rescue Exception=>e
            puts e.inspect
    
          end
  
        end
     
           }
       
           pt_thread.run
       
       
       queue = []
       
      media_thread = Thread.new {
        
        
        EventMachine.run {

       
         xv = Time.now.to_f

          EM.add_periodic_timer(1) do
            
             begin
            unless ws.open?
              sleep 5
               ws = MIOT::connect
            end
            
            ethread = Thread.new {
            
            t = Time.now.to_f
         
            
         
            qtemp = queue.shift queue.size
            msg = qtemp.join("\nEOL\n")
            if qtemp.size < 32 
              
           
            ws.send msg
            
            # for i in queue
            #               ws.send msg
            #             end
             puts "Queue = #{qtemp.size} #{msg.size/1000}KB #{(Time.now.to_f-t)*1000}ms #{Time.now.to_f-xv}"
           end
           
           }
           
           ethread.run
           
            rescue Exception=>e

              puts e.inspect 

                end
            
          end
        


        } 
        
      } 
       
       media_thread.run
       
       
     start_monitor socket, ws , queue
     
     thread.join
   
   media_thread.join
   
end
end
  
