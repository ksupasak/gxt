require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'



his_post_opd_url = URI("https://api-covid.wisible.com/v2/addVitalSigns")

url = his_post_opd_url

http = Net::HTTP.new(url.host, url.port)
http.use_ssl = true #if uri.instance_of? URI::HTTPS
http.verify_mode = OpenSSL::SSL::VERIFY_NONE
http.read_timeout = 10 # seconds

   headers = {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json'}

     request = Net::HTTP::Post.new(url, initheader = headers)
     
     # request['x-api-key'] = 'DCTIoTCovid19'
     request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
     # {"hn"=>"", "weight"=>"90.00", "height"=>"180.00", "bmi"=>"27.78", "pr"=>"80", "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "time"=>"23:44:41", "date"=>"2021-05-12", "serial_number"=>"00000"}

     px = {}

     ## modify bp

     
     
     px['rr'] = "" unless px['rr']
     
     
     
     pd = {}
     # pd['x-api-key'] = 'DCTIoTCovid19'
     pd['FHN'] = px['hn']
     pd['FHN'] = '2021000008'
     pd['date'] = "2021-05-27"
     pd['time'] = "18:00:00"
     pd['round'] = "1"
     # pd['doci'] = "0"
     pd['temperature'] = 39.2
     # pd['respiration_rate'] = nil
     pd['pulse_rate'] = 89
     
     pd['systolic_blood_pressure'] = 140
     pd['diastolic_blood_pressure'] = 80
     
     pd['oxygen_saturation'] = 99
     pd['oxygen_saturation3min'] = 99
     
     
     
     puts pd.inspect 
     
     
     
     # {"hn"=>"280", "weight"=>"90.0", "bp"=>"120/80", "bp_sys"=>"120", "bp_dia"=>"80", "bp_mean"=>nil, "height"=>"180.0", "bmi"=>nil, "pr"=>"80",
#      "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "serial_number"=>"00000", "time"=>"00:26:14", "date"=>"2021-05-13"}
#
#
     
     

     request.set_form_data(pd)
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
     
     # result = JSON.parse response.body
     
     
     puts '======================='
     
     
     
     # uri = url
     # req = Net::HTTP::Post.new(uri, initheader = headers)
     # # req.basic_auth 'anystring', 'xxxx'
     # # req.body = URI.encode_www_form({ ... }})
     # request.set_form_data(pd)
     # #
     # # response = Net::HTTP.new(uri.hostname, uri.port).start {|http| http.request(req) }
     # # puts "Response #{response.code} #{response.message}:#{response.body}"
     #
     # http = Net::HTTP.new(url.host, url.port)
     # http.use_ssl = true #if uri.instance_of? URI::HTTPS
     # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
     # http.read_timeout = 10 # seconds
     # response = http.request(request)
     #
     #
     # header = headers
     # data = pd
     # uri = url
     # https = Net::HTTP.new(uri.host,uri.port)
     # https.use_ssl = true
     # req = Net::HTTP::Post.new(uri.path, header)
     # req.body = data.to_json
     # res = https.request(req)
     #
     # puts "Response #{res.code} #{res.message}: #{res.body}"
     #
     #
     #
    # 
    
    
    
    
    
    uri = url #URI.parse("http://localhost:3000/users")

    header = headers
    user = {user: {
                       name: 'Bob',
                       email: 'bob@example.com'
                          }
                }

    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true #if uri.instance_of? URI::HTTPS
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 10 # seconds
    request = Net::HTTP::Post.new(uri.request_uri, header)
    # request.body = user.to_json
    request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
     request.set_form_data(pd)

    # Send the request
    response = http.request(request)
    
    
    
    # response =  Net::HTTP.post url,
  #                   pd.to_json,
  #                  headers
  #
  #
  #
  #
  #
  #
     puts "RESPONSE #{response.body}"
  #
  #
  #
  #
  #
  #
     #
     #
     # uri = url
     # req = Net::HTTP::Post.new(uri,headers)
     # req.set_form_data(pd)
     #
     # res = Net::HTTP.start(uri.hostname, uri.port) do |http|
     #   http.request(req)
     # end
     #
     # case res
     # when Net::HTTPSuccess, Net::HTTPRedirection
     #   # OK
     # else
     #   res.value
     # end
     
     # headers  = {"Referer" => url}"
    #  http     = Net::HTTP.new(url.host)
    #  # response = http.post(url.path, headers)
    #  puts headers.inspect
    #
    # response =  Net::HTTP.post url,
    #                 {}.to_json,
    #                headers
    #    puts "RESPONSE #{response.body}"
     