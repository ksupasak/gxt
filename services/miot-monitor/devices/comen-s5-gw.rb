require 'socket'



module Device
  
  
  def self.monitor_comen_s5_live ws  
  
  
  



    server = TCPServer.new 7788
    @ws = ws
    last = {}
    last_sec = Time.now.to_i

    loop do
      
      begin
      
      Thread.start(server.accept) do |client|
        puts 'connect f'
     
        #   while content = client.read(128)
            
            
        map = {'MDC_RESP_RATE'=>:rr,
        'MDC_ECG_HEART_RATE'=>:hr, 
        'MDC_PULS_OXIM_SAT_O2'=>:spo2, 
        'MDC_PRESS_CUFF_SYS'=>:bp_sys, 
        'MDC_PRESS_CUFF_MEAN'=>:bp_mean, 
        'MDC_PRESS_CUFF_DIA'=>:bp_dia, 
        'MDC_PULS_RATE_NON_INV'=>:pr, 
        'MDC_PULS_RATE'=>:pr}
      message = ""
       queue = []
       data = {}
       # HL7 over MLLP typically ends with \x1c\r
       while (line = client.read(4096))
         # puts line.inspect
         #puts line.bytes.inspect
         # puts line
         message << line
     
     
         t = message.split("\r")
         
         stop =false
         
         t.each do |m|
             if m == "\u001C"
               puts data.inspect


               if !data.empty?
              



               stamp = Time.now
               name = "S5"
               ref = "-"
               
               if data[:bp_sys] and data[:bp_sys].to_i > 11 and data[:bp_dia] and data[:bp_dia].to_i > 11

                data[:bp] = "#{data[:bp_sys]}/#{data[:bp_dia]}"
                       
               end








               msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
                # puts msg
    
                puts 'Start Sent Data '+msg
    
                
        
                a =   @ws.send(msg)  
                
                if a == nil
                puts 'Cannot connect server'
                sleep 2
                    @ws = MIOT::connect
                
                a =   @ws.send(msg)  
                
                end
               
            end

               data = {}
               message = ""  
             else
               v =  m.split("|") 
               if v[0]=="OBX" and v[3]
                 # puts "#{v[3]}\t#{v[5]}"
                 k = v[3].split("^")[1]
     
                 if map[k]
                   data[map[k]] = v[5]
                 end
     
              
     
               end
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
      
    end
  
  end # loop

end  
  
  
  
def self.monitor_comen_nc3a ws


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
  tri_weight = nil
  sent = false

  seca = Thread.new {
    
     #
    # 9 Current Weight
    #
    # 10 76.2
    #
    # 11 kg
    #
    # 12 Trig. Weight
    #
    # 13 0.0
    #
    # 14 kg
    #
    # 15 Height
    #
    # 16 0.000
    #
    # 17 m
    #
    # 18 Scan Value
    
    seca_uri = URI('http://192.168.4.1/')
    
    while true
      puts 'seca'
      
      begin
      
      req = Net::HTTP::Get.new(seca_uri.to_s)

      # setting both OpenTimeout and ReadTimeout
      res = Net::HTTP.start(seca_uri.host, seca_uri.port, :open_timeout => 3, :read_timeout => 3) {|http|
           
           http.request(req)
           
      }
      
      
      content = res.body
      
      document = Nokogiri::HTML(content)
      tags = document.xpath("//td")
      tags.each_with_index do |t,ti|
    
        current_height = t.text.strip if ti==16
        current_weight = t.text.strip if ti==13  
        trig_weight = t.text.strip if ti==10
        
          
        if current_height and current_weight and current_height.to_f > 0 and current_weight.to_f > 0
          
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
      
      puts "weight = #{current_weight}, height = #{current_height}"
      
      
     
      # end
      
    rescue Net::ReadTimeout => exception
            STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (ReadTimeout)"
            sleep 10 
    rescue Net::OpenTimeout => exception
            STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
            sleep 10
    rescue Exception =>exception        
            STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
            sleep 10 
    end
        
         sleep 1
      
    end
  }

  seca.run




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

       
       lines << "STATUS:T1|T1:#{last['T1'].to_i/10.0}" if last['T1']
       lines << "STATUS:M0|PR:#{last['PR']}|SPO2:#{last['SPO2']}" if last['PR'] and last['SPO2'] and last['PR'][0]!='-' and  last['SPO2'][0]!='-'
       lines << "STATUS:M1|SYS:#{last['NIBP_S']}|DIA:#{last['NIBP_D']}|MEAN:#{last['NIBP_M']}|PR:#{last['PR']}|SPO2:#{last['SPO2']}" if last['NIBP_S'] and last['NIBP_D'] and last['NIBP_M'] and last['PR'] and last['NIBP_S'][0]!='-'  and last['SPO2'] and last['PR'][0]!='-' and  last['SPO2'][0]!='-'
       
       
       
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