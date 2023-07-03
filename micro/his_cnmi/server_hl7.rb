require 'eventmachine'
require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'

require 'websocket-client-simple'

require_relative '../lib/miot'

  # set :bind, '0.0.0.0'
  # set :port, 9292
  # set :last_vn, ""





  # set :endpoint, 'http://d-frontserv1.rama.mahidol.ac.th'
 
  set :endpoint, 'http://localhost:9292'
  set :ssb_connection_key, '34522DBE-1E62-4EEC-B049-7C85C9C11012'
  


  puts settings.endpoint





  #
  unless HOST_IP
  HOST_IP = IPSocket.getaddress(Socket.gethostname)
  end

  t = HOST_IP.split('.')
  HOST_NETWORK = t[0..2].join(".")+".1"

  unless ARGV[3]
  HOST_NETWORK_BOARDCAST = t[0..2].join(".")+".255"
  else
  HOST_NETWORK_BOARDCAST = ARGV[3]
  end

  select_monitor = ARGV[2]


  CMS_URI = URI("https://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}")
  MIOT::post_config

  $global_position = ""

  threads = []
  puts ARGV.inspect

  ws = MIOT::connect

  puts ws.inspect 
  
    #
  #
  #  data =  {"hn"=>"9943", "weight"=>"69.10", "height"=>"182.00", "bmi"=>"20.86", "pr"=>"66", "rr"=>nil, "spo2"=>"97", "bp"=>"98/56", "bp_sys"=>"98",
  #   "bp_dia"=>"56", "bp_mean"=>"72", "temp"=>"41.9", "time"=>"16:11:40", "date"=>"2023-05-15",
  #   "serial_number"=>"123456", "record_id"=>"6461f74c74fece0208003ef5", "record_at"=>"2023-05-15 16:11:40 +0700", "staff_id"=>"-"}
  #
  #
  # uri = URI("#{settings.endpoint}/send")
  #
  #
  # http = Net::HTTP.new(uri.host, uri.port)
  # http.use_ssl = true if uri.instance_of? URI::HTTPS
  # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  # http.read_timeout = 10 # seconds
  #
  # request = Net::HTTP::Post.new(uri.request_uri)
  # request.set_form_data(data)
  #
  # response = http.request(request)
  #
  # obj = JSON.parse(response.body)
  #
  #
  # puts obj.inspect
  #




if true

puts 'start HL7'

server = TCPServer.new '0.0.0.0', 9998

last = {}
last_sec = Time.now.to_i

loop do
  
   buff = []
  
  
  
  Thread.start(server.accept) do |client|
    
    begin
      
      
    puts 'connect f'
      
    # client.read_timeout = 1
    buff = []
   
    current_hn = nil
    current_station = nil
    map = nil
    flash = false
    
    while true
      
      content = ""
      

       
      content = client.readline("\r")
       
       puts content.inspect  
       
       buff << content 
        
       sleep(0.01)
    end 
    
    
 
  
rescue Exception=>e
  
  # "\vMSH|^~\\&|Bansal Station Smart OPD|oni|HIS|BMS-HOSxP|20230323120742||ORU^R01|2701|P|2.3\r"
  # "PID|1|||9999999999999\r"
  # "PV1||O|||||||||||||||||\r"
  # "OBR|1|||||20230323120742||||||||20230323120742\r"
  # "OBX|1|ST|WEIGHT||71.00|KG.|||||F|||20230323120742|Bansal Station Smart OPD\r"
  # "OBX|2|ST|HEIGHT||181.6|CM.|||||F|||20230323120742|Bansal Station Smart OPD\r"
  # "OBX|3|ST|BMI||21.5| Kg/m2|||||F|||20230323120742|Bansal Station Smart OPD\r"
  # "OBX|4|ST|TEMP||35.5|C|||||F|||20230323120742|Bansal Station Smart OPD\r"
  # "OBX|5|ST|SYSTOLIC||132|mmHg|||||F|||20230323120742|Bansal Station Smart OPD\r"
  # "OBX|6|ST|DIASTOLIC||90|mmHg|||||F|||20230323120742|Bansal Station Smart OPD\r"
  # "OBX|8|ST|PULSE||78|bpm|||||F|||20230323120742|Bansal Station Smart OPD\x1C\r"  
  
  senses = {}

  senses['bp_sys']=['1', 'SYSTOLIC','mmHg']
  senses['bp_dia']=['2', 'DIASTOLIC','mmHg']
  senses['bp_mean']=['3', 'MBP','mmHg']
  senses['pr']=['4', 'PULSE','bpm']
  senses['temp']=['5', 'TEMP','C']
  senses['weight']=['6', 'WEIGHT','kg']
  senses['height']=['7', 'HEIGHT','cm']
  senses['bmi']=['8', 'BMI','kg/m2']
  senses['spo2']=['9', 'SPO2','%']
  senses['rr']=['10', 'RR','bpm', '22']
  senses['score']=['11','SCORE','']
  senses['avpu']=['12','AVPU','','Alert']
  senses['pain']=['13','PAIN','']
  senses['crt']=['14','CRT','']
  senses['serial_number']=['14','SN','']
  
  
  
  
  map = {}
  
  for i in buff
    
    t = i.split("|")
    
    puts t.inspect 
    
    case t[0]
    when "\vMSH"
      map['SN'] = t[2].strip
    when 'PID'
      map['HN'] = t[3].strip
    when 'OBX'
      x = t[3]
      y = t[5]
      map[x] = y.strip
    else  
    end  
    
    
  end
  
  ##########
  puts map.inspect
 
  # data =  {"hn"=>"9943", "weight"=>"69.10", "height"=>"182.00", "bmi"=>"20.86", "pr"=>"66", "rr"=>nil, "spo2"=>"97", "bp"=>"98/56", "bp_sys"=>"98",
#    "bp_dia"=>"56", "bp_mean"=>"72", "temp"=>"41.9", "time"=>"16:11:40", "date"=>"2023-05-15",
#    "serial_number"=>"123456", "record_id"=>"6461f74c74fece0208003ef5", "record_at"=>"2023-05-15 16:11:40 +0700", "staff_id"=>"-"}
  
  data = {}
  
  
  data['hn'] =  map['HN']
  data['avpu'] =  'Alert'
  data['rr'] =  "20"  
  data['record_id'] = Time.now.to_i.to_s
  data['record_at'] = Time.now.to_s
  data['staff_id'] = "-"
  
  data['bp'] = "#{map['SYSTOLIC']}/#{map['DIASTOLIC']}" if map['SYSTOLIC'] and map['SYSTOLIC'].size>0
  

  # data['FormatType'] = 'BCH'
  # data['VisitType'] = 'OPD'
  # data['HN'] = map['HN']
  # data['VisitDate'] = Time.now.strftime("%Y%m%d")
  # data['VN'] = map['HN']
  # data['PrescriptionNo'] = '1'
  #
  #
  # data['ReportDateTime'] = Time.now.strftime("%Y%m%d%H%M%S")
  # data['ReportByUID'] = "-"
  #
  #
  # senses = {}
  # senses['PULSE']=['Pulse','bpm']
  # senses['SYSTOLIC']=['BPSystolic','mmHg']
  # senses['DIASTOLIC']=['BPDiastolic','mmHg']
  # senses['TEMP']=['Temperature','C']
  # senses['WEIGHT']=['BodyWeight','kg']
  # senses['HEIGHT']=['BodyHeight','cm']
  #


  for s in senses.keys
    v = senses[s]
    if map[v[1]] and map[v[1]].size>0 and map[v[1]]!= "-"

    data[s] = map[v[1]]

    end
  end



  lines = []

  lines << "STATUS:M1|SYS:#{data['BPSystolic']}|DIA:#{data['BPDiastolic']}|PR:#{data['Pulse']}" if data['BPSystolic']
  lines << "STATUS:T1|T1:#{data['Temperature'].to_s}" if data['Temperature']
  lines << "STATUS:S1|HEIGHT:#{data['BodyHeight'].to_f/100}|WEIGHT:#{data['BodyWeight']}" if data['BodyWeight']

msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM

        puts msg

           puts 'Start Sent Data '+msg

           ws.send(msg)
           
           uri = URI("#{settings.endpoint}/send")

           http = Net::HTTP.new(uri.host, uri.port)
           http.use_ssl = true if uri.instance_of? URI::HTTPS
           http.verify_mode = OpenSSL::SSL::VERIFY_NONE
           http.read_timeout = 10 # seconds

           request = Net::HTTP::Post.new(uri.request_uri)
           request.set_form_data(data)

           response = http.request(request)
  
           obj = JSON.parse(response.body)
   


end

end

sleep(1)

end

   
  
  



end


#end  
  

#}


puts 'ready'

#
#
#   post '/send2' do
#
#
#     puts params.inspect
#
#     result = {}
#
#     hn = params[:hn]
#
#     pr = params[:pr]
#
#     weight = params[:weight]
#     height = params[:height]
#
#     puts params.inspect
#
#     ##############################################################
#
#     # his_post_opd_url = URI("http://xxxx/bloodpressure/obd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}&height=#{height}&weight=#{weight}")
#
#     his_post_opd_url = URI("http://localhost:9292/test_send?hn=#{hn}")
#
#     his_post_opd_url = URI("https://10.58.249.83/apis/PTM/set_smart_vital_sign/")
#
#     his_post_opd_url = URI("https://api-covid.wisible.com/v2/addVitalSigns")
#
#
#     # his_post_opd_url = URI("http://172.20.10.5:9292/test_send?hn=#{hn}")
#
#
#
#     # if weight !="-" and height !="-" and weight != '0.0' and height != '0.0'
#     # his_post_opd_url = URI("http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}&height=#{height}&weight=#{weight}")
#     # else
#     # his_post_opd_url = URI("http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}")
#     # end
#     puts 'yyyy'
#     puts his_post_opd_url
#    # http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=111&systolic=222&diastolic=333&pulse=444&weight=555&height=666&waist=777
#
#
#     ##############################################################
#
#     url = his_post_opd_url
#
#
#     error = false
#     err_msg = "NA"
#     begin
#
#
#       # uri = URI.parse(encoded_url)
#    #      http = Net::HTTP.new(uri.host, uri.port)
#    #      http.use_ssl = true if uri.instance_of? URI::HTTPS
#    #      request = Net::HTTP::Post.new(uri.request_uri)
#
#
#
#
#
#       http = Net::HTTP.new(url.host, url.port)
#       http.use_ssl = true #if uri.instance_of? URI::HTTPS
#       http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#       http.read_timeout = 10 # seconds
#
#       # --header 'Content-Type:application/json' --header 'Accept:application/json'
#       # puts url.path
#       # puts url.full_path
#       # puts "#{url.path}?#{url.query}"
#
#
#
#
#       # request = Net::HTTP::Post.new(uri.path, request_header)
#
#
#       # request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'Content-Type' =>'application/json', 'Accept'=>'application/json'})
#
#
#       # request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json'})
#
#
#       request = Net::HTTP::Post.new(url, {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json','User-Agent'=>"Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"})
#
#       # request['x-api-key'] = 'DCTIoTCovid19'
#       request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
#       # {"hn"=>"", "weight"=>"90.00", "height"=>"180.00", "bmi"=>"27.78", "pr"=>"80", "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "time"=>"23:44:41", "date"=>"2021-05-12", "serial_number"=>"00000"}
#
#       px = params
#
#       ## modify bp
#
#
#
#       px['rr'] = "" unless px['rr']
#
#
#
#       pd = {}
#       # pd['x-api-key'] = 'DCTIoTCovid19'
#       pd['FHN'] = px['hn']
#       pd['FHN'] = '2021000008'
#       pd['date'] = px['date']
#       pd['time'] = px['time']
#       pd['round'] = "0"
#       # pd['doci'] = "0"
#       pd['temperature'] = px['temp'].to_f
#       # pd['respiration_rate'] = nil
#       pd['pulse_rate'] = px['pr'].to_i
#
#       pd['systolic_blood_pressure'] = px['bp_sys'].to_i
#       pd['diastolic_blood_pressure'] = px['bp_dia'].to_i
#
#       pd['oxygen_saturation'] = px['spo2'].to_i
#       pd['oxygen_saturation3min'] = px['spo2'].to_i
#
#
#
#       puts pd.inspect
#
#
#
#       # {"hn"=>"280", "weight"=>"90.0", "bp"=>"120/80", "bp_sys"=>"120", "bp_dia"=>"80", "bp_mean"=>nil, "height"=>"180.0", "bmi"=>nil, "pr"=>"80",
#  #      "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "serial_number"=>"00000", "time"=>"00:26:14", "date"=>"2021-05-13"}
#  #
#  #
#
#
#
#       # request.set_form_data(pd)
#       request.body = pd
#       # puts px.to_json
#    #    request.body = px.to_json
#
#
#       # response = Net::HTTP.start(url.host, url.port, :open_timeout => 5, :read_timeout => 10) {|http|
#       #
#       #
#       #    http.request(request)
#       #
#       #  }
#
#
#       response = http.request(request)
#
#
#
#
#
#
#
#
#
#
#
#
#       puts "RESPONSE #{response.body}"
#
#       result = JSON.parse response.body
#
#
#
#     rescue Exception => e
#       puts e.inspect
#       error = true
#       err_msg = "Server Timeout!"
#     end
#
#
#     if result['status'] == "200 OK"
#
#       return {:status=>"200 OK", :msg=>'SUCCESS'}.to_json
#
#     else
#
#       return {:status=>"404 ERROR", :msg=>result['message']}.to_json
#
#     end
#
#   end
#
#
#   get '/test_get_patient' do
#
#     content = <<CNX
#     {
#     "personKey": "4578484884", "hn": "#{params[:hn]}", "pid": "3840100269238", "pname": "นาย",
#     "fname": "S#{params[:hn]}", "lname": "Kulawonganunchai",
#     "birth": "28042526", "gender": "1", "fullName": "Supasak Kulawonganunchai", "employeeCode": "XXXX"
#     }
# CNX
#     content = <<CNX
#     {
#     "title": "นาย", "hn": "#{params[:hn]}", "name": "สมชาย",
#     "lastname": "รักเรียน", "sex": "ชาย"
#     }
# CNX
# return content
#
#   end
#
#
#   post '/test_send' do
#
#
#     result = nil
#
#
#     puts params.inspect
#
#
#
#       return {:status=>"200 OK", :msg=>'SUCCESS', :post=>params.inspect }.to_json
#
#
#
#   end
#
#   get '/' do
#
#      if login
#
#        return "Login with accessToken : #{settings.token}"
#
#
#      else
#
#        return "Error Login"
#
#      end
#   end
#
#   #class App < Sinatra::Base
#     # This action responds to POST requests on the URI '/billcrux/register'
#     # and is responsible for handeling registration requests with the
#     # BillCrux payment system.
#   #   # The
#   #   lm = Time.now.strftime("%m")
#   #   tw = 0
#   #
#   #   get '/' do
#   #
#   #
#   #     if true or  lm != Time.now.strftime("%m")
#   #
#   #     #puts "Random"
#   #     tw = "#{rand(20)+100}"
#   #     lm = Time.now.strftime("%m")
#   #     # tw = 0.0
#   #     end
#   #
#   #
#   #     content = <<SECA
#   #
#   #     <!doctype html>
#   #     <html lang="de">
#   #     <head>
#   #         <title>Alibaba WebInterface</title>
#   #         <table>
#   #             <tr>
#   #                 <td>WebServer</td>
#   #                 <td>Version 1.1</td>
#   #             </tr>
#   #             <tr>
#   #                 <td>
#   #                     <br>
#   #                 </td>
#   #             </tr>
#   #             <tr>
#   #                 <td>Name</td>
#   #                 <td>scaler01</td>
#   #             </tr>
#   #             <tr>
#   #                 <td>Scale Model</td>
#   #                 <td>seca 797</td>
#   #                 <td>05797254208950</td>
#   #             </tr>
#   #             <tr>
#   #                 <td>
#   #                     <br>
#   #                 </td>
#   #             </tr>
#   #             <tr>
#   #                 <td>Current Weight</td>
#   #                 <td>#{(rand(20)+100).to_f}</td>
#   #                 <td>kg</td>
#   #             </tr>
#   #             <tr>
#   #                 <td>Trig. Weight</td>
#   #                 <td>#{tw.to_f}</td>
#   #                 <td>kg</td>
#   #             </tr>
#   #             <tr>
#   #                 <td>Height</td>
#   #                 <td>1.700</td>
#   #                 <td>m</td>
#   #             </tr>
#   #             <tr>
#   #                 <td>Scan Value</td>
#   #                 <td></td>
#   #             </tr>
#   #         </table>
#   #     </head>
#   #     <body>
#   #         <h3>CONFIG</h3>
#   #         <form method="get">
#   #             <p>
#   #                 Login-Pwd
#   #                 <input type="password" name="LoginPwd" size=32 maxlength=59>
#   #             <p>
#   #                 <input type="submit" value="Submit">
#   #         </form>
#   #     </body>
#   #     <br>
#   #     <br>
#   #     Copyright © 2018 seca gmbh & co. kg. All rights reserved.
#   #     </html>
#   #
#   #
#   #
#   # SECA
#   #
#   # return content
#   #
#   #
#   #   end
