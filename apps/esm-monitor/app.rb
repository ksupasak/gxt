
require 'net/http'
require_relative '../../services/monitor/conf'


register_app 'monitor', 'esm-monitor'

module EsmMonitor
class Station
  include MongoMapper::Document
  key :name, String
  key :ip, String
  key :serial_number, String
  key :type, String
  key :zone_id, ObjectId
end

class User
  include MongoMapper::Document
  
  key :login, String
  key :salt,  String
  key :hashed_password,  String
  key :last_login, DateTime
  key :role, ObjectId
  key :email, String
  timestamps!
  
end
class Zone
  include MongoMapper::Document
  key :name, String
end
class Sense
  include MongoMapper::Document
  key :stamp, Time
  key :name, String
  key :station_id, ObjectId
  key :ip, String
  key :ref, String
  key :data,  String
end

class HomeController < GXT

end
class ZoneController < GXTDocument
  
end

class StationController < GXTDocument
  
end

class SenseController < GXTDocument

  def sense params
    
      # user = User.create :name=>'Soup'

      # key :stamp, DateTime
      #   key :station_id, ObjectId
      #   key :ip, String
      #   key :ref, String
      #   key :data,  String
      # puts params

      stamp = Time.now
      stamp = params['stamp'] if params['stamp']

      ip = @context.request.ip
      ip = params['ip'] if params['ip']


      # station_name
      # 1. monitor ip
      # 2. bed index

      station_name = ip
      station_name = params['station'] if params['station'] 
      # puts "Name = #{params.inspect }"
      ref = "-"
      ref = params['ref'] if params['ref']

      data = "{}"
      data = params['data'] if params['data']
      
      
      puts data
      
      station_id = nil

      station = nil

      unless station = @context.settings.stations[station_name]

        station = Station.where(:name=>station_name).first

        unless station

        station = Station.create(:name=>station_name,:ip=>ip)

        end

        @context.settings.stations[station_name] = station

      end


      if station
          station_id = station['_id']
      end  

      data = JSON.parse(data)
      data['ref'] = ref
       # @context.settings.senses[station_name] = data

        old = @context.settings.senses[station_name]
        @context.settings.senses[station_name] = data
        @context.settings.live[station_name] = 10
        
       
                  if  data['bp_stamp']
                  
                       bp_stamp = data['bp_stamp']
                       old_bp_stamp = old['bp_stamp'] 
                        # puts "$$$$$ #{data['bp_stamp']}  #{old['bp_stamp']}  "
                       if bp_stamp!=old_bp_stamp
                        his_host = GW_HIS_IP
                        his_port = GW_HIS_PORT
                  
                         urix = URI("http://#{his_host}:#{his_port}/his/test_send_anpacurec")
                  
                        begin
                         res = Net::HTTP.post_form(urix, :hn=>data['ref'], :bp=>data['bp'],:hr=>data['hr'], :bp_stamp=>data['bp_stamp'])
                        rescue Exception => e
                          
                          puts e.message
                          
                        end
                  
                       end
                  
                       end
         



      # records = Sense.collection.insert([{:station_id=>station_id, :name=>station_name,:stamp=>stamp,:ip=>ip,:ref=>ref,:data=>data}])
      
      
      # puts station_name
      #  puts app.settings.stations.inspect 
      #  puts Station.count



       "200 OK\nSense " + Sense.collection.count.to_s + "\nId "
    
    
  end

end

end

module Sinatra
 
  module SenseMonitor
    
  include EsmMonitor
    
def self.registered(app)
  
  
  # 
  #   
  # app.get '/monitor' do
  #   # user = User.create :name=>'Soup'
  #   # user = User.collection.insert([{:name=>'Soup'}])
  #   # erb 'Can you handle a <a href="/secure/place">secret</a>? '+User.collection.count.to_s
  #   
  #   
  #   if !request.websocket?
  #      # erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  # 
  #      erb :monitor
  #      
  #    else
  #       request.websocket do |ws|
  #         ws.onopen do
  #           # ws.send("Hello World!")
  #           app.settings.sockets << ws
  #         end
  #         ws.onmessage do |msg|
  #           puts msg
  #           # 10.times do |i|
  #           EM.next_tick { app.settings.sockets.each{|s| s.send(msg) } }
  #           # sleep(1)
  #           # end
  #         end
  #         ws.onclose do
  #           warn("websocket closed")
  #           app.settings.sockets.delete(ws)
  #         end
  #       end
  #     end
  #   
  # end
  
# before do
#   
#   if request.path =="/sense"
#     puts 'sidofjd'
#     switch 'monitor'
#       
#   end
#   
#   
# end





app.post "/sense" do 
    # user = User.create :name=>'Soup'
  
    # key :stamp, DateTime
    #   key :station_id, ObjectId
    #   key :ip, String
    #   key :ref, String
    #   key :data,  String
    # puts params

    stamp = Time.now
    stamp = params['stamp'] if params['stamp']

    ip = request.ip
    ip = params['ip'] if params['ip']


    # station_name
    # 1. monitor ip
    # 2. bed index

    station_name = ip
    station_name = params['station'] if params['station'] 
    # puts "Name = #{params.inspect }"
    ref = "-"
    ref = params['ref'] if params['ref']

    data = "{}"
    data = params['data'] if params['data']
    puts data.inspect 
    station_id = nil

    station = nil

    unless station = app.settings.stations[station_name]

      station = Station.where(:name=>station_name).first

      unless station

      station = Station.create(:name=>station_name)

      end

      app.settings.stations[station_name] = station

    end


    if station
        station_id = station['_id']
    end  

    data = JSON.parse(data)
    data['ref'] = ref
    old = app.settings.senses[station_name]
    app.settings.senses[station_name] = data
    
    
     "$$$$$ #{data['bp_stamp']}"
    if data['bp_stamp']
  
    bp_stamp = data['bp_stamp']
    old_bp_stamp = old['bp_stamp'] 
  
    if bp_stamp!=old_bp_stamp
      
      
      uri = URI("http://#{his_host}:#{his_port}/his/test_send_anpacurec")
      
      res = Net::HTTP.post_form(uri, :hn=>data['ref'], :bp=>data['bp'],:hr=>data['hr'], :bp_stamp=>data['bp_stamp'])
      
      
    end
    
    end



    records = Sense.collection.insert([{:station_id=>station_id, :name=>station_name,:stamp=>stamp,:ip=>ip,:ref=>ref,:data=>data}])
    # puts station_name
    #  puts app.settings.stations.inspect 
    #  puts Station.count
    
    

     "200 OK\nSense " + Sense.collection.count.to_s + "\nId "+records[0].inspect

  
end

$sum = 0

Thread.new do # trivial example work thread
  while true do
     sleep 1
     if Sense.count > 500
       
       Sense.sort(:created_at).limit(400).destroy_all
       
     end
     EM.next_tick { 
        # puts   app.settings.live.inspect 
         app.settings.live.keys.each do |k|
            app.settings.live[k] -=1
            if app.settings.live[k]<0
              
              app.settings.live.delete k
              app.settings.stations.delete k
              app.settings.senses.delete k
            end
         end
       
     begin
       if  app.settings.apps_ws[app.settings.name]
       app.settings.apps_ws[app.settings.name].each{|s|  s.send({:time=>Time.now, :list=>app.settings.stations.keys.sort,:data=>app.settings.senses}.to_json) } 
      end
       # app.settings.sockets.each{|s| s.send({:time=>Time.now, :list=>app.settings.stations.keys.sort,:data=>app.settings.senses}.to_json) } 
    rescue Exception=>e
      
      puts e.inspect 
      
      end   
       
       }
  end
end

end


end


  
  register SenseMonitor
end



