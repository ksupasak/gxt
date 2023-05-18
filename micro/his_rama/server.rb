
require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'

require 'websocket-client-simple'

require_relative '../lib/miot'

  set :bind, '0.0.0.0'
  set :port, 9292

 
 
  set :endpoint, 'http://d-frontserv1.rama.mahidol.ac.th'
  # set :endpoint, 'http://d-frontserv1.rama.mahidol.ac.th:9293'

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



  def login 
    
    
      uri = URI("#{settings.endpoint}/api/client/login")
      
      headers = {'Content-Type' =>'application/json'}
      
      data = {}
      
      content = <<CNX
      { "data":
      {
      "username": "test01",
      "password": "test01",
      "appCode": "ITEM_TEST"
      }
    }
  

CNX
      data = JSON.parse(content)
      
      puts data.to_json
    

  #    res = Net::HTTP.post_form  uri, data
      
   #   puts res.body
      

      

      # Full control
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.instance_of? URI::HTTPS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10 # seconds

      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(data)
      
      request.body = data.to_json
      puts "ss #{request.body}"

      # Tweak headers, removing this will default to application/x-www-form-urlencoded
      request["Content-Type"] = "application/json"

      puts '============= DEBUG ==================='
    
      request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
      puts request.inspect 
      

      response = http.request(request)
    
      puts '============= FINISH 2 ==================='
    
    
      
      obj = JSON.parse(response.body)
  
      
      puts obj.inspect 
      
      settings.set :token, obj['data']['accessToken']
      
      return {:r=>obj['success'],:http=>http}
      
      
  end




# service to get patient data

  get '/get_patient_by_hn' do 
  
  hn = params[:hn]  
  
  ##############################################################
  
  puts 'Call get_patient_by_hn'

  begin    

  if ht = login
  
      
      uri = URI("#{settings.endpoint}/api/MR/Patients/GetPatientProfileByMrn")
    
      data = {}
      
      content = <<CNX
      {
      "mrn": "#{hn}"
      }
CNX
      data = JSON.parse(content)
      
      
    

      # Full control
      # http = Net::HTTP.new(uri.host, uri.port)
 #      http.use_ssl = true if uri.instance_of? URI::HTTPS
 #      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 #      http.read_timeout = 10 # seconds
 
       http = ht[:http]
       
       data['accessToken'] = settings.token
      
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(data)
      request.body = data.to_json
      
      puts request.body.inspect

      puts 'tok '+ht.inspect 
      # Tweak headers, removing this will default to application/x-www-form-urlencoded
      request["Content-Type"] = "application/json"
      request["Authorization"] = 'Bearer '+settings.token
      

      puts '============= DEBUG ==================='
    
      request.each_header {|key,value| puts "#{key} = #{value.inspect}" }

      response = http.request(request)
    
      puts '============= FINISH ==================='
    
    
      
      dobj = JSON.parse(response.body)
  
      
      puts dobj.inspect 
      
      obj = dobj['data']
      
      robj = {}
  
      # birth_date = Date.new obj['dateOfBirth'][4..7].to_i-543, obj['dateOfBirth'][2..3].to_i, obj['dateOfBirth'][0..1].to_i
      # birth_date = Date.new obj['dateOfBirth'][0..3].to_i, obj['dateOfBirth'][4..5].to_i, obj['dateOfBirth'][6..7].to_i
      
      
      
      birth_date = Date.parse obj['dateOfBirth']
      
  
      robj[:hn] = hn #obj['patientCode']
      # robj[:pid] = obj['pid']
      robj[:first_name] = obj['firstName']
      robj[:last_name] = obj['lastName']
      robj[:prefix_name] = obj['titleName']
      robj[:gender] = obj['gender']
      robj[:birth_date] = birth_date
      # robj[:age] = 
      robj[:full_name] = "#{obj['name']} #{obj['lastname']}"
  
  
      result = {:status=>'200 OK', :record=>robj}
  
  

      return result.to_json
	
        
  
  else
    
       return "Error Login"
  
  end  
  
rescue Net::ReadTimeout => exception
        # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (ReadTimeout)"
        msg = "NOT reachable (ReadTimeout)"
         result = {:status=>'404 ERROR', :msg=>msg}
   #      sleep 10
rescue Net::OpenTimeout => exception
        # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
        msg = "NOT reachable (OpenTimeout)"
         result = {:status=>'404 ERROR', :msg=>msg}
       #  sleep 10
rescue Exception =>exception        
        # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
        msg = exception.to_s
     puts exception.backtrace
        result = {:status=>'404 ERROR', :msg=>msg}
end
  
puts result.inspect 
  
end
 
 
 
 
 
 
 
# service to get patient data

  post '/send' do 
  
  hn = params[:hn]  
  
  unless hn
    
      result = {:status=>'404 ERROR', :msg=>msg}
      
      return result
    
  else
  
  ##############################################################
  
  puts 'Call send'

  begin    

  if login
  
      
      uri = URI("#{settings.endpoint}/api/VitalSign/SaveVitalSigns")
      
      data = {}
      
      content = <<CNX
      {
      "mrn": "4210003"
      }
CNX
   
   
   
# [{
# "mrn": "0000001",
# "locationId": "",
# "machineId": "110021082417", "physicalExamId": 1,
# "value": "116",
# "unit": "mmHg",
# "recordBy": "machine",
# "recordDate": "15/03/2020 13:26:22.767", "staffId": "",
# "remark": ""
# },{...},{...}]
   
   
      
      senses = {}
   
      senses['bp_sys']=['1', 'SBP','mmHg']
      senses['bp_dia']=['2', 'DBP','mmHg']
      senses['bp_mean']=['3', 'MBP','mmHg']
      senses['pr']=['4', 'PR','bpm']
      senses['temp']=['5', 'BT','C']
      senses['weight']=['6', 'W','kg']
      senses['height']=['7', 'H','cm']
      senses['bmi']=['8', 'BMI','kg/m2']
      senses['spo2']=['9', 'SPO2','%']
      senses['rr']=['10', 'RR','bpm']
      senses['score']=['11','SCORE','']
      senses['avpu']=['12','AVPU','']
      senses['pain']=['13','PAIN','']
      senses['crt']=['14','CRT','']
      
     
      puts
      puts params.inspect 
      puts
      
      list = []
      
      mrn = params[:hn]
      location_id = ''
      exam_id = params[:record_id]
      record_at = Time.parse(params[:record_at])
      staff_id = params[:staff_id]
      
      for s in senses.keys
        v = senses[s]
        if params[s] and params[s].size>0 and params[s] !="-"
            
          data = {}
          data['mrn'] = mrn
          data['locationId'] = location_id
          data['phycialExamId'] = v[0]
          data['machineId'] = params['serial_number']
          # data['phycialExamcode'] = v[0]
          data['value'] = params[s]
          data['unit'] = v[2]
          data['recordBy'] = 'machine'
          data['recordDate'] = record_at.strftime("%d/%m/%Y %H:%M:%S")
          data['staffId'] = staff_id
          data['remark'] = ""  
          
          list << data   
        
        end
      end
   
       
   
   
      data = list
      
      puts data.inspect
    

      # Full control
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true if uri.instance_of? URI::HTTPS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10 # seconds

      request = Net::HTTP::Post.new(uri.request_uri)

 

      # Tweak headers, removing this will default to application/x-www-form-urlencoded
      request["Content-Type"] = "application/json"
      request["Authorization"] = 'Bearer '+settings.token

      puts '============= DEBUG ==================='
    
      request.each_header {|key,value| puts "#{key} = #{value.inspect}" }


      
      # request.set_form_data(data)
      
      request.body = data.to_json

      response = http.request(request)
    
      puts '============= FINISH ==================='
    
    
      
      dobj = JSON.parse(response.body)
  
      
      puts dobj.inspect 


      
      if dobj['success']==true 
        
        result = {:status=>'200 OK', :msg=>dobj.to_json}      
      else
        result = {:status=>'404 ERROR', :msg=>dobj.to_json}
      end
      
  


      begin
        
          name = 'NA'
          
          name = params[:serial_number] if params[:serial_number] and params[:serial_number].size>0 and params[:serial_number]!="-"
          
          stamp = record_at
          data = {}
          ref = mrn
          # data[:bp] = '120/90'
     #      data[:pr] = 60 + rand(60)
     #      data[:hr] = data[:pr]
     #      data[:rr] = 18 + rand(4)
     #      data[:temp] = 36 + rand(4)
     #      data[:spo2] = 90+rand(10)
     #
          
      
          for s in senses.keys
            v = senses[s]
            
            if params[s] and params[s].size>0 
              
              data[s.to_sym] = params[s]
          
            end
            
          end
          
          
          
          
          data[:bp_stamp] = record_at.strftime("%H%M%S")
          msg = <<MSG
Data.Spot device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
          # puts msg

          puts 'Start Sent Data '+msg

          ws.send(msg)

        rescue Exception=>e
          puts e.inspect
          puts e.backtrace
        end




      return result.to_json
	
        
  
  else
    
       return "Error Login"
  
  end  
  
rescue Net::ReadTimeout => exception
        # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (ReadTimeout)"
        msg = "NOT reachable (ReadTimeout)"
         result = {:status=>'404 ERROR', :msg=>msg}
   #      sleep 10
rescue Net::OpenTimeout => exception
        # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
        msg = "NOT reachable (OpenTimeout)"
         result = {:status=>'404 ERROR', :msg=>msg}
       #  sleep 10
rescue Exception =>exception        
        # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
        msg = exception.to_s
        puts msg
         puts exception.backtrace
        result = {:status=>'404 ERROR', :msg=>msg}
end
  
puts result.inspect 


end
  
end


  post '/send2' do 


    puts params.inspect 

    result = {}
    
    hn = params[:hn]

    pr = params[:pr]
    
    weight = params[:weight]
    height = params[:height]
    
    puts params.inspect 
    
    ##############################################################
    
    # his_post_opd_url = URI("http://xxxx/bloodpressure/obd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}&height=#{height}&weight=#{weight}")
    
    his_post_opd_url = URI("http://localhost:9292/test_send?hn=#{hn}")
    
    his_post_opd_url = URI("https://10.58.249.83/apis/PTM/set_smart_vital_sign/")
    
    his_post_opd_url = URI("https://api-covid.wisible.com/v2/addVitalSigns")
    
    
    # his_post_opd_url = URI("http://172.20.10.5:9292/test_send?hn=#{hn}")
    
    
    
    # if weight !="-" and height !="-" and weight != '0.0' and height != '0.0'
    # his_post_opd_url = URI("http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}&height=#{height}&weight=#{weight}")
    # else
    # his_post_opd_url = URI("http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}")
    # end
    puts 'yyyy'
    puts his_post_opd_url
   # http://10.99.0.109/systemx-poc/medicaldevice/bloodpressure/opd2?hn=111&systolic=222&diastolic=333&pulse=444&weight=555&height=666&waist=777
    
    
    ##############################################################

    url = his_post_opd_url
    
   
    error = false
    err_msg = "NA"
    begin
   
      
      # uri = URI.parse(encoded_url)
   #      http = Net::HTTP.new(uri.host, uri.port)
   #      http.use_ssl = true if uri.instance_of? URI::HTTPS
   #      request = Net::HTTP::Post.new(uri.request_uri)
      
   
   
   
   
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true #if uri.instance_of? URI::HTTPS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10 # seconds
      
      # --header 'Content-Type:application/json' --header 'Accept:application/json'
      # puts url.path
      # puts url.full_path
      # puts "#{url.path}?#{url.query}"
      
  
     

      # request = Net::HTTP::Post.new(uri.path, request_header)
      
      
      # request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'Content-Type' =>'application/json', 'Accept'=>'application/json'})
 
 
      # request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json'})
    
      
      request = Net::HTTP::Post.new(url, {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json','User-Agent'=>"Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"})
      
      # request['x-api-key'] = 'DCTIoTCovid19'
      request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
      # {"hn"=>"", "weight"=>"90.00", "height"=>"180.00", "bmi"=>"27.78", "pr"=>"80", "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "time"=>"23:44:41", "date"=>"2021-05-12", "serial_number"=>"00000"}
 
      px = params
 
      ## modify bp

      
      
      px['rr'] = "" unless px['rr']
      
      
      
      pd = {}
      # pd['x-api-key'] = 'DCTIoTCovid19'
      pd['FHN'] = px['hn']
      pd['FHN'] = '2021000008'
      pd['date'] = px['date']
      pd['time'] = px['time']
      pd['round'] = "0"
      # pd['doci'] = "0"
      pd['temperature'] = px['temp'].to_f
      # pd['respiration_rate'] = nil
      pd['pulse_rate'] = px['pr'].to_i
      
      pd['systolic_blood_pressure'] = px['bp_sys'].to_i
      pd['diastolic_blood_pressure'] = px['bp_dia'].to_i
      
      pd['oxygen_saturation'] = px['spo2'].to_i
      pd['oxygen_saturation3min'] = px['spo2'].to_i
      
      
      
      puts pd.inspect 
      
      
      
      # {"hn"=>"280", "weight"=>"90.0", "bp"=>"120/80", "bp_sys"=>"120", "bp_dia"=>"80", "bp_mean"=>nil, "height"=>"180.0", "bmi"=>nil, "pr"=>"80",
 #      "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "serial_number"=>"00000", "time"=>"00:26:14", "date"=>"2021-05-13"}
 #
 #
      
      
 
      # request.set_form_data(pd)
      request.body = pd
      # puts px.to_json
   #    request.body = px.to_json
    
      
      # response = Net::HTTP.start(url.host, url.port, :open_timeout => 5, :read_timeout => 10) {|http|
      #
      #
      #    http.request(request)
      #
      #  }
      
      
      response = http.request(request)
      
      
      
      
      
      

      
      
      
      
      
      puts "RESPONSE #{response.body}"
      
      result = JSON.parse response.body
      
    
      
    rescue Exception => e
      puts e.inspect 
       puts exception.backtrace
      error = true
      err_msg = "Server Timeout!"
    end
    
   
    if result['status'] == "200 OK"
      
      return {:status=>"200 OK", :msg=>'SUCCESS'}.to_json
      
    else
      
      return {:status=>"404 ERROR", :msg=>result['message']}.to_json
      
    end
    
  end
  
  
  get '/test_get_patient' do
    
    content = <<CNX
    {
    "personKey": "4578484884", "hn": "#{params[:hn]}", "pid": "3840100269238", "pname": "นาย",
    "fname": "S#{params[:hn]}", "lname": "Kulawonganunchai",
    "birth": "28042526", "gender": "1", "fullName": "Supasak Kulawonganunchai", "employeeCode": "XXXX"
    }
CNX
    content = <<CNX
    {
    "title": "นาย", "hn": "#{params[:hn]}", "name": "สมชาย",
    "lastname": "รักเรียน", "sex": "ชาย"
    }
CNX
return content
    
  end
  
  
  post '/test_send' do 


    result = nil

    
    puts params.inspect 
    

   
      return {:status=>"200 OK", :msg=>'SUCCESS', :post=>params.inspect }.to_json
      
   
    
  end

  get '/' do
    
     if login
     
       return "Login with accessToken : #{settings.token}"
     
     
     else
       
       return "Error Login"
     
     end
  end
  
  
  get '/records' do
    

    if ht = login
  
      
        uri = URI("#{settings.endpoint}/api/VitalSign/searchVitalSignsByMRNAndDate?mrn=1000782&startDate=18/05/2023&endDate=20/05/2023")
    
        data = {}

        # Full control
        # http = Net::HTTP.new(uri.host, uri.port)
   #      http.use_ssl = true if uri.instance_of? URI::HTTPS
   #      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
   #      http.read_timeout = 10 # seconds
 
         http = ht[:http]
       
         data['accessToken'] = settings.token
      
        request = Net::HTTP::Post.new(uri.request_uri)
    
 
        # Tweak headers, removing this will default to application/x-www-form-urlencoded
        request["Content-Type"] = "application/json"
        request["Authorization"] = 'Bearer '+settings.token
      

        puts '============= DEBUG ==================='
    
        # request.each_header {|key,value| puts "#{key} = #{value.inspect}" }

        response = http.request(request)
    
        puts '============= FINISH ==================='
    
    
        puts response.body
        
        @dobj = JSON.parse(response.body)
        
        erb :records
        
      end
  


  end
  
  
  post '/sendx' do
    
    puts params.inspect 
    
  end
  
  


  #class App < Sinatra::Base
    # This action responds to POST requests on the URI '/billcrux/register'
    # and is responsible for handeling registration requests with the
    # BillCrux payment system.
  #   # The
  #   lm = Time.now.strftime("%m")
  #   tw = 0
  #
  #   get '/' do
  #
  #
  #     if true or  lm != Time.now.strftime("%m")
  #
  #     #puts "Random"
  #     tw = "#{rand(20)+100}"
  #     lm = Time.now.strftime("%m")
  #     # tw = 0.0
  #     end
  #
  #
  #     content = <<SECA
  #
  #     <!doctype html>
  #     <html lang="de">
  #     <head>
  #         <title>Alibaba WebInterface</title>
  #         <table>
  #             <tr>
  #                 <td>WebServer</td>
  #                 <td>Version 1.1</td>
  #             </tr>
  #             <tr>
  #                 <td>
  #                     <br>
  #                 </td>
  #             </tr>
  #             <tr>
  #                 <td>Name</td>
  #                 <td>scaler01</td>
  #             </tr>
  #             <tr>
  #                 <td>Scale Model</td>
  #                 <td>seca 797</td>
  #                 <td>05797254208950</td>
  #             </tr>
  #             <tr>
  #                 <td>
  #                     <br>
  #                 </td>
  #             </tr>
  #             <tr>
  #                 <td>Current Weight</td>
  #                 <td>#{(rand(20)+100).to_f}</td>
  #                 <td>kg</td>
  #             </tr>
  #             <tr>
  #                 <td>Trig. Weight</td>
  #                 <td>#{tw.to_f}</td>
  #                 <td>kg</td>
  #             </tr>
  #             <tr>
  #                 <td>Height</td>
  #                 <td>1.700</td>
  #                 <td>m</td>
  #             </tr>
  #             <tr>
  #                 <td>Scan Value</td>
  #                 <td></td>
  #             </tr>
  #         </table>
  #     </head>
  #     <body>
  #         <h3>CONFIG</h3>
  #         <form method="get">
  #             <p>
  #                 Login-Pwd
  #                 <input type="password" name="LoginPwd" size=32 maxlength=59>
  #             <p>
  #                 <input type="submit" value="Submit">
  #         </form>
  #     </body>
  #     <br>
  #     <br>
  #     Copyright © 2018 seca gmbh & co. kg. All rights reserved.
  #     </html>
  #
  #
  #
  # SECA
  #
  # return content
  #
  #
  #   end