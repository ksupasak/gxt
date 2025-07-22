require_relative 'lib/tempus'
require "active_support"

require "active_support/core_ext/date/calculations"

# gw = Tempus::Gateway.new :key=> 'nRHprq9d0Y9UefyxJ3buzZp0Do5RpFtacxzDyRK77VQ=', :iv=>'Nki18CKUFhH5CrI3TAaWdg==', :username=>'A5yPKnq8yLJKwtxOnyfhACcsWVpUYUj63VbsDCTdy+D+GGa4rnJATz1bvnPCU+/8', :password=>'gcbfEBUB3nQc+nCsjMknLiqmk+lbbF6l0Leuv+ZY+1I=', :url=>'https://corsium.com.au/WebAPI/chula'
gw = Tempus::Gateway.new :username=>'686d4517-bd7f-4b8d-9ece-7a6ce799ad6f', :password=>'3P(RTe$t1n9', :url=>'https://corsium.info/WebAPI/sdkencr'


org_id = gw.get_organization


puts org_id

# incidents = gw.get_incidents datetime
incidents = gw.get_incidents :device_id=>'111002', :from_date => Time.now.to_date.at_beginning_of_month


puts incidents.inspect 


# https://corsium.info/WebAPI/sdk/Api/Clinical/Incidents/FA68370A-BF24-4BD1-99BE- DF946C8ECDDE/TrendedVitals

incidents.size 

if incidents.size > 0 
  
  id = incidents[0]['IncidentId']

  
  
  while(true)
  
  ts = Time.now 
  datetime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
  # vitals = gw.get_trended_vitals id, datetime
  # puts vitals['VitalDetailsInfo'].size.to_s + " #{Time.now.to_f-ts.to_f}"
  
  events = gw.get_events id #, datetime
  puts events['EventsInfo'].size.to_s + " #{Time.now.to_f-ts.to_f}"
  
  twelve_leads_id = nil
  
  for i in events['EventsInfo']
    puts "#{i['EventId']} #{i['EventType']}"
    if i['EventType'] == 'TWELVE_LEADS'
      twelve_leads_id = i['EventId']  
      # puts i['Vitals'].inspect
    end
  end
  
  if twelve_leads_id
    
    gw.download_twelve_leads id, twelve_leads_id, "#{twelve_leads_id}.jpg"
    
    
  end
  
  # gw.download_pdf id, 'report.pdf'
  

  # vitals = gw.get_trended_vitals id

  # puts vitals.inspect 
  
  
  sleep(0.01)
  
  end
  

end

