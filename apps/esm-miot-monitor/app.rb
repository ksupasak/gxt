require 'eventmachine'
require 'net/http'
require_relative '../../services/monitor/conf'




require_relative 'models'


module EsmMiotMonitor


  def self.dispatch cmd, path, data
    
     
    name = settings.name
    #---- {"ZoneUpdate"=>{"zone_id=*"=>"66dd17be5164100f13fd1ee9d742df188c4a1ba793b9defe312838d77066690a"}}
    # puts 'event for '+name
    # puts "#{settings.cmd_map.inspect  }"
    # puts
    if settings.cmd_map[name]
    if m = settings.cmd_map[name][cmd]
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
    
    
  end


  class HomeController < GXT

    
  def get_stations params
      
     stations = nil
     
     if params[:zone]
    
     zone = Zone.where(:name=>params[:zone]).first
     if zone
       # puts 'from zone'
       stations = Station.where(:zone_id=>zone.id).all
       stations.collect!{|i| i.name=i.name.split("_")[-1]; i } if params[:zone]
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
          
           # puts 'init websocket '
      
           ws.onopen do
             puts "open websocket for #{@context.settings.name} on #{ws.hash}"
             # ws.send("websocket opened")
             @context.settings.apps_ws[@context.settings.name] << ws
             @context.settings.apps_ws_rv[ws.hash] = @context.settings.name
           end
           ws.onmessage do |msg|
             
             
             name =  @context.settings.apps_ws_rv[ws.hash]
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
               wsname = path.split("=")[-1]
               wsname = ws.hash
               @context.settings.ws_map[wsname]=ws
               puts body.inspect
               data =  ActiveSupport::JSON.decode(body)
               puts "#{cmd} #{path} #{data.inspect}"
               
               for i in data
                  t = i.split()
                  icmd = t[0]
                  ipath = t[1]
                  
                  @context.settings.cmd_map[name] = {} unless @context.settings.cmd_map[name]
                  @context.settings.cmd_map[name][icmd] = {} unless @context.settings.cmd_map[name][icmd]
                  @context.settings.cmd_map[name][icmd][ipath] = [] unless @context.settings.cmd_map[name][icmd][ipath]
                  @context.settings.cmd_map[name][icmd][ipath] << wsname unless @context.settings.cmd_map[name][icmd][ipath].index(wsname)
                  
               end
               
               
               puts "#---- #{  @context.settings.cmd_map.inspect}"
            
             when 'Zone.Data'
               
               
            station_id = "#{name}|#{station_name}"   
             
             zone_name = path.split("=")[-1]
             
             zone = Zone.where(:name=>zone_name).first
             
             zone = Zone.create(:name=>zone_name) unless zone
              
             data = ActiveSupport::JSON.decode(body)
             
             for i in data['list']
               
               record = data['data'][i]
               station_name = "#{zone_name}_#{i}"
               
               station = Station.where(:name=>station_name, :zone_id=>zone.id).first
              
               unless  station
                  title = station_name
                  title = record['title'] if record['title'] and record['title'].size > 0 
                  station = Station.create :name=>station_name,:title=>title, :zone_id=>zone.id unless station
                end
               @context.settings.senses[station_id] = record
               
               
             end
             
            
            
             when 'Data.Sensing'
               
                   pdata =  ActiveSupport::JSON.decode(body)
               
                   station_name = "Untitled"
                   station_name = pdata['station'] if pdata['station'] 
                   station_idx = "#{name}|#{station_name}"
                   
                   EsmMiotMonitor::dispatch cmd, path, pdata.to_json
               
                  
                   # puts "Name = #{params.inspect }"
                   ref = "-"
                   ref = pdata['ref'] if pdata['ref']

                   data = "{}"
                   data = pdata['data'] if pdata['data']

                    

                   station_id = nil
                   station = nil
                   
## create station. 

                  # puts @context.settings.stations.inspect 
                  
                  @context.settings.stations[name] = {} unless @context.settings.stations[name]
       #
       #            unless station = @context.settings.stations[name][station_name]
       #
       #               station = Station.where(:name=>station_name).first
       #               unless station
       #                   station = Station.create(:name=>station_name, :title=>station_name)
       #               end
       #                @context.settings.stations[name] = {} unless  @context.settings.stations[name]
       #               @context.settings.stations[name][station_name] = station
       #
       #             end
                   
                  
                   station = Station.where(:name=>station_name).first
                   unless station
                          station = Station.create(:name=>station_name, :title=>station_name)
                   end
                   @context.settings.stations[name][station.name] = station
                   
                   


                   if station
                       station_id = station['_id']
                       data['title'] = station.title if station.title and station.title.size>0 
                   end  

                   if data['pr'] 
                       data['ref'] = ref
                   end
                   
                   data['score'] = 0
                   if admit = Admit.where(:station_id=>station.id,:status=>'Admitted').last
                     data['score'] = admit.current_score
                   end
                   
                   @context.settings.senses[name] = {} unless  @context.settings.senses[name] 
                    old = @context.settings.senses[name][station_name]
                    old = old.clone if old
                    odata = @context.settings.senses[name][station_name]
                    odata = {} unless odata
                    
## merge wave 
                 
                    
                    if data['wave']
                       odata['wave'] = [] unless odata['wave']
                       odata['wave'] += data['wave']
                       data.delete 'wave'
                    end
                  
                     odata.merge! data
                     
                     # puts odata.inspect 
                     
                     @context.settings.live[name] = {} unless  @context.settings.live[name]
                     @context.settings.senses[name][station_name] = odata
                     @context.settings.live[name][station_name] = 10
               
                     data = odata
                     
              
## internal alert
              
              if data['bp']
                   high = data['bp'].split("/")[0].to_i
                   
                   if high > 200
                     puts "****** Alert *****"
                     EsmMiotMonitor::dispatch "Alert", "station_id=*", {:title=>pdata['title'],:station=>pdata['station'],:alert=>'High BP Sys at '+data['bp'].to_s+' '}.to_json
                     data['sos'] = 10
                   else
                 
                   end
              end
               
              # puts 'dispatch bp stamp '+ " #{data['bp_stamp']}"
             
              if data['bp']!= "-/-"
              
                old = {} unless old
              
                   bp_stamp = data['bp_stamp']
                   old_bp_stamp = old['bp_stamp'] 
                    # puts "$$$$$ #{data['bp_stamp']}  #{old['bp_stamp']} #{data['ref']} "
                   if bp_stamp!=old_bp_stamp or old['ref']!=data['ref']
                      
                     # puts 'change'
                     
                     record = {:ref=>data['ref'],:bp=>data['bp'],:hr=>data['hr'],:bp_stamp=>data['bp_stamp']}
                     
                     puts "Record #{record.inspect }"
                    
             
                     EsmMiotMonitor::dispatch "Record", "station_id=*", record.to_json
                    
             
                   end
                   
              end
             
             
             
             
             
             
             when 'Data.Image'
                   EsmMiotMonitor::dispatch cmd, path, t[1..-1].join
             else
                   EsmMiotMonitor::dispatch cmd, path, body.to_json
             end
           
           
           end
           
           
           
           
           ws.onclose do
              
             
              
              name = @context.settings.apps_ws_rv[ws.hash]
              
              
              warn("websocket closed #{name} #{ws.hash}")
             
              @context.settings.apps_ws[@context.settings.name].delete(ws)
              @context.settings.apps_ws_rv.delete ws.hash
             
              if  @context.settings.cmd_map[name]
              
              @context.settings.cmd_map[name].each_pair do |icmd,v|
              
                v.each_pair do |ipath,v2|
             
             
                  warn("websocket closed #{ws.hash} from #{icmd} #{ipath}")
                  v2.delete ws.hash
                  
                end
              
              end
              
               
              end
               
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
          
          if app.settings.apps_ws[app.settings.name] and app.settings.stations[name] and app.settings.senses[name]
        
            dispatch "ZoneUpdate", "zone_id=*", {:time=>Time.now, :list=>app.settings.stations[name].keys.sort,:data=>app.settings.senses[name]}.to_json
            
            # reset all wave data after sent
            
            app.settings.senses[name].each_pair do |k,v|
                
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
