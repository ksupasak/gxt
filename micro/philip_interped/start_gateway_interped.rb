require_relative 'lib/ws'
require "active_support"
require "eventmachine"
require "active_support/core_ext/date/calculations"
require 'sinatra'
require 'sinatra/base'


require 'net/http'
require 'uri'
require 'json'
require "base64"






def run(opts)

  # Start he reactor
  EM.run do


# Define the URL to send the POST request to
# url = URI.parse('https://www.philips-emergencycare.com/Account/APILogin')
url = URI.parse('https://au.philips-emergencycare.com/Account/APILogin')

server  = opts[:server] || 'thin'
host    = opts[:host]   || '0.0.0.0'
port    = opts[:port]   || '2424'
web_app = opts[:app]

dispatch = Rack::Builder.app do
  map '/' do
    run web_app
  end
end

# NOTE that we have to use an EM-compatible web-server. There
# might be more, but these are some that are currently available.
unless ['thin', 'hatetepe', 'goliath'].include? server
  raise "Need an EM webserver, but #{server} isn't"
end

# Start the web server. Note that you are free to run other tasks
# within your EM instance.
# Rack::Server.start({
#   app:    dispatch,
#   server: server,
#   Host:   host,
#   Port:   port,
#   signals: false,
# })

# Create the HTTP object
# http = Net::HTTP.new(url.host, url.port)
# Set the request body with the username and password
# request.body = {username: 'ksupasak@gmail.com', password: 'SCU_1234'}.to_json

   ws = web_app.settings.ws

# request.body = {username: 'triple.s.mos@gmail.com', password: 'PHDsyd115/122'}.to_json

mark_dup = {}
# puts url.path


Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|


# Create the request
  request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json'})
  request.body = "username=#{'ksupasak@gmail.com'}&password=#{'SCU_1234'}"
  #request.body = "username=triple.s.mos@gmail.com&password=PHDsyd115/122";
  

  response = http.request request # Net::HTTPResponse object
  
  puts response.body
  all_cookies = response.get_fields('set-cookie')
  cookies_array = Array.new
  all_cookies.each { | cookie |
         cookies_array.push(cookie.split('; ')[0])
     }
  cookies = cookies_array.join('; ')
  puts
  
  
  request = Net::HTTP::Get.new '/Api/Organizations',  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}
  
  response = http.request request # Net::HTTPResponse object
  
  puts response.body
  organizations = JSON.parse(response.body)
  org_id = organizations['Data'][0]['Id']
  # organization
  # {"ErrorMessage":"","IsSuccessful":true,"Data":[{"Id":"41edf04f-aa90-4aab-94bd-b6b73f360411","Name":"DEMO ECIS","Description":""}],"IsRedirect":false,"RedirectUrl":""}
  
  puts "Org : #{org_id}"
  
  
  request = Net::HTTP::Get.new '/Api/Clinical/Incidents',  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}
  request.body = "organizationId=#{org_id}"
  response = http.request request # Net::HTTPResponse object
  incidents = JSON.parse(response.body)
  incidents['Data'].sort! do |a,b|
    a['LastUpdateTime']<=>b['LastUpdateTime']
  end
  for i in incidents['Data']
    puts "#{i['IncidentId']}\t#{i['LastUpdateTime']}"
  end
  inc_id = incidents['Data'][-1]['IncidentId']
  inc_sn = incidents['Data'][-1]['deviceSerialNumber']
  # puts response.body
  
  # organization
  puts  "Inc : #{inc_id}"
  
  
  
  request = Net::HTTP::Get.new "/Api/Clinical/Incidents/#{inc_id}/Vitals",  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}
  response = http.request request # Net::HTTPResponse object
  
  # puts response.body
  fout = File.open("#{inc_id}_vitals.json",'w')
  vitals = JSON.parse(response.body)
  puts "Vitals = #{vitals['Data'].size}"
  fout.write JSON.pretty_generate(vitals)
  fout.close
  
inc_sn = '100000'


  # organization
  puts
  
   puts  "Event : #{inc_id}\t#{}"
   

  request = Net::HTTP::Get.new "/Api/Clinical/Incidents/#{inc_id}/Events/",  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}
                         
  response = http.request request # Net::HTTPResponse object

  puts response.body


  fout = File.open("#{inc_id}_events.json",'w')
  fout.write JSON.pretty_generate(JSON.parse(response.body))
  fout.close

  puts
  
  #==============
  
  if true

  request = Net::HTTP::Get.new "/Api/Clinical/Incidents/#{inc_id}/TwelveLeads",  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}
  request.body = "withXml=true"
  response = http.request request # Net::HTTPResponse object

  # puts response.body
  #

  fout = File.open("#{inc_id}_twelveleads.xml",'w')
  fout.write response.body
  fout.close

  request = Net::HTTP::Get.new "/Api/Clinical/Incidents/#{inc_id}/TwelveLeads",  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}

  response = http.request request # Net::HTTPResponse object

  fout = File.open("#{inc_id}_twelveleads.json",'w')
  reports = JSON.parse(response.body)
  fout.write JSON.pretty_generate(reports)
  fout.close
  puts
  
  

  for i in reports['Data']
    
    url = "/Api/Clinical/Incidents/#{inc_id}/TwelveLeads/#{i['Id']}"
    puts url 
    request = Net::HTTP::Get.new url,  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}

    response = http.request request # Net::HTTPResponse object

    fout = File.open("#{inc_id}_twelveleads_#{i['Id']}.json",'w')
    report = JSON.parse(response.body)
    fout.write JSON.pretty_generate(reports)
    fout.close
    

    report['Data']['TwelveLeadImages'].each_with_index do |j,ji|
    
    fout = File.open("#{inc_id}_#{i['Id']}_#{ji}.jpg",'w')
    fout.write Base64.decode64(j)
    fout.close


    GXTWS.send_image ws,  {'SN'=>inc_sn}, File.join("#{inc_id}_#{i['Id']}_#{ji}.jpg")
    
    end
    
    
    puts
  
    
  end
  
end
  
  while true 
    
    
    request = Net::HTTP::Get.new "/Api/Clinical/Incidents/#{inc_id}/Vitals",  {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json','Cookie' => cookies}
                         
    response = http.request request # Net::HTTPResponse object

    # puts response.body
    vitals = JSON.parse(response.body)
    puts "Vitals = #{vitals['Data'].size} #{Time.now}"
    for i in vitals['Data']
      puts "#{i['DataAcquisitionTimeUtc']}\t#{i['Name']}\t#{i['Value']}"
    end
    
    GXTWS.send ws, {'SN'=>inc_sn}, vitals, mark_dup
    
    puts "======================================"
    sleep(2)
    
    
    
    
  end

  
  
end


end 

end



# Our simple hello-world app
class HelloApp < Sinatra::Base
  
  
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
    
    # gw = Tempus::Gateway.new :key=> 'nRHprq9d0Y9UefyxJ3buzZp0Do5RpFtacxzDyRK77VQ=', :iv=>'Nki18CKUFhH5CrI3TAaWdg==', :username=>'A5yPKnq8yLJKwtxOnyfhACcsWVpUYUj63VbsDCTdy+D+GGa4rnJATz1bvnPCU+/8', :password=>'gcbfEBUB3nQc+nCsjMknLiqmk+lbbF6l0Leuv+ZY+1I=', :url=>'https://corsium.com.au/WebAPI/chula'
 #    # gw = Tempus::Gateway.new :username=>'686d4517-bd7f-4b8d-9ece-7a6ce799ad6f', :password=>'3P(RTe$t1n9', :url=>'https://corsium.info/WebAPI/sdkencr'
 #
 #    set :gw, gw
 # 
    # org_id = gw.get_organization
   #
   #  set :org_id, org_id
   #
   #  set :live, {}
   #
   opts = {}
    
    ws_host = opts[:ws_host] || 'localhost:1792'
    ws_solution = opts[:ws_solution] || 'miot'

    
    ws = GXTWS::connect ws_solution, ws_host
    puts ws.inspect 
    GXTWS::bind_event ws
    
    set :ws, ws
    
  end
  
 

  # Request runs on the reactor thread (with threaded set to false)
  get '/' do
    
     @org = settings.org_id
     
     erb :home
     
  end

  # Request runs on the reactor thread (with threaded set to false)
  # and returns immediately. The deferred task does not delay the
  # response from the web-service.
  get '/delayed-hello' do
    EM.defer do
      sleep 5
      puts 'ok'
    end
    'I\'m doing work in the background, but I am still free to take requests'
  end
end

while(true)

begin

  run app: HelloApp.new
rescue Exception=>e
  puts e
  puts 'RESET'
end
sleep(1)

end




# request.body = "username=triple.s.mos@gmail.com&password=PHDsyd115/122";
#
# # Send the request and get the response
# response = http.request(request)
#
# # Output the response body
# puts response.body
#
#
# request = Net::HTTP::Get.new()
#
# # request.body = "username=triple.s.mos@gmail.com&password=PHDsyd115/122";
#
# # Send the request and get the response
# response = http.request(request)
#
#
# puts response.body
# # 1.2

