require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'
set :bind, '0.0.0.0'
set :port, 9292


#class App < Sinatra::Base
  # This action responds to POST requests on the URI '/billcrux/register'
  # and is responsible for handeling registration requests with the
  # BillCrux payment system.
  # The
  lm = Time.now.strftime("%m")
  tw = 0

  get '/' do 


    if true or  lm != Time.now.strftime("%m")
    
    #puts "Random"
    tw = "#{rand(20)+100}" 
    lm = Time.now.strftime("%m")
    # tw = 0.0
    end
     

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
                <td>#{(rand(20)+100).to_f}</td>
                <td>kg</td>
            </tr>
            <tr>
                <td>Trig. Weight</td>
                <td>#{tw.to_f}</td>
                <td>kg</td>
            </tr>
            <tr>
                <td>Height</td>
                <td>1.700</td>
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

return content

		
  end



  get '/get_patient_by_hn' do 
  
   hn = params[:hn]  
  
  ##############################################################
    
  his_get_patient_uri = URI("http://xxxx/patient/#{hn}")
    
  # his_get_patient_uri = URI("http://172.20.10.5:9292/test_get_patient?hn=#{hn}")
  
  his_get_patient_uri = URI("http://10.99.0.109/systemx-poc/api/patient/#{hn}")
  
 

  his_get_patient_uri = URI("https://cnmi-his.rama.mahidol.ac.th/apis/IME/get_demographic/hn/#{hn}/")
  
  his_get_patient_uri = URI("http://10.58.249.94/apis/IME/get_demographic/hn/#{hn}/")
  
    
  ##############################################################  
  
 
    
  robj = {:hn=>params[:hn]}
  
  
  msg = nil
  
  begin
  
  content = "{}"    
  
  unless params[:debug]    
  
    puts 'xxxxx send get his'
  req = Net::HTTP::Get.new(his_get_patient_uri.to_s)
  #
  # # setting both OpenTimeout and ReadTimeout
  # res = Net::HTTP.start(his_get_patient_uri.host, his_get_patient_uri.port, :open_timeout => 0.5, :read_timeout => 0.5) {|http|
  #
  #      http.request(req)
  #
  # }


  http = Net::HTTP.new(his_get_patient_uri.host, his_get_patient_uri.port)
  # http.use_ssl = true #if uri.instance_of? URI::HTTPS
  # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  http.read_timeout = 10 # secon
  
  res =  http.request(req)



  content = res.body  
  
  puts content
  
  else
  
    content = <<CNX
    {
    "personKey": "4578484884", "hn": "153174XX", "pid": "3840100269238", "pname": "นาย",
    "fname": "Supasak", "lname": "Kulawonganunchai",
    "birth": "28042526", "gender": "1", "fullName": "Supasak Kulawonganunchai", "employeeCode": "XXXX"
    }
CNX
  
  end

   
  obj = JSON.parse(content)
  
  robj = {}
  
  # birth_date = Date.new obj['birth'][4..7].to_i-543, obj['birth'][2..3].to_i, obj['birth'][0..1].to_i
  # birth_date = Date.new obj['birth'][0..3].to_i, obj['birth'][4..5].to_i, obj['birth'][6..7].to_i
  
  
  # {"hn":"C3344","initial_name":"นาง","first_name":"ทัศนีย์","last_name":"ปิ่นปั่น","middle_name":"","initial_name_eng":"Mrs.","first_name_eng":"Tasanee","last_name_eng":"Pinpan","middle_name_eng":"","id_card_no":"3670300238028","nation_code":1,"nationality":"ไทย","dob":"1981-01-07","gender":"F","address":"270 โรงพยาบาลรามาธิบดี พระราม 6 ทุ่งพญาไท","amphur":"เขตราชเทวี","province":"กรุงเทพมหานคร","zipcode":"10400","tel_no":"","mobile_no":"089-1139055","email":"tpinpan@gmail.com","emergency_contact":"270 โรงพยาบาลรามาธิบดี พระราม 6 แขวง ทุ่งพญาไท เขต เขตราชเทวี จังหวัด กรุงเทพมหานคร ประเทศไทย","photo":"","encounters":[]}%
  
  
  puts obj.inspect 

  
  
  robj[:hn] = obj['hn']
  # robj[:pid] = obj['pid']
  robj[:first_name] = obj['first_name']
  robj[:last_name] = obj['last_name']
  robj[:prefix_name] = obj['initial_name']
  robj[:gender] = obj['gender']
  # robj[:birth_date] = birth_date
  robj[:birth_date] = obj['dob']
  # robj[:age] = 
  robj[:full_name] = "#{obj['initial_name']}#{obj['first_name']} #{obj['last_name']}"
  
  
  result = {:status=>'200 OK', :record=>robj}
  
  
  
    
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
          
          result = {:status=>'404 ERROR', :msg=>msg}
  end
  

  return result.to_json
	
  end
  
  


  post '/send' do 


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
    
    his_post_opd_url = URI("https://cnmi-his.rama.mahidol.ac.th/apis/PTM/set_smart_vital_sign/")
    
    his_post_opd_url = URI("https://10.58.249.83/apis/PTM/set_smart_vital_sign/")
    
    his_post_opd_url = URI("http://10.58.249.94/apis/PTM/set_smart_vital_sign/")
    
   

    
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
      # http.use_ssl = true #if uri.instance_of? URI::HTTPS
     #  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10 # seconds
      
      # --header 'Content-Type:application/json' --header 'Accept:application/json'
      # puts url.path
      # puts url.full_path
      # puts "#{url.path}?#{url.query}"
      
  
     

      # request = Net::HTTP::Post.new(uri.path, request_header)
      
      
      request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'Content-Type' =>'application/json', 'Accept'=>'application/json'})
 
      # {"hn"=>"", "weight"=>"90.00", "height"=>"180.00", "bmi"=>"27.78", "pr"=>"80", "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "time"=>"23:44:41", "date"=>"2021-05-12", "serial_number"=>"00000"}
 
      px = params
 
      ## modify bp
      
      sys = px['bp_sys']
      dia = px['bp_dia']
      mean = px['bp_mean']
      pr = px['pr']
      
      
      px.delete 'bp_sys'
      px.delete 'bp_dia'
      px.delete 'bp_mean'
      px.delete 'bp'
      px.delete 'pr'
      
      
      px['systolic'] = sys
      px['diastolic'] = dia
      px['mean'] = mean
      px['pulse'] = pr
      
      
      
      px['rr'] = "" unless px['rr']
      px['date'] = Time.now.strftime("%Y-%m-%d")
      px['time'] = Time.now.strftime("%H:%M:%S")
      
      
      # {"hn"=>"280", "weight"=>"90.0", "bp"=>"120/80", "bp_sys"=>"120", "bp_dia"=>"80", "bp_mean"=>nil, "height"=>"180.0", "bmi"=>nil, "pr"=>"80",
 #      "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "serial_number"=>"00000", "time"=>"00:26:14", "date"=>"2021-05-13"}
 #
 #
      
      
 
      request.set_form_data(px)
 #      puts px.to_json
 #      request.body = px.to_json
    
      
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
      error = true
      err_msg = "Server Timeout!"
    end
    
    return {:status=>"200 OK", :msg=>'SUCCESS'}.to_json
   

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
