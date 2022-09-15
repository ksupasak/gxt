# confirm iiok
require 'net/http'
require 'socket'                 # Get sockets from stdlib
require 'json'
require 'date'
require 'simple_hl7'
server = TCPServer.open(6002)    # Socket to listen on port 2000
loop {                  
     puts 'start'
           # Servers run forever
   client = server.accept
   
   puts 'accept'
   
   
   # start
   # accept
   # waile
   # xx
   # "\vMSH|^~\\&|VC150|84:2F:75:00:24:AA|GATEWAY|HOSPITAL|20200424112552.538+0700||QBP^Q22^QBP_Q21|1701072507-00000001|P|2.5\r"
   # xx
   # "QPD|IHE PDQ Query|Q0001|@PID.3.1^12345678\r"
   # xx
   # "RCP|I|100^RD\r"
   # xx
   # "\x1C\r"
   # PV1||O454545||Doe^John|12345678|D|2.5
   #
   # PV1||O454545||Doe^John|12345678|D|2.5
   # start
   
   
   
   # t = Thread.new {
      local = client
         puts 'waile'
         msg = client.gets("\r")
         puts 'xx'
         puts msg.inspect # "\vMSH|^~\\&|VC150|84:2F:
          msg = client.gets("\r")
          puts 'xx'
          puts msg.inspect   # "QPD|IHE PDQ Query|Q0001|@PID.3.1^12345678\r"
          
          query_hn = msg.split("|")[3].split("^")[-1].strip
          
          
           msg = client.gets("\r")
           puts 'xx'
           puts msg.inspect   # "RCP|I|100^RD\r"
            msg = client.gets("\r")
            puts 'xx'
            puts msg.inspect  # "\x1C\r"
            
            
            
            
            his_get_patient_uri = URI("http://10.99.0.109/systemx/api/patient/#{query_hn}")
 
    
  
            msg = nil
  
            begin
  
            content = "{}"    
  
             
            req = Net::HTTP::Get.new(his_get_patient_uri.to_s)

            # setting both OpenTimeout and ReadTimeout
            res = Net::HTTP.start(his_get_patient_uri.host, his_get_patient_uri.port, :open_timeout => 0.5, :read_timeout => 0.5) {|http|

                 http.request(req)

            }

            content = res.body  
            
            puts content.inspect 
            puts 'xxx'
            
            # {
     #        "personKey": "4578484884", "hn": "153174XX", "pid": "3840100269238", "pname": "นาย",
     #        "fname": "Supasak", "lname": "Kulawonganunchai",
     #        "birth": "28042526", "gender": "1", "fullName": "Supasak Kulawonganunchai", "employeeCode": "XXXX"
     #        }
            
            
            obj = JSON.parse(content)
            puts 'paraed'
            robj = {}
  
  
  
            puts obj.inspect
    
    
            # birth_date = Date.new obj['birth'][4..7].to_i-543, obj['birth'][2..3].to_i, obj['birth'][0..1].to_i
            birth_date = Date.new obj['birth'][0..3].to_i, obj['birth'][4..5].to_i, obj['birth'][6..7].to_i
  
  
            robj[:hn] = obj['hn']
            robj[:pid] = obj['pid']
            robj[:first_name] = obj['fname']
            robj[:last_name] = obj['lname']
            robj[:prefix_name] = obj['pname']
            robj[:gender] = obj['gender']
            robj[:birth_date] = birth_date
            robj[:age] = (Time.now.to_time.to_i - birth_date.to_time.to_i).to_i / 365 / 86400
            robj[:full_name] = obj['fullName']
  
            
            dob = birth_date.strftime("%Y%m%d")
            
            gender = 'U'
            gender = 'M' if robj[:gender]=='1'
            gender = 'F' if robj[:gender]=='2'
            
            puts 'parsed'
            
            msg = SimpleHL7::Message.new
            msg.msh[9][1] = "ADT"
            msg.msh[9][2] = "A04"
            msg.msh[10] = "12345678"
            msg.msh[11] = "D"
            msg.msh[12] = "2.5"

            msg.pid[3] =  robj[:hn] 
            msg.pid[5][1] =  robj[:first_name] 
            msg.pid[5][2] =   robj[:last_name] 
            msg.pid[7] = dob #YYY[MM[DD
            msg.pid[8] = gender 

            msg.pv1[2] = "O"

            puts msg.to_hl7  # PV1||O454545||Doe
            puts msg.to_llp    # PV1||O454545||Doe^John|
            
            client.write msg.to_llp
            
            client.close   
            
          rescue Exception=>e 
            
            puts e.inspect 
          end
            
            
                      #
          # rescue Net::ReadTimeout => exception
          #         # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (ReadTimeout)"
          #         msg = "NOT reachable (ReadTimeout)"
          #          result = {:status=>'404 ERROR', :msg=>msg}
          #    #      sleep 10
          # rescue Net::OpenTimeout => exception
          #         # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
          #         msg = "NOT reachable (OpenTimeout)"
          #          result = {:status=>'404 ERROR', :msg=>msg}
          #        #  sleep 10
          # rescue Exception =>exception
          #         # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
          #         msg = exception.to_s
          #
          #         result = {:status=>'404 ERROR', :msg=>msg}
          # end
            
            
            
            
            
            
    #  while msg = client.read and msg.size>0
    #   puts msg.inspect
    #  end
     
       
   # }
   
   # t.run
   
   
   #MSH|^~\&|VC150|84:2F:75:00:24:AA|GATEWAY|HOSPITAL|20190711063023.309+0700||QBP^QRCP|I|100^RDQuery|Q0015|@PID.3.1^9538359
   
   #         # Wait for a client to connect
   # client.puts(Time.now.ctime)   # Send the time to the client
   # 
   # 
   # 
   # 
   # client.puts "Closing the connection. Bye!"
              # Disconnect from the client
}



