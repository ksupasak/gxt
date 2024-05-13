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
  
  
  def self.monitor_nihon_hl7_live ws  
  
    puts 'xxx'
    server = TCPServer.new '0.0.0.0', 5001
    @ws = ws
    last = {}
    last_sec = Time.now.to_i

    loop do
      
      begin
      
      Thread.start(server.accept) do |client|
        puts 'connect f'
          
        # client.read_timeout = 1
        
       
        current_hn = nil
        current_station = nil
        map = nil
        flash = false
        
        while true
          
          content = ""
          
          # while buff = client.readline("\r")
     #        content += buff
     #        puts buff.inspect
     #        puts buff.size
     #      end
           
          content = client.readline("\r")
          
          puts content
            
          t = content.split("|")
          
          tag = t[0]

          case tag
            
          when 'PID'
       
            # puts map.inspect 
        
            if map
              puts t[3].inspect 
            
              last = map  
              last['hn'] = {:val=>current_hn,:unit=>''} 
              last['name'] = {:val=>current_station,:unit=>''}
              flush = true
             
            end
             map = {}
            current_hn = t[3].split("^")[0]
          
          when 'PV1'
            v = t[3].split("^")
            puts v.inspect 
            # current_station = "#{v[0]+"-" if v[0].size>0}#{v[2].split('&')[0]}"
            current_station = "#{v[1].split('-')[1]}"
            
            # map[] = current_station.split.join("_")
            
          when 'OBX'
            
            tag = t[3].split("^")[-2]
            val = t[5]
    
            unit = t[6].split("^")[-2]
            
            map[tag] = {:val=>val,:unit=>unit}
            
          end
          
          
          
      
          t = Time.now.to_i
      
          if flush 
            
            
            flush = false
            puts " Flush : #{current_hn} #{current_station}"
          
          
              
            lines = []
            
            tmap = last
           
            last = {}
            puts tmap.inspect 
            
            tmap.each_pair do |k,v| 
              last[k] = v[:val]
            end
            
          # "NBPs"=>{:val=>"67", :time=>"20200330114750\r", :unit=>"mmHg"},
          # "NBPd"=>{:val=>"40", :time=>"20200330114750\r", :unit=>"mmHg"},
          # "NBPm"=>{:val=>"49", :time=>"20200330114750\r", :unit=>"mmHg"},
          # "Pulse (NBP)"=>{:val=>"95", :time=>"20200330114750\r", :unit=>"bpm"},
          # "HR"=>{:val=>"120", :time=>"F\r", :unit=>"bpm"},
          # "RR"=>{:val=>"30", :time=>"F\r", :unit=>"rpm"},
          # "SpO2"=>{:val=>"98", :time=>"F\r", :unit=>"%"},
          # "Perf"=>{:val=>"3.6", :time=>"F\r", :unit=>""}}
          #
          puts 'okkkkkkk'
            last['PR'] = last['Pulse (NBP)']
            last['PR'] = last['Pulse (SpO2)'] if last['Pulse (SpO2)'] and last['Pulse (SpO2)'].size>0
            
            
            last['HR'] = last['001000']
            last['PR'] = last['007001']
            last['RR'] = last['004073']
            
            last['NBPs'] = last['044000']
            last['NBPd'] = last['044001']
            last['NBPm'] = last['044002']
            
            last['NBPs'] = last['009000'] if last['009000']
            last['NBPd'] = last['009001'] if last['009001']
            last['NBPm'] = last['009002'] if last['009002']
            
            last['SpO2'] = last['007000']
            last['CO2'] = last['073000']
            
               
            # OBR|1|||VitalSigns|||20240503100459||||||||||||||||||A
        #     OBX|1|NM|001000^HR||75|bpm|-||||O|||20240503100459|||
        #     OBX|2|NM|004001^Apnea||0|sec|-||||O|||20240503100459|||
        #     OBX|3|NM|004073^RR/CO2||16|/min|-||||O|||20240503100459|||
        #     OBX|4|NM|007000^SpO2||98|%|-||||O|||20240503100459|||
        #     OBX|5|NM|007001^SpO2/PR||73|/min|-||||O|||20240503100459|||
        #     OBX|6|NM|011000^Tskin||36.5|C|-||||O|||20240503100459|||
        #     OBX|7|NM|012000^Tskin2||36.5|C|-||||O|||20240503100459|||
        #     OBX|8|NM|037000^Delta-T||0.0|C|-||||O|||20240503100459|||
        #     OBX|9|NM|044000^ART-S||124|mmHg|-||||O|||20240503100459|||
        #     OBX|10|NM|044001^ART-D||88|mmHg|-||||O|||20240503100459|||
        #     OBX|11|NM|044002^ART-M||100|mmHg|-||||O|||20240503100459|||
        #     OBX|12|NM|044006^ART/PR||75|/min|-||||O|||20240503100459|||
        #     OBX|13|NM|073000^CO2/RR||16|/min|-||||O|||20240503100459|||
        #     OBX|14|NM|073001^EtCO2||40|mmHg|-||||O|||20240503100459|||
        #     OBX|15|NM|073003^CO2/Apnea||0|sec|-||||O|||20240503100459|||
        #     OBX|16|NM|136000^QT||0|ms|-||||O|||20240503100459|||
        #     OBX|17|NM|136001^QTc||0|ms|-||||O|||20240503100459|||
        #     OBX|18|NM|136002^QTcE||0|ms|-||||O|||20240503100459|||
        #     OBX|19|NM|136003^QTcB||0|ms|-||||O|||20240503100459|||
        #     OBX|20|NM|136004^QTcF||0|ms|-||||O|||20240503100459|||
        #     OBX|21|NM|136005^QT-HR||0|bpm|-||||O|||20240503100459|||
        #     OBX|22|NM|136006^QRSd||0|ms|-||||O|||20240503100459|||
        #     OBR|2|||NIBP|||20240503100718||||||APERIODIC||||||||||||A
        #     OBX|1|NM|009000^NIBP-S||171|mmHg|-||||O||APERIODIC|20240503100718|||
        #     OBX|2|NM|009001^NIBP-D||122|mmHg|-||||O||APERIODIC|20240503100718|||
        #     OBX|3|NM|009002^NIBP-M||138|mmHg|-||||O||APERIODIC|20240503100718|||
      
            lines = []
            
            # station name 
            name = client.peeraddr[2].gsub(".","-")
            # name = "49-230-20-94"
            
            
            bp_stamp = Time.now
            stamp = Time.now
            ref = '-'
            data = {}
            data[:bp] = "-/-"
            data[:bp] = "#{last['NBPs']}/#{last['NBPd']}" if last['NBPs'] and last['NBPd'] and last['NBPm']
            data[:bp_sys] = last['NBPs'] if last['NBPs'] and last['NBPs'].to_i > 11
            data[:bp_dia] = last['NBPd'] if last['NBPd'] and last['NBPd'].to_i > 11
            data[:bp_mean] = last['NBPm'] if last['NBPm'] and last['NBPm'].to_i > 11
            
            data[:pr] = last['PR'] if last['PR'] and last['PR'].to_i > 0
            data[:hr] = last['HR'] if last['HR'] and last['HR'].to_i > 0
            data[:rr] = last['RR'] if last['RR'] and last['RR'].to_i > 0
            data[:co2] = last['CO2'] if last['CO2'] and last['CO2'].to_i > 0
            
            
            data[:temp] = last['T1'].to_i/10.0 if last['T1'] and last['T1'].to_i > 11
            # data.delete :temp if data[:temp] < 0 
            
            data[:spo2] = last['SpO2'] if last['SpO2'] and last['SpO2'].to_i > 11
            data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
            
            # data[:spot] = true 
            
            name = last['name']#current_station.split.join("_")
            ref = last['hn']#current_hn
            
            puts data.inspect 
            
            if data[:spo2] or data[:bp]
            
            msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
            # puts msg

            puts 'Start Sent Data '+msg

           
  
           a =  @ws.send(msg)  
           
           if a == nil
             puts 'Cannot connect server'
             sleep 2
              @ws = MIOT::connect
             
             a =   @ws.send(msg)  
             
           end
           
         end
        
         
          
           end
      
      
        end # 
    
        client.close
        
        
      end  # thread
  
  
    rescue Exception=>e
      
      puts e.inspect 
      
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
