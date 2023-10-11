require_relative 'lib/tempus'
require "active_support"
require "eventmachine"
require "active_support/core_ext/date/calculations"
require 'sinatra'
require 'sinatra/base'
require_relative 'lib/ws'
# gw = Tempus::Gateway.new :key=> 'nRHprq9d0Y9UefyxJ3buzZp0Do5RpFtacxzDyRK77VQ=', :iv=>'Nki18CKUFhH5CrI3TAaWdg==', :username=>'A5yPKnq8yLJKwtxOnyfhACcsWVpUYUj63VbsDCTdy+D+GGa4rnJATz1bvnPCU+/8', :password=>'gcbfEBUB3nQc+nCsjMknLiqmk+lbbF6l0Leuv+ZY+1I=', :url=>'https://corsium.com.au/WebAPI/chula'






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
    ws = web_app.settings.ws
    gw = web_app.settings.gw
    
    EventMachine.add_periodic_timer(10) {
 
      puts "run #{Time.now}"
      
      
      online_lives = gw.get_live_incidents
      
      if online_lives
      
      
      current = {}
      puts online_lives.size
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
        
        
      puts "Current #{lives.keys.size }"
      
    end
       
      
    }
    
    sim = JSON.parse(File.open("sim.json").read)
    cur = 0 
    sim_vitals = sim['VitalDetailsInfo']
    smap = {}
    
    start = Time.parse(sim_vitals[0]['DataCaptureTimeUtc'])
    
    for i in sim_vitals 
      
      t =  Time.parse(i['DataCaptureTimeUtc']) - start
      
      smap[t] = [] unless smap[t]
      
      smap[t] << i 
      
    end
    
    slist = []
    
    smap.keys.sort.each do |i|
      
      slist << smap[i]
      
    end
    
    mark_dup = {}
    
    EventMachine.add_periodic_timer(3) {
    
      if lives.keys.size>0 
        
        
        lives.each_pair do |k,v|
          # puts k
       #
       #    puts v.inspect
          
       if  web_app.settings.twelvelead 
           
         puts 'twelvelead'
         
         web_app.settings.twelvelead = false
         
          GXTWS.send_image ws, v, "data/B07E81C6-0F1F-4DC7-A6F8-9544F553138F.jpg"
         
       end
          
          datetime = Time.now.strftime("%Y-%m-%dT%H:%M:%S")
          
          # vitals = gw.get_trended_vitals k, datetime
          # vitals = gw.get_trended_vitals k #, datetime
          data = {"IncidentId"=>"4F270D7A-E301-4F76-93C8-A09AC0D1D8B3","VitalDetailsInfo"=>[] }
          
          list = slist[cur].clone

          list.collect! do |j|
            j['DataCaptureTimeUtc'] = Time.now
            j
          end
   #
          
          data["VitalDetailsInfo"] = list
          
          cur +=1 
          cur = 0 if cur == slist.size 
          
          # puts data.to_json
          
          GXTWS.send ws, v, data, mark_dup
          
          
            
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
    
    gw = Tempus::Gateway.new :username=>'686d4517-bd7f-4b8d-9ece-7a6ce799ad6f', :password=>'3P(RTe$t1n9', :url=>'https://corsium.info/WebAPI/sdkencr'
    
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
    
    set :twelvelead, false
    
  end
  
 

  # Request runs on the reactor thread (with threaded set to false)
  get '/' do
    
     @org = settings.org_id
     @twelvelead = settings.twelvelead
     erb :home
     
  end
  
  
  get '/twelvelead' do 
      
       settings.twelvelead = true
       
    redirect '/'
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

