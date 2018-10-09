require 'eventmachine'
require 'net/http'
require_relative '../../services/monitor/conf'


register_app 'miot', 'esm-miot-monitor'


require_relative 'models'


module EsmMiotMonitor


  def self.dispatch cmd, path, data
    
    
    #---- {"ZoneUpdate"=>{"zone_id=*"=>"66dd17be5164100f13fd1ee9d742df188c4a1ba793b9defe312838d77066690a"}}
    
    if m = settings.cmd_map[cmd]
        m.each_pair do |k,line|
          if k==path
            for i in line
              ws = settings.ws_map[i]
msg = <<MSG
#{cmd} #{path}
#{data}
MSG
              
              ws.send msg
              
            end
          end
          
        end
        
    end
    
    
  end


  class HomeController < GXT

    
  def get_stations params
      
     stations = nil
     
     if params[:zone]
    
     zone = Zone.where(:name=>params[:zone]).first
     if zone
       puts 'from zone'
       stations = Station.where(:zone_id=>zone.id).all
       return stations.to_json
       
     end
     
     end
      
       
     stations = Station.all unless stations
     
     
     return stations.to_json
     
     
    
  end

  def get_data params
     
     if params[:zone]
        
        
        if params[:name]
          name = "#{params[:zone]}_#{params[:name]}"
          station = Station.where(:name=>name).first
        end
        
          
     else
     
     if params[:id]
       station = Station.find(params[:id])
     else
       station = Station.where(:name=>params[:name]).first
     end
    end
     
     
     if station
        data = settings.senses[station.name]
        return data.to_json
     else
        return {:result=>404,:msg=>'Not found'}
     end
     
  end   
    

  def websocket request
      
   
      
 
      
        request.websocket do |ws|
          
                puts 'init websocket '
      
           ws.onopen do
             puts 'init websocket '
             # ws.send("websocket opened")
             @context.settings.apps_ws[@context.settings.name] << ws
             @context.settings.apps_ws_rv[ws] = @context.settings.name
           end
           ws.onmessage do |msg|
             name =  @context.settings.apps_ws_rv[ws]
             switch name
             # puts  "msg from #{@context.settings.name} #{msg}"
             # t = msg.encode('utf-8').split("\n")
             t = []
             msg.each_line do |line|
               t<<line
             end
             
             
             headers = t[0].split()
             body = t[1..-1].join("\n")
             cmd = headers[0]
             path = headers[1]
             
             case cmd 
               
             when 'WS.Select'
               puts  "msg from #{@context.settings.name} #{msg}"
               name = path.split("=")[-1]
               @context.settings.ws_map[name]=ws
               puts body.inspect
               data =  ActiveSupport::JSON.decode(body)
               puts "#{cmd} #{path} #{data.inspect}"
               
               for i in data
                  t = i.split()
                  icmd = t[0]
                  ipath = t[1]
                  @context.settings.cmd_map[icmd] = {} unless @context.settings.cmd_map[icmd]
                  @context.settings.cmd_map[icmd][ipath] = [] unless @context.settings.cmd_map[icmd][ipath]
                  @context.settings.cmd_map[icmd][ipath] << name unless @context.settings.cmd_map[icmd][ipath].index(name)
               end
               puts "#---- #{  @context.settings.cmd_map.inspect}"
            
             when 'Zone.Data'
             
             zone = path.split("=")[-1]
             
             data = ActiveSupport::JSON.decode(body)
             
             for i in data['list']
               
               record = data['data'][i]
               station_name = "#{zone}_#{i}"
               station = Station.where(:name=>station_name).first
               
               station = Station.create :name=>station_name unless station
               
               @context.settings.senses[station_name] = record
               
               
             end
             
             # {"time":"2018-10-06T11:03:16.553+07:00","list":["Bed01"],"data":{"Bed01":{"wave":[50.0,53.019,73.148,56.248,78.506,98.788,67.635,86.21,56.356,62.532,50.0,36.054,25.703,27.55,32.556,36.806,24.42,29.648,31.871,44.944,50.0,54.19,65.011,56.434,66.463,70.153,54.559,50.698,77.467,61.396,50.0,34.561],"bp":"103/77","pr":61,"hr":61,"rr":20,"temp":36,"spo2":94,"bp_stamp":"110306","ref":"1234","score":0}}}
             #           Zone.Data zone=default
             #           {"time":"2018-10-06T11:03:17.556+07:00","list":["Bed01"],"data":{"Bed01":{"wave":[50.0,52.055,74.277,50.522,58.206,86.871,65.056,79.33,58.069,60.698,50.0,40.014,32.638,37.855,15.308,13.686,48.782,43.266,21.606,49.848,50.0,60.881,54.627,88.895,94.782,75.335,63.213,77.756,57.158,58.528,50.0,41.512],"bp":"103/77","pr":111,"hr":111,"rr":21,"temp":38,"spo2":98,"bp_stamp":"110306","ref":"1234","score":0}}}
             #           Zone.Data zone=default
             #           {"time":"2018-10-06T11:03:18.560+07:00","list":["Bed01"],"data":{"Bed01":{"wave":[50.0,62.77,61.322,86.735,52.421,51.338,85.782,63.661,56.805,58.753,50.0,44.766,47.564,34.598,30.85,19.487,8.76,14.219,48.997,35.242,50.0,65.193,71.212,71.016,68.019,62.961,50.162,88.853,53.984,61.817,50.0,41.322],"bp":"103/77","pr":79,"hr":79,"rr":20,"temp":37,"spo2":90,"bp_stamp":"110306","ref":"1234","score":0}}}
              
              # @context.settings.senses[station_name]
              
              
              
            
            
             when 'Data.Sensing'
               
               pdata =  ActiveSupport::JSON.decode(body)
               
               
               
               ##########################################################
                   # {"station":"Bed01","stamp":"\"2018-07-29 00:58:14 +0700\"","ref":"-","data":{"bp":"82/118","pr":112,"hr":112,"rr":18,"bp_stamp":"005812"}}
                   station_name = "Untitled"
                   station_name = pdata['station'] if pdata['station'] 
               
                 
                   EsmMiotMonitor::dispatch cmd, path, pdata.to_json
               
                  
                   # puts "Name = #{params.inspect }"
                   ref = "-"
                   ref = pdata['ref'] if pdata['ref']

                   data = "{}"
                   data = pdata['data'] if pdata['data']

                    

                   station_id = nil

                   station = nil

                   unless station = @context.settings.stations[station_name]

                     station = Station.where(:name=>station_name).first

                     unless station

                     station = Station.create(:name=>station_name)

                     end

                     @context.settings.stations[station_name] = station

                   end


                   if station
                       station_id = station['_id']
                   end  

                   if data['pr'] 
                     data['ref'] = ref
                   end
                   
                   
                   data['score'] = 0
                   
                   if admit = Admit.where(:station_id=>station.id,:status=>'Admitted').last
                     
                     data['score'] = admit.current_score
                     
                     
                     
                   end
                   
                   
                    
                    odata = @context.settings.senses[station_name]
                    odata = {} unless odata
                    
                 
                    
                    if data['wave']
                       odata['wave'] = [] unless odata['wave']
                       odata['wave'] += data['wave']
                       # puts odata['wave'].size
                       # puts odata['wave'][0..-1].join(" ")
                    else
                       odata.merge! data
                    end

                     old = @context.settings.senses[station_name]
                     @context.settings.senses[station_name] = odata
                     @context.settings.live[station_name] = 10
               
                 ##########################################################
                 
                if data['bp']
                  
                 high = data['bp'].split("/")[0].to_i
                 
                 
               if high>140
                 
                 
                 puts "****** Alert *****"
                 
                 EsmMiotMonitor::dispatch "Alert", "station_id=*", {:station=>pdata['station'],:alert=>'High BP Sys at '+data['bp'].to_s+' '}.to_json
                 
                 data['sos'] = 10
                 
                 
               else
                 
                 
                 
               end
               
               
             end
               
                 when 'Data.Image'
               
                   EsmMiotMonitor::dispatch cmd, path, t[1..-1].join
              
             else
             
               EsmMiotMonitor::dispatch cmd, path, body.to_json
             
               
             end
             
             # 10.times do |i|
             # EM.next_tick {  @context.settings.apps_ws[@context.settings.name].each{|s| s.send(msg) } }
             # sleep(1)
             # end
           end
           ws.onclose do
             warn("websocket closed")
              @context.settings.apps_ws[@context.settings.name].delete(ws)
           end
         end
    
  end
  

  end
 
end

module EsmMiotMonitor

def self.settings
      @@settings
end

def self.registered(app)
  
     puts 'Start MIOT Solution '
     @@settings = app.settings
     
     settings.set :ws_map, {}
     settings.set :cmd_map, {}
     
     EM.next_tick { 
        EM.add_periodic_timer(1) do
          
          if app.settings.apps_rv
            
          for name in app.settings.apps_rv['esm-miot-monitor']
          switch name
          
          if app.settings.apps_ws[app.settings.name]
        
            dispatch "ZoneUpdate", "zone_id=*", {:time=>Time.now, :list=>app.settings.stations.keys.sort,:data=>app.settings.senses}.to_json
            
            app.settings.senses.each_pair do |k,v|
                
              v['wave'] = []
              
            end
            
          end
          
          
          
          end
          
          end
        
        end
      }

end
end


module Sinatra


 register EsmMiotMonitor

end
