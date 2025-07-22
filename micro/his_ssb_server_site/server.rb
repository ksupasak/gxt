require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'
require 'cgi'
require 'thin'





class MyThinBackend < ::Thin::Backends::TcpServer
  def initialize(host, port, options)
    super(host, port)
    @ssl = true
    @ssl_options = options
  end
end

configure do
  set :environment, :production
  set :bind, '0.0.0.0'
  set :port, 443
  set :server, "thin"
  class << settings
    def server_settings
      {
        :backend          => MyThinBackend,
        :private_key_file => "../../private.key",
        :cert_chain_file  => "../../server.crt",
        :verify_peer      => false
      }
    end
  end
end



  set :bind, '0.0.0.0'
  set :port, 9293

 
 
  set :endpoint, 'http://d-frontserv1.rama.mahidol.ac.th:9293'

  puts settings.endpoint


  before do
    request.body.rewind
    @request_payload = CGI::parse(request.body.read)
  end



  get '/IVitalSign/AccessToken/Request' do
    

    # request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
    
    content = <<CNX
    {
    "ResponseStatus" : {
    "StatusCode" : "100",
    "Description" : "Success" },
    "Data": {
    "TokenType" : "Bearer",
    "AccessToken" : "IiwibmFtZSI6IkpvaG4gR.....lIiwiaWF0IjoxNTE2MjM5MDI", 
    "AccessTokenExpireUTC" : "20230305151000"
    } 
  }
CNX
      
    return content
    
end
  






  
  
  post '/IVitalSign/GetPatientInfo' do 

    puts '============== Header ================'
    
    # request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
    

    
    puts @request_payload
    
    content = <<CNX
    {
    "ResponseStatus" : {
      "StatusCode" : "100",
      "Description" : "Success" },
    
    "Data" : {
      "VisitType" : "OPD", 
      "VisitDate" : "20200213", 
      "VN" : "0145", 
      "PrescriptionNo" : "1", 
      "HN" : "60-321548",
      "Name" : "นาย สมใจ รกัดี", 
      "NameEnglish" : "Mr Somjai Rakdee", 
      "NameLocal" : "นาย สมใจ รกั ดี",
      "Gender" : "M", 
      "Age" : "23Y 4M 2D", 
      "DOB" : "19900120"
    } 
  }
CNX
   
     
     return content   
    
  end

  
  post '/IVitalSign/UpdateVitalSign' do 

    puts '============== Header ================'
    
    # request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
    

    
    puts  @request_payload
    
    content = <<CNX
    {
    "ResponseStatus" : {
    "StatusCode" : "100",
    "Description" : "Success" }
    }
CNX

     
     
     return content   
    
  end

