require 'socket'


def callx l
  
  puts "ua "+l.size.to_s
   #puts '========================================'

   n = 30
   r = l.size/n+1

   print "-\t"

   n.times do |i|

     print "#{i}\t"

   end
   puts
   r.times do |j|

     print "#{j*n}\t"

     n.times do |i|

       # print ".#{l[j*n+i].chr}\t"

       print "#{l[j*n+i]}\t"


     end

     puts


   end
  
end

module Device
  
  
  def self.monitor_comen_nc3a_live ws  
  
  
  



    server = TCPServer.new 5001
    @ws = ws
    last = {}
    last_sec = Time.now.to_i

    loop do
      
      begin
      
      Thread.start(server.accept) do |client|
        puts 'connect f'
     
          while content = client.read(256)
    
          # OBX||NM|40^HR||-100|0002-4182^bpm^
          # OBX||NM|1000^ST2||-10000|NULL|<20||||FDIL|<10||||F
          # OBX||NM|1000^STVaVL||-10000|NULL|<20||||F
          # OBX||NM|1000^STV2||-10000|NULL|<20||||F|F
          # OBX||NM|1000^STV5||-10000|NULL|<20||||F
          # OBX||NM|100^T1||-1000|0401-0b54^C^MDIL|3600^3900||||F
          # OBX||NM|188^SPO2||-100|0002-0b54^C^MDIL|0^200||||F
          # OBX||NM|67^AET_M||-100|0002-4a05^mmhg^MDIL|7000^16000||||F
          # OBX||NM|83^ICP_M||-100|0002-4a05^mmhg^MDIL|0^1000||||F||F
          # OBX||NM|91^NIBP_M||-100|0002-4a05^mmhg^MDIL|6000^11000||||F
          # OBX||NM|115^INSCO2||100|0002-4a05^mmhg^MDIL|16000^0||||F
          # OBX||NM|112^CO2Et_AG||-100|0002-4a05^mmhg^MDIL|2
          # OBX||NM|1192^O2Et_AG||-100|0002-4bb8^%^MDIL|18^88||||F|||F
          # OBX||NM|1188^N2OFt_AG||-100|0002-4bb8^%^MDIL|0^55||||FF
          # OBX||NM|1239^MAC_AG||-100|0002-4a05^mmhg^MDIL|0^0||||F
          # OBX||NM|1000^SV__ICG||-100||0^0||||FF
          # OBX||NM|125^CI||-10000||0^0|^3900||||F|F
          # OBX||NM|132^BT||-100|0002-4bb8^%^MDIL|0^0||||F
          # OBX||NM|1000^IT||-100|0002-4bb8^%^MDIL|0^70||||F
          # OBX||NM|44^PR||-100|0002-4182^bpm^MDIL|50^120||||F
          # PID||~\&|||||20201211162102||ORU^R01|202012111621024734|P|2.4
          # callx content.each_byte.to_a.collect{|i| i.to_i}
          # puts content.inspect 
          list = content.split("\r").collect{|i| t = i.split("|");  [t[3].split("^")[-1],t[5]] if t.size>5 }.compact
      
          lines = []
      
          
      
          for i in list
  
          last[i[0]] = i[1] if i[1][0..3]!='2021'
        
          end
      
      
          t = Time.now.to_i
      
      
          if last_sec != t 
        
            last_sec = t
      
            puts last.inspect
      
            lines = []
            
            # station name 
            name = client.peeraddr[2].gsub(".","-")
            # name = "49-230-20-94"
            
            
            bp_stamp = Time.now
            stamp = Time.now
            ref = '-'
            data = {}
            data[:bp] = "-/-"
            data[:bp] = "#{last['NIBP_S']}/#{last['NIBP_D']}" if last['NIBP_S'] and last['NIBP_D'] and last['NIBP_M'] and  last['NIBP_S'].to_i>11
            data[:bp_sys] = last['NIBP_S'] if last['NIBP_S'] and last['NIBP_S'].to_i > 11
            data[:bp_dia] = last['NIBP_D'] if last['NIBP_D'] and last['NIBP_D'].to_i > 11
            data[:bp_mean] = last['NIBP_M'] if last['NIBP_M'] and last['NIBP_M'].to_i > 11
            
            data[:pr] = last['PR'] if last['PR'] and last['PR'].to_i > 11
            data[:hr] = last['HR'] if last['HR'] and last['HR'].to_i > 11
            data[:rr] = last['RR'] if last['RR'] and last['RR'].to_i > 11
            
            data[:temp] = last['T1'].to_i/10.0 if last['T1'] and last['T1'].to_i > 11
            # data.delete :temp if data[:temp] < 0 
            
            data[:spo2] = last['SPO2'] if last['SPO2'] and last['SPO2'].to_i > 11
            data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
            msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
            # puts msg

            puts 'Start Sent Dataf '+msg

           
  
           a =  @ws.send(msg)  
           
           if a == nil
             puts 'Cannot connect server'
             sleep 2
              @ws = MIOT::connect
             
             a =   @ws.send(msg)  
             
           end
           

          end
      
      
        end # 
    
        client.close
        
        
      end  # thread
  
  
    rescue Exception=>e
      
      unless ws.open?
        puts 'error ws'
        sleep 5
        ws.close
        puts 'reconnect ws'
        ws = MIOT::connect
      end
      
    end # begin
  
  end # loop

end  #func 
  
  

end # module
