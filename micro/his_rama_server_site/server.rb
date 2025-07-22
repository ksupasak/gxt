require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'
require 'cgi'

  set :bind, '0.0.0.0'
  set :port, 9293

 
 
  set :endpoint, 'http://d-frontserv1.rama.mahidol.ac.th:9293'

  puts settings.endpoint


  before do
    request.body.rewind
    @request_payload = CGI::parse(request.body.read)
  end

  post '/api/client/login' do
    
    
    puts '============== Header ================'
    
    request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
    
    content = <<CNX
    {
    "data": {
    "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImJjZjZlNGVmZjUxZGQ3Y2Q1NWE2ODUwMjEzNj Y5ZDg2N2I2ZWJkYTI2ZDgxYjI1ZGE2NzlkZTFhNDJkOTk5NmJjMmQ5NzdhZjYxNTI4Yzk1In0.eyJhdW QiOiIxIiwianRpIjoiYmNmNmU0ZWZmNTFkZDdjZDU1YTY4NTAyMTM2NjlkODY3YjZlYmRhMjZkODFi MjVkYTY3OWRlMWE0MmQ5OTk2YmMyZDk3N2FmNjE1MjhjOTUiLCJpYXQiOjE2MjAwMjIwNjgsIm5i ZiI6MTYyMDAyMjA2OCwiZXhwIjoxNjUxNTU4MDY4LCJzdWIiOiIxMyIsInNjb3BlcyI6W119..........NdY4",
    "expiresIn": 31622399,
    "scopes": [] },
    "success": true,
    "errorTexts": [] }
CNX

     
     
     return content
    
  end

  
  
  post '/api/MR/Patients/GetPatientProfileByMrn' do 

    puts '============== Header ================'
    
    request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
    

    
    puts @request_payload
    
    content = <<CNX
    {
    "data": {
    "patientCode": "4210003", "titleName": "นาย", "firstName": "ศุภศักดิ์", "lastName": "กุลวงศ์อนันชัย", "middleName": "", "titleNameEn": "MR", "firstNameEn": "Supasak", "lastNameEn": "", "middleNameEn": "", "gender": "M", "dateOfBirth": "1983-04-28"
    },
    "success": true, "errorTexts": null
    }
CNX

     
     
     return content   
    
  end

  
  post '/api/VitalSign/SaveVitalSigns' do 

    puts '============== Header ================'
    
    request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
    
    # puts request.body.read
  
    puts JSON.parse(@request_payload.keys[0])
    
    content = <<CNX
    {
    "success": true,
    "errorTexts": [],
    "data": [] }
CNX

     
     
     return content   
    
  end

