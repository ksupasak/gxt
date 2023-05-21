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
  
  get '/demo' do
    
    


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
                <td>73.2</td>
                <td>kg</td>
            </tr>
            <tr>
                <td>Trig. Weight</td>
                <td>100.0</td>
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
  

  get '/get' do 
	
  
    
    seca_uri = URI('http://192.168.4.1/')
    
 

  temp = 'NA'
    begin
    temp = `vcgencmd measure_temp`.split("=")[-1].split("'")[0]

   rescue

   end
   
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
                <td>73.2</td>
                <td>kg</td>
            </tr>
            <tr>
                <td>Trig. Weight</td>
                <td>100.0</td>
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
   
   unless params[:debug]
 
   req = Net::HTTP::Get.new(seca_uri.to_s)

   # setting both OpenTimeout and ReadTimeout
   res = Net::HTTP.start(seca_uri.host, seca_uri.port, :open_timeout => 0.5, :read_timeout => 0.5) {|http|

        http.request(req)

   }

   content = res.body
    end

	   
    document = Nokogiri::HTML(content)
    tags = document.xpath("//td")
    
    current_height = nil
    current_weight = nil
    trig_weight = nil

   

    tags.each_with_index do |t,ti|
      
      current_height = t.text.strip if ti==16
      current_weight = t.text.strip if ti==10  
      trig_weight = t.text.strip if ti==13
      
 #puts "#{ti}\t#{t.text.strip}"    
    end
      
	

  # puts "X #{current_weight} #{current_height} #{trig_weight} #{temp}"
   
      if current_height and current_weight #and current_height.to_f > 0 and current_weight.to_f > 0
       
        
        
        return "{\"time\":#{Time.now.to_json},\"status\":\"ok\",\"weight\":\"#{current_weight}\",\"height\":\"#{current_height}\",\"trig\":\"#{trig_weight}\",\"temp\":\"#{temp}\"}"
        
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
  #  temp = 'NA'
  #  begin    
  #  temp = `vcgencmd measure_temp`.split("=")[-1].split("'")[0]
   
  # rescue
  
  # end
      return "{\"time\":#{Time.now.to_json},\"status\":\"error\",\"msg\":\"#{msg}\",\"temp\":\"#{temp}\"}"  	

  end

  post '/send' do 

    puts "XXXXX #{params.inspect}"
    
    # req = Net::HTTP::Get.new(seca_uri.to_s)
    #
    # # setting both OpenTimeout and ReadTimeout
    # res = Net::HTTP.start(seca_uri.host, seca_uri.port, :open_timeout => 0.5, :read_timeout => 0.5) {|http|
    #
    #      http.request(req)
    #
    # }
    #
    # content = res.body
    


    # uri = URI('http://172.27.100.40:8899/')
    # uri = URI('http://172.27.200.9:8899/')
    uri = URI('http://172.24.23.250:8899/')
    
    url = uri
    
    # uri = URI('http://www.example.com/search.cgi')
    
    unless params['hn']
      
      puts 'no hn'
      
    else
    
   
    error = false
    err_msg = "NA"
    begin
   
      # res = Net::HTTP.post_form(uri, 'hn' => params[:hn], 'weight' => params[:weight], 'height'=>params[:height])
      
      

      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 2 # seconds
      
      px = params.clone
      
      px[:vn] = px[:hn]
      px.delete :hn

      if px[:height] and h = px[:height].to_f == 0 
        px.delete :height
      end
      if px[:weight] and h = px[:weight].to_f == 0 
        px.delete :weight
      end
      
      if (px[:weight] or px[:height] ) and px[:vn]!=""
      
      request = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
      request.set_form_data(px)
        
      
      response = Net::HTTP.start(url.host, url.port,:open_timeout => 1, :read_timeout => 3) {|http| http.request(request)}
      
      else
    
        error = true
        err_msg = "Invalid Data!"
        
      end
  
    rescue Exception => e
      puts e.inspect 
      error = true
      err_msg = "Server Timeout!"
    end
    
    if error==false
      
      
      redirect '/result'

      
    else
      
      redirect "entry?hn=#{params[:hn]}&weight=#{params[:weight]}&height=#{params[:height]}&err=1&err_msg=#{err_msg}#{'&debug=1' if params[:debug]=='1'}"
      
    end
    
  end
    
    
    
  end
  
  get "/result" do 
    erb :result
  end
  
  get "/error" do 
    erb :error
  end
  
  get "/pad" do
    erb :pad
  end

  get '/entry' do 
      
    erb :entry
  end
  
#end




# Rack::Handler::Thin.run App.new, :Port => 80, :Host=>'0.0.0.0'
