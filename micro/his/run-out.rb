require 'socket'                 # Get sockets from stdlib
require 'net/http'
require 'socket'                 # Get sockets from stdlib
require 'json'
require 'date'
server = TCPServer.open(6000)    # Socket to listen on port 2000
loop {                  
     puts 'start'
           # Servers run forever
   client = server.accept
   act = nil
   puts 'accept'
      time = nil
      local = client
         puts 'waile'
         header = false
         
         
         bp_dia = nil
         bp_sys = nil
         bp_mean = nil
         spo2 = nil
         pr = nil
         
         
         
         
         
     while(true)
           
           
         msg = client.gets("\r")
         
         unless header
            header = msg
            headers = header.split("|")
            
            puts headers.inspect
            
            # ["\vMSH", "^~\\&", "VC150", "84:2F:75:00:4A:3D", "", "", "20211105183918.937+0700", "", "ORU^R01^ORU_R01", "1935915075-00000003", "P", "2.6", "", "", "NE", "AL", "", "", "", "", "IHE_PCD_001^IHE PCD^1.3.6.1.4.1.19376.1.6.1.1.1^ISO", "", "", "^84:2F:75:00:4A:3D^MAC\r"]
            
            
            
            src_app = headers[2]
            src_add = headers[3]
            des_app = headers[4]
            des_add = headers[5]

            time = headers[6]
            rec = headers[8]
            serial = headers[9]
            
            
            t = time.split("+")
            time = "#{t[0].to_f+1}+#{t[1]}"

ack = <<EOF
\vMSH|^~\\&|#{des_app}|#{des_add}|#{src_app}|#{src_add}|#{time}||#{rec}^ACK|#{serial}|P|2.6\rMSA|AA|#{serial}\r
EOF

ack = []
ack << "\vMSH|^~\\&|HIS|EMR|||#{time}||ACK|#{serial}|P|2.3\r"
ack << "MSA|AA|#{serial}\r"
ack << "\x1C\r" 

# MSH|^~\&|HIS|CARDIO|||20150123130522||ACK|20150123130522|P|2.3 MSA|AA|1571000710-00000001


         end
#

      

         break if msg=="\x1C\r"
         
   puts "- "+ msg.inspect
   
   
   tm = msg.split("|")
   cmd = tm[0]
   
   if cmd=='PID'
     
     hn = tm[3].strip
     
   elsif cmd=='OBX'
     
     key = tm[3].split("^")[0]
     value = tm[5].to_i
     
     case key
     when '150022'
       bp_dia = value
     when '150021'
       bp_sys = value
     when '150023'
       bp_mean = value
     when '149546'
       pr = value
     when '150456'
       spo2 = value
     end
     
     
   end   
   
      
      
      
   end
   
   puts 'complete'

   puts ack.inspect  
   
   for i in ack
     client.write i
   end
   client.flush
   
   
   
     
   
   
   
   
   
    his_post_opd_url = URI("http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}")
   
   
   
    url = his_post_opd_url
    
   
    error = false
    err_msg = "NA"
    
    
    begin
   
      

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 2 # seconds
      
      # --header 'Content-Type:application/json' --header 'Accept:application/json'
      puts url.path
      # puts url.full_path
      puts "#{url.path}?#{url.query}"
      
      request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'Content-Type' =>'application/json', 'Accept'=>'application/json'})
      # request.set_form_data(px)
        
      
      response = Net::HTTP.start(url.host, url.port, :open_timeout => 1, :read_timeout => 3) {|http| http.request(request)}
      
      puts "RESPONSE #{response.body}"
      
      result = JSON.parse response.body
      
    
      
    rescue Exception => e
      puts e.inspect 
      error = true
      err_msg = "Server Timeout!"
    end
    
   
   
   
   
   # s = TCPSocket.new '192.168.1.218',6000
   # for i in ack
   #   s.write i
   # end
   # s.flush
   # s.close
   #
   puts "Sent"
   
   # 1701072507-00000002
       # 1942841066-00000001
       
# msg = <<EOF
# MSH|^~\\&|VC150|VC150|MMS\rHL7|.^^|#{time}||ACK^R01|17f1be29-aa2a-11d2-a655-00105a1e9b67|P|2.3\rMSA|AA|17f1be29-aa2a-11d2-a655-00105a1e9b67\r
# EOF
# 
# msg = <<EOF
# MSH|^~\&|LABADT|DH|EPICADT|DH|201301011228||ACK^A01^ACK |HL7ACK00001|P|2.3
# MSA|AA|HL7MSG00001
# EOF

      # puts ack[0..-2].inspect
      # client.write ack[0..-2]
      # client.flush
      #
       
    #  while msg = client.read and msg.size>0
    #   puts msg.inspect
    #  end
     
       client.close     
   
   
   #MSH|^~\&|VC150|84:2F:75:00:24:AA|GATEWAY|HOSPITAL|20190711063023.309+0700||QBP^QRCP|I|100^RDQuery|Q0015|@PID.3.1^9538359
   
  # MSH|^~\&|VC150|84:2F:75:00:24:AA|Gateway|Hospital|20190711064520.613+0700||ORU^R01^ORU_R01|456425781-00000002|P|2.6|||NE|AL|||||IHE_PCD_001^IHE PCD^1.3.6.1.4.1.OBR|1|1^1^1^ISO|1^1^1^ISO|VITALS^Vital Signs^VSM|||20190711064038.000+0700|20190OBX|1|ST|RESPRate|1.1.1.1|60||||||F|||20190711064239.000+0700||||84:2F:75:00:24:OBX|2|ST|LevelOfConsciousness|1.1.1.1|Alert||||||F|||20190711064337.000+0700||||OBX|3|ST|SupplementOxygen|1.1.1.1|No||||||F|||20190711064213.000+0700||||84:2F:7OBX|4|ST|MDC_PULS_OXIM_SAT_O2|1.1.1.1|90||||||R|||20190711064101.000+0700||||84:OBX|5|ST|MDC_TEMP|1.1.1.1|36||||||R|||20190711064126.000+0700||||84:2F:75:00:24:OBX|6|ST|MDC_PULS_OXIM_PULS_RATE|1.1.1.1|85||||||R|||20190711064111.000+0700||||OBX|7|ST|MDC_PRESS_BLD_NONINV_SYS|1.1.1.1|45||||||R|||20190711064151.000+0700||||84:2F:75:00:24:AA|
  # MSH|^~\&|VC150|84:2F:75:00:24:AA|Gateway|Hospital|20190711064520.613+0700||ORU^R01^ORU_R01|456425781-00000002|P|2.6|||NE|AL|||||IHE_PCD_001^IHE PCD^1.3.6.1.4.1.OBR|1|1^1^1^ISO|1^1^1^ISO|VITALS^Vital Signs^VSM|||20190711064038.000+0700|20190OBX|1|ST|RESPRate|1.1.1.1|60||||||F|||20190711064239.000+0700||||84:2F:75:00:24:OBX|2|ST|LevelOfConsciousness|1.1.1.1|Alert||||||F|||20190711064337.000+0700||||OBX|3|ST|SupplementOxygen|1.1.1.1|No||||||F|||20190711064213.000+0700||||84:2F:7OBX|4|ST|MDC_PULS_OXIM_SAT_O2|1.1.1.1|90||||||R|||20190711064101.000+0700||||84:OBX|5|ST|MDC_TEMP|1.1.1.1|36||||||R|||20190711064126.000+0700||||84:2F:75:00:24:OBX|6|ST|MDC_PULS_OXIM_PULS_RATE|1.1.1.1|85||||||R|||20190711064111.000+0700||||OBX|7|ST|MDC_PRESS_BLD_NONINV_SYS|1.1.1.1|45||||||R|||20190711064151.000+0700||||84:2F:75:00:24:AA||
  # MSH|^~\&|VC150|84:2F:75:00:24:AA|Gateway|Hospital|20190711064520.613+0700||ORU^R01^ORU_R01|456425781-00000002|P|2.6|||NE|AL|||||IHE_PCD_001^IHE PCD^1.3.6.1.4.1.OBR|1|1^1^1^ISO|1^1^1^ISO|VITALS^Vital Signs^VSM|||20190711064038.000+0700|20190OBX|1|ST|RESPRate|1.1.1.1|60||||||F|||20190711064239.000+0700||||84:2F:75:00:24:OBX|2|ST|LevelOfConsciousness|1.1.1.1|Alert||||||F|||20190711064337.000+0700||||OBX|3|ST|SupplementOxygen|1.1.1.1|No||||||F|||20190711064213.000+0700||||84:2F:7OBX|4|ST|MDC_PULS_OXIM_SAT_O2|1.1.1.1|90||||||R|||20190711064101.000+0700||||84:OBX|5|ST|MDC_TEMP|1.1.1.1|36||||||R|||20190711064126.000+0700||||84:2F:75:00:24:OBX|6|ST|MDC_PULS_OXIM_PULS_RATE|1.1.1.1|85||||||R|||20190711064111.000+0700||||OBX|7|ST|MDC_PRESS_BLD_NONINV_SYS|1.1.1.1|45||||||R|||20190711064151.000+0700||||84:2F:75:00:24:AA||
   #         # Wait for a client to connect
   # client.puts(Time.now.ctime)   # Send the time to the client
   # 
   # 
   # 
   # 
   # client.puts "Closing the connection. Bye!"
              # Disconnect from the client
}

# MSH|^~\&|VC150|VC150|||20150126122942.570+0200||ORU^R 01^ORU_R01|859050513- 00000001|P|2.6|||NE|AL|||||IHE_PCD_001^IHE PCD^1.3.6.1.4.1.19376.1.6.1.1.1^ISO|||AA:BB:CC:DD:EE: FF^^MAC
# MSH|^~\&|VC150|84:2F:75:00:24:AA|Gateway|Hospital|20190713103648.044+0700||ORU^R01^ORU_R01|1907218830-00000002|P|2.6|||NE|AL|||||IHE_PCD_001^IHE PCD^1.3.6.1.4.1.19376.1.6.1.1.1^ISO|||^84:2F:75:00:24:AA^MAC
# PID|||454545||Doe^John^^^^^L||||
# PV1|1|O|84:2F:75:00:24:AA||||||||||||||||
# OBR|1|1^1^1^ISO|1^1^1^ISO|VITALS^Vital Signs^VSM|||20190713103300.000+0700|20190713103630.000+0700
# OBX|1|ST|RESPRate|1.1.1.1|20||||||F|||20190713103630.000+0700||||84:2F:75:00:24:AA||
# OBX|2|ST|LevelOfConsciousness|1.1.1.1|Alert||||||F|||20190713103624.000+0700||||84:2F:75:00:24:AA||
# OBX|3|ST|SupplementOxygen|1.1.1.1|No||||||F|||20190713103626.000+0700||||84:2F:75:00:24:AA||
# OBX|4|ST|MDC_PULS_OXIM_SAT_O2|1.1.1.1|97||||||F|||20190713103601.000+0700||||84:2F:75:00:24:AA||
# OBX|5|ST|MDC_PRESS_BLD_NONINV_DIA|1.1.1.1|73||||||F|||20190713103601.000+0700||||84:2F:75:00:24:AA||
# OBX|6|ST|MDC_PRESS_BLD_NONINV_MEAN|1.1.1.1|78||||||F|||20190713103601.000+0700||||84:2F:75:00:24:AA||
# OBX|7|ST|MDC_TEMP|1.1.1.1|37||||||R|||20190713103620.000+0700||||84:2F:75:00:24:AA||
# OBX|8|ST|MDC_PULS_OXIM_PULS_RATE|1.1.1.1|87||||||F|||20190713103601.000+0700||||84:2F:75:00:24:AA||
# OBX|9|ST|MDC_PRESS_BLD_NONINV_SYS|1.1.1.1|105||||||F|||20190713103601.000+0700||||84:2F:75:00:24:AA||
