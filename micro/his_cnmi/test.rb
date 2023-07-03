
# require 'sinatra'
require 'socket'
# require 'sinatra/base'
require 'net/http'
require 'nokogiri'

  his_get_patient_uri = URI("http://10.58.249.94/apis/IME/get_demographic/hn/C834/")
  
  
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
  
  puts 'start request'
  res =  http.request(req)



  content = res.body  
  
  puts content