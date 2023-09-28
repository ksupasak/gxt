require_relative 'lib/tempus'
require_relative 'lib/ws'
require "active_support"
require "eventmachine"
require "active_support/core_ext/date/calculations"
require 'sinatra'
require 'sinatra/base'
# gw = Tempus::Gateway.new :key=> 'nRHprq9d0Y9UefyxJ3buzZp0Do5RpFtacxzDyRK77VQ=', :iv=>'Nki18CKUFhH5CrI3TAaWdg==', :username=>'A5yPKnq8yLJKwtxOnyfhACcsWVpUYUj63VbsDCTdy+D+GGa4rnJATz1bvnPCU+/8', :password=>'gcbfEBUB3nQc+nCsjMknLiqmk+lbbF6l0Leuv+ZY+1I=', :url=>'https://corsium.com.au/WebAPI/chula'

require 'fileutils'




def run(opts)

  # Start he reactor
  EM.run do

    # define some defaults for our app
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
    Rack::Server.start({
      app:    dispatch,
      server: server,
      Host:   host,
      Port:   port,
      signals: false,
    })
    
    
    lives = web_app.settings.live
    
    gw = web_app.settings.gw
    ws = web_app.settings.ws
       
    EventMachine.add_periodic_timer(3) {
 
      # puts "run #{Time.now}"
      
    
    
      
      
      online_lives = gw.get_live_incidents
      
      current = {}
      # puts online_lives.size
      for i in online_lives
      
         id = i['IncidentId']
         current[id] = id
         lives[id] = {} unless lives[id]
         lives[id] = i
        
      end
      
      lives.each_pair do |k,v|
        
        unless current[k]
          
          lives.delete k 
          
        end
        
      end
        
        
      puts "Current #{lives.keys.size } #{Time.now}"
       
      
    }
    
    
    
    
    EventMachine.add_periodic_timer(10) {
    
      if lives.keys.size>0 
        
        
        lives.each_pair do |k,v|
          puts k
          datetime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
          
          # vitals = gw.get_trended_vitals k, datetime
          vitals = gw.get_trended_vitals k , datetime
          
          
          
          GXTWS.send ws, v, vitals
          
          
          
          
          events = gw.get_events k , datetime
          
          
          puts events['EventsInfo'].size.to_s + " #{Time.now.to_f-ts.to_f}"
  
          twelve_leads_id = nil
  
          for i in events['EventsInfo']
            puts "#{i['EventId']} #{i['EventType']}"
            if i['EventType'] == 'TWELVE_LEADS'
              twelve_leads_id = i['EventId']  
              # puts i['Vitals'].inspect
            end
          end
  
          if twelve_leads_id and File.exists?(File.join("sent","#{twelve_leads_id}.jpg"))==false
            
            gw.download_twelve_leads id, twelve_leads_id, File.join("data","#{twelve_leads_id}.jpg")
            GXTWS.send_image ws, v, File.join("data","#{twelve_leads_id}.jpg")
            FileUtils.mv(File.join("data","#{twelve_leads_id}.jpg"), File.join("sent","#{twelve_leads_id}.jpg"))

          end
          
          # puts vitals.to_json
          
          # {"DataCaptureTimeUtc"=>"2023-09-14T08:10:00", "Vitals"=>[{"Name"=>"HR", "Value"=>"100", "Measurement"=>"bpm", "Code"=>"", "Source"=>"ECG", "Alert"=>false}, {"Name"=>"SpO2", "Value"=>"96", "Measurement"=>"%", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}, {"Name"=>"Resp", "Value"=>"39", "Measurement"=>"rpm", "Code"=>"", "Source"=>"CAPNO", "Alert"=>false}, {"Name"=>"ETCO2", "Value"=>"43", "Measurement"=>"mmHg", "Code"=>"", "Source"=>"CAPNO", "Alert"=>false}, {"Name"=>"T1", "Value"=>"36.4", "Measurement"=>"C", "Code"=>"", "Source"=>"T1", "Alert"=>false}, {"Name"=>"T2", "Value"=>"35.8", "Measurement"=>"C", "Code"=>"", "Source"=>"T2", "Alert"=>false}, {"Name"=>"PI", "Value"=>"3.7", "Measurement"=>"%", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}, {"Name"=>"PVI", "Value"=>"33", "Measurement"=>"%", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}, {"Name"=>"SpOC", "Value"=>"19", "Measurement"=>"ml/dl", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}, {"Name"=>"SpHb", "Value"=>"12.2", "Measurement"=>"g/dl", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}, {"Name"=>"SpCO", "Value"=>"6", "Measurement"=>"%", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}, {"Name"=>"SpMet", "Value"=>"1.7", "Measurement"=>"%", "Code"=>"", "Source"=>"PULSE", "Alert"=>false}]}
            #
          #
          # for i in vitals['VitalDetailsInfo']
          #
          #    detail = i['Vitals'].collect{|j| "#{j["Name"]} #{j["Value"]}"}.join(", ")
          #
          #    puts "#{i['DataCaptureTimeUtc']}\t#{detail}}"
          #
          # end
          #
         
            
        end
        
        
        
      end
    
    
    }
    
    
  end
end




# Our simple hello-world app
class HelloApp < Sinatra::Base
  
  

  
  
  
  
  # threaded - False: Will take requests on the reactor thread
  #            True:  Will queue request for background thread
  configure do
    set :threaded, false
    
    gw = Tempus::Gateway.new :key=> 'nRHprq9d0Y9UefyxJ3buzZp0Do5RpFtacxzDyRK77VQ=', :iv=>'Nki18CKUFhH5CrI3TAaWdg==', :username=>'A5yPKnq8yLJKwtxOnyfhACcsWVpUYUj63VbsDCTdy+D+GGa4rnJATz1bvnPCU+/8', :password=>'gcbfEBUB3nQc+nCsjMknLiqmk+lbbF6l0Leuv+ZY+1I=', :url=>'https://corsium.com.au/WebAPI/chula'
    # gw = Tempus::Gateway.new :username=>'686d4517-bd7f-4b8d-9ece-7a6ce799ad6f', :password=>'3P(RTe$t1n9', :url=>'https://corsium.info/WebAPI/sdkencr'
    
    set :gw, gw
    
    org_id = gw.get_organization
    
    set :org_id, org_id
    
    set :live, {}
    
     opts = {}
    
    ws_host = opts[:ws_host] || 'pcm-life.com'
    ws_solution = opts[:ws_solution] || 'miot'

    ws = GXTWS::connect ws_solution, ws_host
    
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

run app: HelloApp.new

#
# EventMachine.run {
#
#
#   EventMachine.add_periodic_timer(3) {
#
#
#
#
#   }
#
#
# }


#
#
#
# # incidents = gw.get_incidents datetime
# incidents = gw.get_incidents :device_id=>'111002', :from_date => Time.now.to_date.at_beginning_of_month
#
#
# puts incidents.inspect
#
#
# # https://corsium.info/WebAPI/sdk/Api/Clinical/Incidents/FA68370A-BF24-4BD1-99BE- DF946C8ECDDE/TrendedVitals
#
# incidents.size
#
# if incidents.size > 0
#
#   id = incidents[0]['IncidentId']
#
#
#
#   while(true)
#
#   ts = Time.now
#   datetime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
#   # vitals = gw.get_trended_vitals id, datetime
#   # puts vitals['VitalDetailsInfo'].size.to_s + " #{Time.now.to_f-ts.to_f}"
#
#   events = gw.get_events id #, datetime
#   puts events['EventsInfo'].size.to_s + " #{Time.now.to_f-ts.to_f}"
#
#   twelve_leads_id = nil
#
#   for i in events['EventsInfo']
#     puts "#{i['EventId']} #{i['EventType']}"
#     if i['EventType'] == 'TWELVE_LEADS'
#       twelve_leads_id = i['EventId']
#       # puts i['Vitals'].inspect
#     end
#   end
#
#   if twelve_leads_id
#
#     gw.download_twelve_leads id, twelve_leads_id, "#{twelve_leads_id}.jpg"
#
#
#   end
#
#   # gw.download_pdf id, 'report.pdf'
#
#
#   # vitals = gw.get_trended_vitals id
#
#   # puts vitals.inspect
#
#
#   sleep(0.01)
#
#   end
#
#
# end

