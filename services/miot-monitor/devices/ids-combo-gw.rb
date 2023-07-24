require 'socket'
require 'serialport'



module Device
  

def self.get_device device_select

    list = `ls /dev/ttyUSB*`.split
    puts list
    map = {}

    	for i in list
	
	device_id = i.split("/")[2]	
	
	cmd = `grep PRODUCT= /sys/bus/usb-serial/devices/#{device_id}/../uevent`

	device_vendor =  cmd.split("=")[-1].split("/")[0..1].join(":")

	map[device_vendor] = i 

	end	

   puts map.inspect 

   result = map[device_select]

    return result if result

    return ""

end


def self.get_devices device_select

    list = `ls /dev/ttyUSB*`.split
    puts list
    map = {}

    	for i in list
	
	device_id = i.split("/")[2]	
	
	cmd = `grep PRODUCT= /sys/bus/usb-serial/devices/#{device_id}/../uevent`

	device_vendor =  cmd.split("=")[-1].split("/")[0..1].join(":")

	map[device_vendor] = [] unless map[device_vendor] 
	map[device_vendor] << i
  

	end	

   puts map.inspect 

   results = map[device_select]

    return results if results

    return []

end

  
def self.monitor_ids_combo ws


  content = <<SECA

  <!doctype html>
  <html lang="de">
  <head>
      <title>Alibaba WebInterface</title>
      <table>
          <tr>
              <td>WebServer</td>
              <td>Version 1.1</td>
          </tr>
          <tr>
              <td>
                  <br>
              </td>
          </tr>
          <tr>
              <td>Name</td>
              <td>scaler01</td>
          </tr>
          <tr>
              <td>Scale Model</td>
              <td>seca 797</td>
              <td>05797254208950</td>
          </tr>
          <tr>
              <td>
                  <br>
              </td>
          </tr>
          <tr>
              <td>Current Weight</td>
              <td>76.2</td>
              <td>kg</td>
          </tr>
          <tr>
              <td>Trig. Weight</td>
              <td>0.0</td>
              <td>kg</td>
          </tr>
          <tr>
              <td>Height</td>
              <td>0.000</td>
              <td>m</td>
          </tr>
          <tr>
              <td>Scan Value</td>
              <td></td>
          </tr>
      </table>
  </head>
  <body>
      <h3>CONFIG</h3>
      <form method="get">
          <p>
              Login-Pwd 
              <input type="password" name="LoginPwd" size=32 maxlength=59>
          <p>
              <input type="submit" value="Submit">
      </form>
  </body>
  <br>
  <br>
  Copyright © 2018 seca gmbh & co. kg. All rights reserved.
  </html>

  

SECA

require 'nokogiri'


  current_height = nil
  current_weight = nil
  trig_weight = nil
  sent = false

  seca = Thread.new {
    
    
    
  loop do 
   
   puts 'starting ... seca'


   
   
   # seca_uri = URI('http://192.168.4.1/')
  threads = []
       
   device_ids = get_devices "10c4:ea60"
   
   st =nil
   
   for device_id in device_ids
     puts 'seca '+device_id.inspect
     
   
    threads <<  Thread.new{
   
    Thread.current.thread_variable_set(:device_id, device_id)
    
   
   
    begin
     
   serial = SerialPort.new(device_id, 115200, 8, 1, SerialPort::NONE)
      last_weight = nil
      Thread.current.thread_variable_set(:serial, serial)
      
      
    while true
    
    
      serial = Thread.current.thread_variable_get(:serial)
      device_id = Thread.current.thread_variable_get(:device_id)
   
           #
      # req = Net::HTTP::Get.new(seca_uri.to_s)
      #
      # # setting both OpenTimeout and ReadTimeout
      # res = Net::HTTP.start(seca_uri.host, seca_uri.port, :open_timeout => 3, :read_timeout => 3) {|http|
      #
      #      http.request(req)
      #
      # }
      #
      # content = res.body
      sleep(0.1)
 

      raw = serial.readline("\r")
      
#	puts raw.inspect 
      
      lines = raw.unpack("C*").pack("U*")

      puts '================================= '+device_id
      puts lines
      puts '================================='
      

      content = lines#.split("\n")[-1]    
    

     # puts content

      
      document = Nokogiri::HTML(content)
      tags = document.xpath("//td")
      mtags = {}
tags.each_with_index do |t,ti|
	puts "#{ti} #{t.text.strip}"
  mtags[ti] = t.text.strip
end
      
      version = ""
      
      version = mtags[1].split(" ")[-1] if mtags[1] and mtags[1].index("Version")  
      version = mtags[2].split(" ")[-1] if mtags[2] and  mtags[2].index("Version")
  

      tags.each_with_index do |t,ti|

		
    
        #current_height = t.text.strip if ti==20
        #current_weight = t.text.strip if ti==14  
        #trig_weight = t.text.strip if ti==17
        
        
        if version=='2.1'
          
  	      current_height = t.text.strip if ti==20
          current_weight = t.text.strip if ti==14  
          trig_weight = t.text.strip if ti==17
          
        else

	      current_height = t.text.strip if ti==16
        current_weight = t.text.strip if ti==10  
        trig_weight = t.text.strip if ti==13
	      
       end

        
       # puts "weight = #{current_weight}, height = #{current_height} tweight = #{trig_weight}"
          
        if false and   current_weight and current_weight.to_f > 0
          
          unless sent
          
            lines = []

           lines << "STATUS:S1|HEIGHT:#{current_height}|WEIGHT:#{current_weight}"

       
          if lines.size > 0
          puts lines.inspect

msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM
  
            puts msg

         puts  ws.send(msg)
 
	end
          
            sent = true          
          else 
            send = false
          end
          
        elsif  trig_weight and trig_weight.to_f > 0 
          
          sent = false 
          
            lines = []

           lines << "STATUS:S0|WEIGHT:#{trig_weight}"

       
          if false and  lines.size > 0
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
      
      
      puts "- weight = #{current_weight}, height = #{current_height} tweigth = #{trig_weight} #{device_id}"
   
   
   
if current_weight  and current_weight.to_f > 0
   
    
  lines = []
  puts 'ok'
  
  
  # lines << "STATUS:S1|HEIGHT:#{current_height}|WEIGHT:#{trig_weight}"


   #  if current_height and current_height.to_f > 0
   #
   #   lines << "STATUS:S1|HEIGHT:#{current_height}|WEIGHT:#{current_weight}"
   # else
   #
   #   lines << "STATUS:S1|WEIGHT:#{current_weight}"
   #
   #  end
   #
     
    puts lines.inspect 
      
      
      
      
        if true || trig_weight and trig_weight.to_f !=0 and trig_weight != last_weight
          
          last_weight = trig_weight
		
          if true || current_height and current_height.to_f > 0 
    
      	lines << "STATUS:S1|HEIGHT:#{current_height}|WEIGHT:#{trig_weight}"
        
      else
        
      	lines << "STATUS:S1|WEIGHT:#{trig_weight}"
        
      end
      
	else 
 	
        
	#lines << "STATUS:S1|HEIGHT:#{current_height}|WEIGHT:#{current_weight}"

	end
        

      puts lines.inspect

msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM
  
     puts  ws.send(msg)
 
      
end

    end
    
    
  rescue Net::ReadTimeout => exception
          STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (ReadTimeout)"
          sleep 10 
  rescue Net::OpenTimeout => exception
          STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
          sleep 10
  rescue Exception =>exception        
          STDERR.puts exception.message
          sleep 10 
  end
  
  
  
}


# st.join
  

        end
        
        sleep(5)
        threads.each { |thr| thr.join }
        
       
      # end
      
  
        
  end    





  }

  seca.run
  
  if false

  omron  = Thread.new {
    
   
   # seca_uri = URI('http://192.168.4.1/')
  
	
    begin 

   loop do
  puts 'starting..omron'  


  #device_id = get_device "0483:5740" 
  
  device_id = '/dev/ttyACM0'

  serial = SerialPort.new(device_id, 9600, 8, 1, SerialPort::NONE)
    
    while true
     
      puts 'omron'

      sys = nil

      if true
      
          lines = serial.readline("\r")
      
          last = lines.split(",")
      
          if last.size> 5
      
            sys = last[7]
            dia = last[8]
            pr = last[9]
        
          end
      
      else 
      
            sys = '120'
            dia = '80'
            pr = '79'
        
      
       end
    
    
       if sys
    
    
      lines = []
      
      lines << "STATUS:M1|SYS:#{sys}|DIA:#{dia}|PR:#{pr}"

    msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM
  
       puts msg

       puts  ws.send(msg)
     
     
      end      
     


      sleep(1)
    
    end

    rescue Exception => e
    
  puts e.message
	
sleep(10)

     end
   
  	
 
   end
  }

#  omron.join
  
end


  
  ########################################################################################################################################

  
  
  require 'ble'
  require_relative 'gxt_ble'

  ble  = Thread.new {
    
   loop do 
   
   begin
   
      
   
   BLE::start(ws)
   
   
   
    rescue Exception => e
    
      puts e.message
	
     sleep(1)

     end
   
  	
  end
 
  }

 # ble.join
  
  ########################################################################################################################################
  
  
  
  

  v100  = Thread.new {
    
   
   # seca_uri = URI('http://192.168.4.1/')
  
	
    begin 

  loop do
     
  puts 'starting..v100'  

  device_id = get_device "403:6001" 
#  device_id = "/dev/ttyACM0"
# 
  puts "V100 #{device_id}"
  serial = SerialPort.new(device_id, 9600, 8, 1, SerialPort::NONE)
    serial.read_timeout = 100
    
    

    sleep 1
    # puts 'send'
    #
    ws.send("WS.Select name=local\n[\"Monitor.StartBP device_id=*\"]")
    #
     ws.on :message do |msg|

       if  msg.data.index('Start')
        puts "==================================== Start"
        serial.write " NC0!E\r\n"
        line = serial.readline("\r")
        puts line
       end
       
       
       if  msg.data.index('Stop')
        puts "==================================== Stop"
        serial.write " ND!5\r\n"
        line = serial.readline("\r")
        puts line
       end

     end
    


    while true
     
      puts 'v100'

      sys = nil

      if true
      
          puts 'v100 query'


	        spo2 = nil
          pr = nil
	        bp = nil
          dia = nil
          mean = nil
           
          serial.write " OA!3\r\n"         
          
          line = serial.readline("\r")
	 
          puts line

          if line[3]=='1'
		
           spo2 = line[4..6].to_i

	   end




          serial.write " RA!6\r\n"

          line = serial.readline("\r")
          
          puts line   

          if line[3]=='2'

             pr = line[4..7].to_i

          end           

        
          serial.write " NA!2\r\n"
           
          line = serial.readline("\r")

          puts line

          if line[3]=='1'

               sys = line[10..12].to_i
	             dia = line[13..15].to_i
	             mean = line[16..18].to_i

               puts "Sys:#{sys} Dia:#{dia} Mean:#{mean}"

          end


          last = line.split(",")
      
    
    end
    
       if sys
    
    
      lines = []
     
      x = "STATUS:M1|SYS:#{sys}|DIA:#{dia}|MEAN:#{mean}"
      x += "|PR:#{pr}|SPO2:#{spo2}" if pr and spo2      

  
      lines <<  x #"STATUS:M1|SYS:#{sys}|DIA:#{dia}|MEAN:#{mean}|PR:#{pr}|SPO2:#{spo2}"

    msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM
  
       puts msg

       puts  ws.send(msg)
     
     
      end      
     


      sleep(1)
    
    end

    rescue Exception => e
    
  puts e.message
	
sleep(10)

     end
   
  	
 
   end
  }

  v100.join
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  

#
#
# server = TCPServer.new 5001
#
# last = {}
# last_sec = Time.now.to_i
#
# loop do
#   Thread.start(server.accept) do |client|
#     puts 'connect '
#
#       while content = client.read(128)
#
#       # OBX||NM|40^HR||-100|0002-4182^bpm^
#       # OBX||NM|1000^ST2||-10000|NULL|<20||||FDIL|<10||||F
#       # OBX||NM|1000^STVaVL||-10000|NULL|<20||||F
#       # OBX||NM|1000^STV2||-10000|NULL|<20||||F|F
#       # OBX||NM|1000^STV5||-10000|NULL|<20||||F
#       # OBX||NM|100^T1||-1000|0401-0b54^C^MDIL|3600^3900||||F
#       # OBX||NM|188^SPO2||-100|0002-0b54^C^MDIL|0^200||||F
#       # OBX||NM|67^AET_M||-100|0002-4a05^mmhg^MDIL|7000^16000||||F
#       # OBX||NM|83^ICP_M||-100|0002-4a05^mmhg^MDIL|0^1000||||F||F
#       # OBX||NM|91^NIBP_M||-100|0002-4a05^mmhg^MDIL|6000^11000||||F
#       # OBX||NM|115^INSCO2||100|0002-4a05^mmhg^MDIL|16000^0||||F
#       # OBX||NM|112^CO2Et_AG||-100|0002-4a05^mmhg^MDIL|2
#       # OBX||NM|1192^O2Et_AG||-100|0002-4bb8^%^MDIL|18^88||||F|||F
#       # OBX||NM|1188^N2OFt_AG||-100|0002-4bb8^%^MDIL|0^55||||FF
#       # OBX||NM|1239^MAC_AG||-100|0002-4a05^mmhg^MDIL|0^0||||F
#       # OBX||NM|1000^SV__ICG||-100||0^0||||FF
#       # OBX||NM|125^CI||-10000||0^0|^3900||||F|F
#       # OBX||NM|132^BT||-100|0002-4bb8^%^MDIL|0^0||||F
#       # OBX||NM|1000^IT||-100|0002-4bb8^%^MDIL|0^70||||F
#       # OBX||NM|44^PR||-100|0002-4182^bpm^MDIL|50^120||||F
#       # PID||~\&|||||20201211162102||ORU^R01|202012111621024734|P|2.4
#       # callx content.each_byte.to_a.collect{|i| i.to_i}
#       # puts content.inspect
#       list = content.split("\r").collect{|i| t = i.split("|");  [t[3].split("^")[-1],t[5]] if t.size>5 }.compact
#
#       lines = []
#
#
#
#       for i in list
#
#       last[i[0]] = i[1]
#
#       end
#
#
#       t = Time.now.to_i
#
#
#       if last_sec != t
#
#         last_sec = t
#
#         puts last.inspect
#
#         lines = []
#
#        lines << "STATUS:T1|T1:#{last['T1'].to_i/10.0}" if last['T1']
#
#
#        lines << "STATUS:T1|T1:#{last['T1'].to_i/10.0}" if last['T1']
#        lines << "STATUS:M0|PR:#{last['PR']}|SPO2:#{last['SPO2']}" if last['PR'] and last['SPO2'] and last['PR'][0]!='-' and  last['SPO2'][0]!='-'
#        lines << "STATUS:M1|SYS:#{last['NIBP_S']}|DIA:#{last['NIBP_D']}|MEAN:#{last['NIBP_M']}|PR:#{last['PR']}|SPO2:#{last['SPO2']}" if last['NIBP_S'] and last['NIBP_D'] and last['NIBP_M'] and last['PR'] and last['NIBP_S'][0]!='-'  and last['SPO2'] and last['PR'][0]!='-' and  last['SPO2'][0]!='-'
#
#
#
#       if lines.size > 0
#       puts lines.inspect
#
#       msg = <<EOM
# Monitor.Update zone_id=*
# #{lines.join("\n")}
# EOM
#
#         puts msg
#
#      puts  ws.send(msg)
#
#     end
#
#       end
#
#
#     end
#
#     client.close
#   end
#
# end

end

end
