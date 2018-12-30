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
               @context.settings.senses[station_name] = record
               
               
             end
             
            
            
             when 'Data.Sensing'
               
                   pdata =  ActiveSupport::JSON.decode(body)
               
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
                   
## create station
                   
                   unless station = @context.settings.stations[station_name]
                     station = Station.where(:name=>station_name).first
                     unless station
                         station = Station.create(:name=>station_name, :title=>station_name)
                     end
                     @context.settings.stations[station_name] = station

                   end


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
                   
                    old = @context.settings.senses[station_name]
                    old = old.clone if old
                    odata = @context.settings.senses[station_name]
                    odata = {} unless odata
                    
## merge wave 
                 
                    
                    if data['wave']
                       odata['wave'] = [] unless odata['wave']
                       odata['wave'] += data['wave']
                       data.delete 'wave'
                    end
                    
                     odata.merge! data
                     
                     

                     @context.settings.senses[station_name] = odata
                     @context.settings.live[station_name] = 10
               
                     data = odata
                     
              
## internal alert
              
              if data['bp']
                   high = data['bp'].split("/")[0].to_i
                   
                   if high>140
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
             
                     # hn = data['ref']
              #
              #        prefix = hn[0..5].to_i
              #
              #        if hn.index('/')
              #
              #          hn = "#{hn[-2..-1]}#{format("%06d",hn[0..hn.index('/')-1])}"
              #
              #        elsif hn.size==8 and prefix < 300000
              #
              #          hn = "#{hn[6..-1]}#{format("%06d",prefix)}"
              #
              #        elsif hn.size<8
              #
              #          hn = "#{hn[-2..-1]}#{format("%06d",hn[0..-3].to_i)}"
              #        end
              #
              #       data['ref'] = hn
             
                     EsmMiotMonitor::dispatch "Record", "station_id=*", record.to_json
                     
                     
                     # res = Net::HTTP.post_form(urix, :hn=>data['ref'], :bp=>data['bp'],:hr=>data['hr'], :bp_stamp=>data['bp_stamp'])
             
             
                   end
                   
              end
             
             
             
             
             
             
             when 'Data.Image'
                   EsmMiotMonitor::dispatch cmd, path, t[1..-1].join
             else
                   EsmMiotMonitor::dispatch cmd, path, body.to_json
             end
           
           
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
