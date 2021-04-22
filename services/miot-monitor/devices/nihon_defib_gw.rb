require 'socket'
require 'net/http'
require 'json'
require "ipaddr"
require 'openssl'
require "digest"
require 'base64'


require_relative 'config/m540_cfg'
require_relative 'nihon_defib_lib'



module Device


  def self.defib_nihon  ws


    buffers = {}

  
  thread =  Thread.new {
    
    

    while(true)
      
          bp_stamp = Time.now
          
          stamp_i = Time.now.to_i
          
          
          buffers.each_pair do |device_id, device|
       
            
            puts device[:vs].size
            
          if device[:vs].size>0 and device[:vs][0][:stamp_i] == stamp_i
            
            
            ref = '0000'
            head_data = device[:vs].shift
            puts device[:vs].size
            
            
            data = head_data
            stamp = data[:stamp]
            

            msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>data[:name], 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
            # puts msg

            puts 'Start Sent Data '+msg

            ws.send(msg)
#
            
          end
          
          while device[:vs].size > 0 and device[:vs][0][:stamp_i]<stamp_i
            head_data = device[:vs].shift
          end
          
            
          
          puts "#{device[:vs].collect{|i| i[:stamp_i] }.join(", ")}"
            
          end
          
          
          puts "waiting .. #{stamp_i} "
          sleep(1)
          
    end
    
  }
  
  
  device_thread =  Thread.new {
    
    n = 30
    sam = 3
    


    while(true)
      
      device_id = '0000'
      
      (sam).times do |t|
     
          data = {}
          bp_stamp = Time.now - n + t*(n/sam)
          stamp = bp_stamp
          ref = '0000'
          
          data[:name] = device_id
          data[:bp] = '120/90'
          data[:pr] = 60 + rand(60)
          data[:hr] = data[:pr]
          data[:rr] = 18 + rand(4)
          data[:temp] = 36 + rand(4)
          data[:spo2] = 90+rand(10)
          data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
          data[:stamp] = stamp
          data[:stamp_i] = stamp.to_i + n + 3
          
    
          buffers[device_id] = {:vs=>[]} unless buffers[device_id]
          buffers[device_id][:vs] << data
          
    
     end
         
    sleep(n)
          
    # puts  buffers[device_id][:vs].size
          
          
    end
    
  }
  
  device_thread.join
  thread.join
      
    
  end

end

