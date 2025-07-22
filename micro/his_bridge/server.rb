# encoding: utf-8

require 'json'

require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'


set :bind, '0.0.0.0'
set :port, 9292


get '/his/get_patient_info' do 


    
    uri = URI("http://170.100.50.10:9292#{URI(request.url).request_uri}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.instance_of? URI::HTTPS
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.read_timeout = 2 # seconds
        

    # request = Net::HTTP::Post.new(uri.request_uri)
  
    request = Net::HTTP::Get.new(uri.request_uri)
   
    response = http.request(request)
     
     
    return response.body
	  
  end
  
  
  






