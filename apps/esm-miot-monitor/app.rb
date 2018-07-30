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
              
             when 'Data.Sensing'
               
               pdata =  ActiveSupport::JSON.decode(body)
               EsmMiotMonitor::dispatch cmd, path, pdata.to_json
               
               
               ##########################################################
                   # {"station":"Bed01","stamp":"\"2018-07-29 00:58:14 +0700\"","ref":"-","data":{"bp":"82/118","pr":112,"hr":112,"rr":18,"bp_stamp":"005812"}}
                   station_name = "Untitled"
                   station_name = pdata['station'] if pdata['station'] 
                  
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

                  
                   data['ref'] = ref
                   data['sos'] = rand(3)
                    # @context.settings.senses[station_name] = data

                     old = @context.settings.senses[station_name]
                     @context.settings.senses[station_name] = data
                     @context.settings.live[station_name] = 10
               
                 ##########################################################
               
               if data['pr']>117
                 puts "****** Alert *****"
                 
                 EsmMiotMonitor::dispatch "Alert", "station_id=*", {:station=>pdata['station'],:alert=>'Pule rate is Over..!! at '+data['pr'].to_s+' rpm'}.to_json
                 data['sos'] = 10
                 
                 
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
