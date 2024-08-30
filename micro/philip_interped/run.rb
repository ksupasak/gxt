require 'net/http'
require 'uri'
require 'json'
require "base64"

# Define the URL to send the POST request to
# url = URI.parse('https://www.philips-emergencycare.com/Account/APILogin')
url = URI.parse('https://au.philips-emergencycare.com/Account/APILogin')


# Create the HTTP object
# http = Net::HTTP.new(url.host, url.port)
# Set the request body with the username and password
# request.body = {username: 'ksupasak@gmail.com', password: 'SCU_1234'}.to_json



# request.body = {username: 'triple.s.mos@gmail.com', password: 'PHDsyd115/122'}.to_json


# puts url.path


Net::HTTP.start(url.host, url.port, :use_ssl => true) do |http|


# Create the request
  request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/x-www-form-urlencoded','Accept'=>'Application/json'})
   request.body = "username=#{'ksupasak@gmail.com'}&password=#{'SCU_1234'}"
  # request.body = "username=triple.s.mos@gmail.com&password=PHDsyd115/122";
  

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
  
  if false

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
    puts "======================================"
    sleep(2)
  end

  
  
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

