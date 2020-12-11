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
  
  
def self.monitor_comen_nc3a ws


server = TCPServer.new 5001

last = {}
last_sec = Time.now.to_i

loop do
  Thread.start(server.accept) do |client|
    puts 'connect '
     
      while content = client.read(128)
    
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
  
      last[i[0]] = i[1]
        
      end
      
      
      t = Time.now.to_i
      
      
      if last_sec != t 
        
        last_sec = t
      
        puts last.inspect
      
        lines = []
       
       lines << "STATUS:T1|T1:#{last['T1'].to_i/10.0}" if last['T1']
       lines << "STATUS:M0|PR:#{last['PR']}|SPO2:#{last['SPO2']}" if last['PR'] and last['SPO2'] and last['PR'][0]!='-' and  last['SPO2'][0]!='-'
       lines << "STATUS:M1|SYS:#{last['NIBP_S']}|DIA:#{last['NIBP_D']}|MEAN:#{last['NIBP_M']}|PR:#{last['PR']}|SPO2:#{last['SPO2']}" if last['NIBP_S'] and last['NIBP_D'] and last['NIBP_M'] and last['PR'] and last['SPO2'] and last['PR'][0]!='-' and  last['SPO2'][0]!='-'
       
       
       
      if lines.size > 0
      puts lines.inspect

      msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM
  
        puts msg

     puts  ws.send(msg)
 
    end
      
      end
      
      
    end
    
    client.close
  end

end

end

end