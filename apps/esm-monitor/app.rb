
register_app 'monitor', 'esm-monitor'


class Station
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


module Sinatra
  module Monitor
    
    
def self.registered(app)
app.get '/monitor' do
  # user = User.create :name=>'Soup'
  # user = User.collection.insert([{:name=>'Soup'}])
  # erb 'Can you handle a <a href="/secure/place">secret</a>? '+User.collection.count.to_s
  
  
  if !request.websocket?
     # erb 'This is a secret place that only <%=session[:identity]%> has access to!'

     erb :monitor
     
   else
      request.websocket do |ws|
        ws.onopen do
          # ws.send("Hello World!")
          app.settings.sockets << ws
        end
        ws.onmessage do |msg|
          puts msg
          # 10.times do |i|
          EM.next_tick { app.settings.sockets.each{|s| s.send(msg) } }
          # sleep(1)
          # end
        end
        ws.onclose do
          warn("websocket closed")
          app.settings.sockets.delete(ws)
        end
      end
    end
  
end




app.post "/a/monitor/sense" do 
    # user = User.create :name=>'Soup'

    # key :stamp, DateTime
    #   key :station_id, ObjectId
    #   key :ip, String
    #   key :ref, String
    #   key :data,  String


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
    app.settings.senses[station_name] = data



    records = Sense.collection.insert([{:station_id=>station_id, :name=>station_name,:stamp=>stamp,:ip=>ip,:ref=>ref,:data=>data}])
    # puts station_name
    #  puts app.settings.stations.inspect 
    #  puts Station.count
    
    

     "200 OK\nSense " + Sense.collection.count.to_s + "\nId "+records[0].inspect

  
end

$sum = 0

Thread.new do # trivial example work thread
  while true do
     sleep 0.5
     EM.next_tick { 
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
  register Monitor
end


class SenseController < GXTDocument

end
