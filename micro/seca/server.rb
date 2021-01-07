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
 


  get '/' do 
	puts params.inspect      
      erb :index, :locals => {:params=> params}
		
  end

  get '/get' do 
	
  
  
    seca_uri = URI('http://192.168.4.1/')
    
    
    begin
    


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
                <td>100.0</td>
                <td>kg</td>
            </tr>
            <tr>
                <td>Height</td>
                <td>107.000</td>
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
    
   req = Net::HTTP::Get.new(seca_uri.to_s)

   # setting both OpenTimeout and ReadTimeout
   res = Net::HTTP.start(seca_uri.host, seca_uri.port, :open_timeout => 0.5, :read_timeout => 0.5) {|http|

        http.request(req)

   }

   content = res.body
    
    document = Nokogiri::HTML(content)
    tags = document.xpath("//td")
    
    current_height = nil
    current_weight = nil
    trig_weight = nil
    
    tags.each_with_index do |t,ti|
     
      current_height = t.text.strip if ti==16
      current_weight = t.text.strip if ti==13  
      trig_weight = t.text.strip if ti==10
      
      
    end
        
      
      if current_height and current_weight and current_height.to_f > 0 and current_weight.to_f > 0
        
        
        return "{\"time\":#{Time.now.to_json},\"status\":\"ok\",\"weight\":#{current_weight},\"height\":#{current_height}}"
        
      end
      
      
      
    rescue Net::ReadTimeout => exception
            # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (ReadTimeout)"
            msg = "NOT reachable (ReadTimeout)"
       #      sleep 10
    rescue Net::OpenTimeout => exception
            # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
            msg = "NOT reachable (OpenTimeout)"
           #  sleep 10
    rescue Exception =>exception        
            # STDERR.puts "#{seca_uri.host}:#{seca_uri.port} is NOT reachable (OpenTimeout)"
            msg = exception.to_s
          #   sleep 10
    end
        
      
      return "{\"time\":#{Time.now.to_json},\"status\":\"error\",\"msg\":\"#{msg}\",\"temp\":`vcgencmd measure_temp | egrep -o '[0-9]*\.[0-9]*'`}"  	

  end

  post '/send' do 

      redirect "/"	
  end

#end




# Rack::Handler::Thin.run App.new, :Port => 80, :Host=>'0.0.0.0'