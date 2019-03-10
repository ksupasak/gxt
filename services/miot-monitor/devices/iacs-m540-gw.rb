require 'socket'
require 'net/http'
require 'json'
require "ipaddr"
require_relative 'config/m540_cfg'





# BIND_ADDR_LOCAL = "191.1.1.5"

# BIND_ADDR_LOCAL = "172.28.5.151"

# BIND_ADDR_LOCAL = "10.50.0.193"


# M540 data on this port


module Device



  def self.monitor_iacs_m540 ws

    puts "-- Start IACS M540 Service"


    def tabular data, cols = 20
  
      data.each_with_index do |i,index|
    
        print "#{index}.\t" if index % cols == 0
    
        print "#{i}\t"
    
        puts if index % cols == cols -1
    
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
  
     puts 'Start Sent Data'
     


    socket = UDPSocket.new

    membership = IPAddr.new(M540_MULTICAST_ADDR).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton
    
 
    puts 'Start Sent Data'
    socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
    # socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)

    # open port
    socket.bind('0.0.0.0', M540_PORT)


    # host = GW_IP
    # port = GW_PORT
    # uri = GW_URI

  
    puts 'Start Receive Data'

    tmp = []
    stmp = {}
    sk = {}
    
    lbuff = {}
    
    vs =  {}
    
    response = true


    while true do
  
      begin
  
        message, info = socket.recvfrom(4096)
        l = message.each_byte.to_a.collect{|i| i.to_i}  
   
    
          # lead data package
          
    
          #====================================================
          
          if l[33].to_i == 14 and message.size==1298

            puts "SPO2-HR #{l[291]}"
            puts "SPO2-% #{l[255]}"

            puts "HR #{l[39]}"
      
            puts "BP-SYS #{l[326]*256+l[327]}"
      
            puts "BP-DIA #{l[362]*256+l[363]}"
      
            vs[:hr] = l[39]
            
            vs[:pr] = l[291]
            vs[:spo2] = l[255]
            
            if l[291]=4 and l[255] == 4
               vs[:pr] = vs[:spo2] = '-'
            end
            
            bp_sys = l[326]*256+l[327]
            bp_dia = l[362]*256+l[363]
            
            vs[:bp] = "#{bp_sys/10}/#{bp_dia/10}"
            
      
             #
             # tabular l
             # puts
             # variant_detection tmp, l
             puts
           end
          
          
          if  l[33].to_i ==  12 #and l[49].to_i != 110# and l[19].to_i != 174
     
                 #
            # 40.times do |i|
    #           print "#{i}\t"
    #           6.times do |j|
    #
    #             v = 58+(j*94)+i*2
    #             v -= 6 if j>1
    #
    #             a = l[v].to_i
    #             b = l[v+1].to_i
    #
    #             # puts a
    #             x = a*256+b
    #             x = -(256-b) if a==255
    #
    #             print "#{x}\t"
    #
    #
    #           end
    #
    #           puts
    #         end

            #========================================
          
            
           
              now = Time.now 
            stamp = now.to_json
            bp_stamp = now
            ref = '1235'
            6.times do |j|
              
              wave = []
              40.times do |i|
                
                v = 58+(j*94)+i*2
                v -= 6 if j>1
                a = l[v]
                b = l[v+1]
                
                x = a*256+b
                x = -256*(256-a)+b if a>200
       
                wave << x
                
              end
              
              lbuff[j] = [] unless lbuff[j]
              lbuff[j] += wave
              
            
              
              
            end
              
                # puts "#{lbuff[0].size} #{Time.now}"
                
                
      if lbuff[0].size>=200        
            
            
            data = {}
            
            
            
            data[:leads] = {}
            6.times do |j|
              
               data[:leads][j] = lbuff[j].shift(200)
              
            end

            # data[:bp] = '120/90'
        #     data[:pr] = 60 + rand(60)
        #     data[:hr] = data[:pr]
        #     data[:rr] = 18 + rand(4)
        #     data[:temp] = 36 + rand(4)
        #     data[:spo2] = 90+rand(10)
            
        # data[:bp] = '120/90'
        # data[:pr] = 60 + rand(60)
        # data[:hr] = data[:pr]
        # data[:rr] = 18 + rand(4)
        # data[:spo2] = 90+rand(10)

        data.merge! vs

        # data[:temp] = 36 + rand(4)
    #     data[:rr] = 18 + rand(4)
        data[:temp] = 37 
        data[:rr] = 20 
        
        data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
         
           
       msg = <<MSG
Data.Sensing device_id=#{name}
 #{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG

      response = ws.send(msg)
      puts "Send #{now} #{response}"
      
      if response == nil
        
       ws = MIOT::connect 
        
        
      end
 
      
    end
    end
          
    
  
  
  rescue Exception=>e
        puts e
      
  end
  
end
end
end
  