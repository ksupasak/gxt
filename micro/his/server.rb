require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'
set :bind, '0.0.0.0'
set :port, 3000


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
    
  his_get_patient_uri = URI("http://localhost:9293/test_get_patient?hn=#{hn}")
    
  ##############################################################  
  
 
    
  robj = {:hn=>params[:hn]}
  
  
  msg = nil
  
  begin
  
  content = "{}"    
  
  unless params[:debug]    
  
  
  req = Net::HTTP::Get.new(his_get_patient_uri.to_s)

  # setting both OpenTimeout and ReadTimeout
  res = Net::HTTP.start(his_get_patient_uri.host, his_get_patient_uri.port, :open_timeout => 0.5, :read_timeout => 0.5) {|http|

       http.request(req)

  }

  content = res.body  
  
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
  
  birth_date = Date.new obj['birth'][4..7].to_i-543, obj['birth'][2..3].to_i, obj['birth'][0..1].to_i
  
  
  robj[:hn] = obj['hn']
  robj[:pid] = obj['pid']
  robj[:first_name] = obj['fname']
  robj[:last_name] = obj['lname']
  robj[:prefix_name] = obj['pname']
  robj[:gender] = obj['gender']
  robj[:birth_date] = birth_date
  robj[:age] = (Time.now.to_time.to_i - birth_date.to_time.to_i).to_i / 365 / 86400
  robj[:full_name] = obj['fullName']
  
  
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


    result = {}
    
    hn = params[:hn]
    
    bp = params[:bp].split('/')
    bp_sys = bp[0]
    bp_dia = bp[1]
    
    pr = params[:pr]
    
    weight = params[:weight]
    height = params[:height]
    
    puts params.inspect 
    
    ##############################################################
    
    # his_post_opd_url = URI("http://xxxx/bloodpressure/obd2?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}&height=#{height}&weight=#{weight}")
    
    his_post_opd_url = URI("http://localhost:9293/test_send?hn=#{hn}&systolic=#{bp_sys}&diastolic=#{bp_dia}&pulse=#{pr}&height=#{height}&weight=#{weight}")
    
    ##############################################################

    url = his_post_opd_url
    
   
    error = false
    err_msg = "NA"
    begin
   
      

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 2 # seconds
      
      
      request = Net::HTTP::Post.new(url.path, initheader = {'Content-Type' =>'application/json'})
      # request.set_form_data(px)
        
      
      response = Net::HTTP.start(url.host, url.port, :open_timeout => 1, :read_timeout => 3) {|http| http.request(request)}
      
      puts "RESPONSE #{response.body}"
      
      result = JSON.parse response.body
      
    
      
    rescue Exception => e
      puts e.inspect 
      error = true
      err_msg = "Server Timeout!"
    end
    
   
    if result['status'] == '200 OK'
      
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
return content
    
  end
  
  
  post '/test_send' do 


    result = nil

    
    puts params.inspect 
    

   
      return {:status=>"200 OK", :msg=>'SUCCESS', :post=>params.inspect }.to_json
      
   
    
  end
