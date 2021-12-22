require 'eventmachine'
require 'net/http'
require_relative '../../services/monitor/conf'
require_relative 'sas'
require_relative 'aoc'
require_relative 'smart_er'
require_relative 'smart_health'
require_relative 'smart_icu'
require_relative 'smart_ipd'
require_relative 'smart_aoc'
require_relative 'smart_opd'


require 'active_support'

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

class EMSController < GXT
  
  def default_layout
    return :rocker_layout
  end
 
end

class EmsRequestController < GXT
  
  def default_layout
    return :rocker_layout
  end
 
end


class EmsPrearrivalController < GXT
  
  def default_layout
    return :rocker_layout
  end
 
end

class EmsKMController < GXT
  
  def default_layout
    return :rocker_layout
  end
 
end



class UITemplateController < GXT
  
  def default_layout
    return :rocker_layout
  end
 
end
  
class TestController < GXT

end

class OpdController < GXT
 
  def acl
    
    return {:index=>'*',:entry=>'*',:log=>'*',:result=>'*',:post=>'*'}

    
  end
 
  def default_layout
    return :opd_layout
  end
 
end

class ErController < GXT

end

class SolutionController < GXT

end

class HomeController < GXT
  
  def acl
    
    return {:get_data=>'*',:get_stations=>'*'}
    
  end
    
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
     
     
     
    # if hn or patient_id
  
    patient = nil
    station = nil
    zone = nil
    records = nil
    last = nil
    
    if params[:zone]
       
       zone = Zone.where(:name=>params[:zone]).first
       
     end
    

    if params[:hn] or params[:patient_id]
     
      
      if params[:patient_id]
        patient = Patient.find params[:patient_id]
      else
        patient = Patient.where(:hn=>params[:hn]).first
      end
        
      puts 'ok'
     
     
    elsif params[:name] or params[:id]
      
      if params[:id]
        station = Station.find(params[:id])
      
      else
      
        if zone
          station = Station.where(:zone_id=>zone.id, :name=>params[:name]).first
        else
          station = Station.where(:name=>params[:name]).first
        end
      
      end
      
      
    end
    
    
    if patient or station

    now = Time.now 
    
    from_time = now - 60
    
    if params[:form]
        
      from_time = Time.parse params[:form]
      
    end
    
    to_time = now
    
    if params[:to]
        
      to_time = Time.parse params[:to]
      
    end
    
    
    if patient 
      
      admit = Admit.where(:patient_id=>patient.id).last
      
      if admit
        records = DataRecord.where(:admit_id=>admit.id, :stamp=>{'$gte'=>from_time, '$lte'=>to_time}).all
        last = DataRecord.where(:admit_id=>admit.id).last
      end
      
      
    elsif station
        records = DataRecord.where(:station_id=>station.id, :stamp=>{'$gte'=>from_time, '$lte'=>to_time}).all
        last = DataRecord.where(:station_id=>station.id).last
    end
     
    query = {:from=>from_time, :to=>to_time}
    if patient
      query[:patient_id]=patient.id
    end
    if station
      query[:station_id]=station.id
    end
    
     
     if records 
        
       last = last.attributes.compact if last
        
       return {:result=>200,:msg=>'OK',:query=>query, :list=>records.collect{|i|i.attributes.compact}, :last=>last}.to_json
       
     else
        return {:result=>404,:msg=>'Not found',:query=>query}.to_json
     end
   else
      return {:result=>505,:msg=>'Error', :query=>params}.to_json
   end
   
  end   
    

  def websocket request
      
        request.websocket do |ws|



      
           ws.onopen do
             puts "open websockets for #{@context.settings.name} on #{ws.hash}"
             # ws.send("websocket opened")
             @context.settings.apps_ws[@context.settings.name] = [] unless @context.settings.apps_ws[@context.settings.name] 
             @context.settings.apps_ws[@context.settings.name] << ws
             @context.settings.apps_ws_rv[ws.hash] = @context.settings.name
             
         
           end


           
           
           ws.onmessage do |msg_data|
             
             # puts msg_data
             
             # begin 
              
             name =  @context.settings.apps_ws_rv[ws.hash]
              
             switch name
             
             
             redis = @context.settings.redis
             
             # forward to redis
             redis.publish("miot/#{@context.settings.name}/in", msg_data)
             
            
             
             msgs = msg_data.split("EOL\n")             
             
             for msg in msgs 
             
             t = []
             msg.each_line do |line|
               t<<line
             end
             
             
             headers = t[0].split()
             body = t[1..-1].join("\n")
             cmd = headers[0]
             path = headers[1]
             
             case cmd 
            
             when 'Monitor.StartBP'
               puts 'Monitor.StartBP'
               if @context.settings.cmd_map[name] and @context.settings.cmd_map[name]['Monitor.StartBP'] and wsnames = @context.settings.cmd_map[name]['Monitor.StartBP']['device_id=*']
                 # puts wsnames.inspect
                 for wsname in wsnames
                   
                   wss = @context.settings.ws_map[wsname]
                   
                   if wss
                     # puts 'send...'
                     wss.send msg_data.split("\n")[1..-1].join("\n")
                   else
                      @context.settings.ws_map.delete wsname
                     
                   end
                   
                 end
               
               
               end
               
             when 'Monitor.Update'
               
               
               
               # puts "Monitor"
               # puts msg_data
  #              puts @context.settings.cmd_map.inspect
  #
  #              # {"miot"=>{"Monitor.Update"=>{"zone_id=*"=>[-3100113279091852179]}, "ZoneUpdate"=>{"zone_id=*"=>[-3100113279091852179]}, "Alert"=>{"station_id=*"=>[-3100113279091852179]}, "Data.Image"=>{"station_id=*"=>[-3100113279091852179]}}}
  #              puts name
  #              puts name.class
  #              puts @context.settings.cmd_map.keys.collect{|i| "#{i} #{i.class}"}.join(", ")
  #  
              
               if @context.settings.cmd_map[name] and @context.settings.cmd_map[name]['Monitor.Update'] and wsnames = @context.settings.cmd_map[name]['Monitor.Update']['device_id=*']
                 # puts wsnames.inspect
                 for wsname in wsnames
                   
                   wss = @context.settings.ws_map[wsname]
                   
                   if wss
                     # puts 'send...'
                     wss.send msg_data.split("\n")[1..-1].join("\n")
                   else
                      @context.settings.ws_map.delete wsname
                     
                   end
                   
                 end
               
               
               end
      # register message receiver 
               
             when 'WS.Select'
               
               ch_map = @context.settings.ch_map
               
               
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
                  
                  if icmd=='Zone'
                    puts '****************'
                    
                    puts "#{ipath} #{ch_map.inspect}"
                    ch = ipath
                    
                    unless ch_map[ch]
                      ch_map[ch] = {:ws=>{},:t=>nil }
                    end
                  
                    
                    ch_map[ch][:ws][wsname] = true
                    
                    
                    
                      
                  else
                 
                    @context.settings.cmd_map[name] = {} unless @context.settings.cmd_map[name]
                    @context.settings.cmd_map[name][icmd] = {} unless @context.settings.cmd_map[name][icmd]
                    @context.settings.cmd_map[name][icmd][ipath] = [] unless @context.settings.cmd_map[name][icmd][ipath]
                    @context.settings.cmd_map[name][icmd][ipath] << wsname unless @context.settings.cmd_map[name][icmd][ipath].index(wsname)
                  
                     
                  end
                  
                  
                  
                  
               end
               
               
               puts "#---- #{  @context.settings.cmd_map.inspect}"
               
      # store remote sensing 
            
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
               @context.settings.senses[name][station_id] = record
               
               
             end
             
         # store local sensing     
         
             when 'Zone.Message'
         
               EsmMiotMonitor::dispatch cmd, path, body.to_json
            
            
             when 'Data.Sensing'
               
             
            when 'Data.Image'
                  EsmMiotMonitor::dispatch cmd, path, t[1..-1].join
            else
                  EsmMiotMonitor::dispatch cmd, path, body.to_json
            end
             
             
             
             
            end
           
           
           # rescue Exception=>e
    #           puts e.inspect
    #
    #        end
           
           
           
           end
           
           
           
           
           ws.onclose do
              
             
              
              name = @context.settings.apps_ws_rv[ws.hash]
              
              @context.settings.ws_map.delete ws.hash
              
              @context.settings.ch_map.each_pair do |k,v|
                
                if v[:ws][ws.hash]
                  v[:ws].delete ws.hash
                end
                
              end
              
              
              
              warn("websocket closed #{name} #{ws.hash}")
              if   @context.settings.apps_ws[@context.settings.name]
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
 
end


require_relative 'service'

