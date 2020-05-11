
module EsmMiotMonitor

def self.settings
      @@settings
end

def self.registered(app)
    
     mode = app.settings.mode
     
     
  
     @@settings = app.settings
     
     settings.set :ws_map, {}
     settings.set :cmd_map, {}
     settings.set :ch_map,  {}
     settings.set :last_map, {}
     
     
     
     data = 0
     
  
     puts "Start MIOT Solution : #{mode}" 
     
     if mode=='application'
       puts "Start MIOT Solution : App" 
       
       EM.next_tick do 
         
         
         
         redis = app.settings.redis
       
         c = "redis://#{REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
         puts "REDIS CONFIG SERVICE 1 : #{c}"
         redis = EM::Hiredis.connect c
         
         
         
         EM.add_periodic_timer(1) do
    
             
             settings.ch_map.each_pair do |k,v|
               
               # puts "#{k} #{v.inspect}"
               
               
               unless v[:t]
                 
                 EM.next_tick do 

 
                                      begin
                                        puts "PUBSUB #{k}"

                                        redis.pubsub.psubscribe(k) { |channel, message|
                                          
                                          
                                          ws_list = app.settings.ch_map[channel][:ws].keys
                                          # puts app.settings.ch_map[channel][:ws].keys.inspect
                                          # puts message
                                           for i in ws_list
                                              ws = settings.ws_map[i]
                                              if ws
                                               # EM.next_tick do
                                                 # puts "send to #{i}"
                                                 ws.send message
                                              # end
                                            end

                                           end

                                          
                                          
                                        }
                                        
                                        puts 'stop'



                                      rescue Exception=>e
                                        puts 'error'
                                        puts e.inspect
                                         puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
                                      # rescue Redis::BaseConnectionError => error
                                      #   puts "#{error}, retrying in 1s"
                                      #   sleep 1
                                      #   retry
                                      end
                                      
                   settings.ch_map[k][:t] = true            
                 end
                 
                 
               end
               
             end
             
             
        end
         
         
         
       end
       
     elsif false
       
      puts mode 
       
       
     elsif mode=='service'
     
       puts "Start MIOT Solution : Service" 

     EM.next_tick do 
         
         
       
# Thread for data IN : 
       
       thread = Thread.new {
       
       
       require 'redis'
       require 'json'
       require "hiredis"

       redis = settings.redis

       begin
         
         redis.psubscribe('miot/*/in' ) do |on|
           on.psubscribe do |channel, subscriptions|
             puts "Subscribed to #{channel} (#{subscriptions} subscriptions)"
           end

           on.pmessage do |channel, tag, message|
             # puts "#{channel}: #{tag}: \n#{message} #{Time.now.to_f}"
             # data += message.size
#              redis.punsubscribe if message == "exit"

# ===========================================================================================================================
# ===========================================================================================================================
# ===========================================================================================================================

       begin 
       
       
       name =  tag.split('/')[1]
       
       switch name
       
       
       redis = settings.redis
       
       # forward to redis
       # redis.publish("miot/#{@context.settings.name}/in", msg_data)
       
       msg_data = message
       
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
         
         
# register message receiver 
         
       when 'WS.Select'
         
         # puts  "msg from #{settings.name} #{msg}"
         # wsname = path.split("=")[-1]
         # wsname = ws.hash
         # settings.ws_map[wsname]=ws
         # puts body.inspect
         # data =  ActiveSupport::JSON.decode(body)
         # puts "#{cmd} #{path} #{data.inspect}"
         #
         # for i in data
         #    t = i.split()
         #    icmd = t[0]
         #    ipath = t[1]
         #
         #    @context.settings.cmd_map[name] = {} unless @context.settings.cmd_map[name]
         #    @context.settings.cmd_map[name][icmd] = {} unless @context.settings.cmd_map[name][icmd]
         #    @context.settings.cmd_map[name][icmd][ipath] = [] unless @context.settings.cmd_map[name][icmd][ipath]
         #    @context.settings.cmd_map[name][icmd][ipath] << wsname unless @context.settings.cmd_map[name][icmd][ipath].index(wsname)
         #
         # end
         #
         #
         # puts "#---- #{  @context.settings.cmd_map.inspect}"
         
# store remote sensing 
      
       when 'Zone.Data'
         
         
      # station_id = "#{name}|#{station_name}"
      #
      #  zone_name = path.split("=")[-1]
      #
      #  zone = Zone.where(:name=>zone_name).first
      #
      #  zone = Zone.create(:name=>zone_name) unless zone
      #
      #  data = ActiveSupport::JSON.decode(body)
      #
      #  for i in data['list']
      #
      #    record = data['data'][i]
      #    station_name = "#{zone_name}_#{i}"
      #
      #    station = Station.where(:name=>station_name, :zone_id=>zone.id).first
      #
      #    unless  station
      #       title = station_name
      #       title = record['title'] if record['title'] and record['title'].size > 0
      #       station = Station.create :name=>station_name,:title=>title, :zone_id=>zone.id unless station
      #     end
      #    @context.settings.senses[name][station_id] = record
      #
      #
      #  end
       
   # store local sensing     
      
       when 'Data.Sensing'
         
             pdata =  ActiveSupport::JSON.decode(body)
         
             station_name = "Untitled"
             station_name = pdata['station'] if pdata['station'] 
             station_idx = "#{name}|#{station_name}"
             
             # fw : data sensing for direct receiver
             # EsmMiotMonitor::dispatch cmd, path, pdata.to_json
         
            
             ref = "-"
             ref = pdata['ref'] if pdata['ref']

             data = "{}"
             data = pdata['data'] if pdata['data']

             

             station_id = nil
             station = nil
             
            
             settings.stations[name] = {} unless settings.stations[name]

             
             # register or retrieve station 
             
             station = Station.where(:name=>station_name).first
             unless station
                    zone = Zone.first 
                    zone_id = nil
                    zone_id = zone.id if zone
                    station = Station.create(:name=>station_name, :title=>station_name,:zone_id=>zone_id)
             end
             
             
             settings.stations[name][station.name] = station
             
             
             data['station_id'] = station.id
              
             # insert title data  
             
             if station
                 station_id = station['_id']
                 data['title'] = station.title if station.title and station.title.size>0 
             end  

             # if data['pr'] 
                 data['ref'] = ref
             # end
             
             data['score'] = 0
             
             admit = nil
             
             # inject last score
             
             if admit = Admit.where(:station_id=>station.id,:status=>'Admitted').last
               data['score'] = admit.current_score
             end
             
              settings.senses[name] = {} unless  settings.senses[name] 
              
              old = settings.senses[name][station_name]
              old = old.clone if old
              odata = settings.senses[name][station_name]
              odata = {} unless odata
              
              
              # mark history
              
              if admit!=nil and (data['bp'] or data['pr'] or data['spo2'] or data['hr'])
                
                odata['admit_id'] = admit.id
                
                now = Time.now
                # core":0,"bp":"113/87","pr":114,"hr":114,"rr":18,"temp":37,"spo2":90,"bp_stamp":"133737","ref":"1234"}}}
                record = {:stamp=>now,:bp=>data['bp'],:bp_stamp=>data['bp_stamp'], :pr=>data['pr'],:hr=>data['hr'], :rr=>data['rr'],:spo2=>data['spo2'],:temp=>data['temp'],:co2=>data['co2']}
                
                odata['vs'] = [] unless odata['vs']
                
                odata['vs'] << record 
                
                
              end
              
              
              
              ## merge wave data
              
              if data['wave']
                 odata['wave'] = [] unless odata['wave']
                 odata['wave'] += data['wave']
                 data.delete 'wave'
              end
              
             
              
              if data['leads']
                
                 odata['leads'] = {} unless odata['leads']
                 
                 data['leads'].each_pair do |l,lv|
                   
                   odata['leads'][l] = [] unless odata['leads'][l]
                   odata['leads'][l] += data['leads'][l]
                   # data['leads'].delete l
                   
                 end
               
              end
              
               odata.merge! data
               
               # puts odata.inspect 
               
               settings.live[name] = {} unless  settings.live[name]
               settings.senses[name][station_name] = odata
               settings.live[name][station_name] = 10
         
               data = odata
               
        
               ## internal alert
        
              if data['bp']
                   high = data['bp'].split("/")[0].to_i
             
                   if high > 200
                     puts "****** Alert *****"
                     # EsmMiotMonitor::dispatch "Alert", "station_id=*", {:title=>pdata['title'],:station=>pdata['station'],:alert=>'High BP Sys at '+data['bp'].to_s+' '}.to_json
                     data['sos'] = 10
                   else
           
                   end
              end
         
       
        # detect new bp stamp or new patient admit
       
        if data['bp']!= "-/-"
        
             old = {} unless old
        
             bp_stamp = data['bp_stamp']
             old_bp_stamp = old['bp_stamp'] 
              # puts "$$$$$ #{data['bp_stamp']}  #{old['bp_stamp']} #{data['ref']} "
             if bp_stamp!=old_bp_stamp or old['ref']!=data['ref']
                
               # puts 'change'
               
               record = {:ref=>data['ref'],:bp=>data['bp'],:hr=>data['hr'],:bp_stamp=>data['bp_stamp']}
               
               # puts "Record #{record.inspect }"
              
       
               # EsmMiotMonitor::dispatch "Record", "station_id=*", record.to_json 
              
       
             end
             
        end
       
       
       
       
      when 'Data.Image'
            # EsmMiotMonitor::dispatch cmd, path, t[1..-1].join
      else
            # EsmMiotMonitor::dispatch cmd, path, body.to_json
      end
       
       
       
       
      end
     
     
     rescue Exception=>e
        puts e.inspect 

     end
     
     


     # ===========================================================================================================================
     # ===========================================================================================================================
     # ===========================================================================================================================







           end

           on.punsubscribe do |channel, subscriptions|
             puts "Unsubscribed from #{channel} (#{subscriptions} subscriptions)"
           end
         end
       rescue Redis::BaseConnectionError => error
         puts "#{error}, retrying in 1s"
         sleep 1
         retry
       end
       
       
      } 
      
      redis = app.settings.redis
       
      # c = "redis://#{app.settings.redis_password+"@"  if app.settings.redis_password }#{app.settings.redis_host}:#{app.settings.redis_port}/#{app.settings.redis_db}"
      c = "redis://#{REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
      
      puts "REDIS CONFIG SERVICE : #{c}"
      # redis = Redis.new(url: "redis://#{@conf_redis_host}:#{@conf_redis_port}/#{@conf_redis_db}",:driver => :hiredis)
      redis = EM::Hiredis.connect c
       
       
        EM.add_periodic_timer(1) do
          puts '. '
          if app.settings.apps_rv
            
          for name in app.settings.apps_rv['esm-miot-monitor']
          switch name
          
          puts "app : #{name}"
          
          if  app.settings.apps_ws[app.settings.name] and app.settings.stations[name] and app.settings.senses[name]
            # puts app.settings.senses[name].inspect 
            
            
            for z in Zone.all
            
            stations = z.stations.all
            snames = stations.collect{|i| i.name}
            result = {:time=>Time.now, :list=>snames,:data=>app.settings.senses[name].select{|k,v| snames.index(k) }}
            
            if z.mode == 'aoc'
            
            if list = Ambulance.all and list.size > 0 
                
              result[:ambu_data] = {}
              
              for i in list
                am = i
                admit = Admit.where(:ambulance_id=>i.id, :status=>'Admitted').first
                am[:admit_id] = admit.id if admit
                  
                result[:ambu_data][i.id] = am
                
              end
              
            end
            end
            
            if list = Admit.where(:status=>'Admitted', :zone_id=>z.id).all and list.size > 0 
                
              result[:admit_data] = {}
              
              for i in list
                  
                ad = {}
                
                ad[:patient] = i.patient
                ad[:station_name] = nil
                ad[:station_name] = i.station.name if i.station
                ad[:note] = i.note
                  
                result[:admit_data][i.id] = ad
                
              end
              
            end
            
            # puts result.to_json
            path = "miot/#{name}/z/#{z.name}"
          # EM.next_tick do 
msg = <<MSG
#{'ZoneUpdate'} #{path}
#{result.to_json}
MSG
                  
# puts msg
            redis.publish(path, msg)
         
            end
         
            # reset all wave data after sent
            
            now = Time.now
            
            app.settings.senses[name].each_pair do |k,v|
              
              # store to sense
                
               if v['station_id'] and v['admit_id'] 
                 
                 
                 # admit = Admit.find v['admit_id'] 
                 
                 
                 if v['admit_id'] 
                 
                 admit = Admit.find v['admit_id']
                 
                 if admit and admit.status == 'Admitted'
                 
                 start_time = now
                 start_time = v['current_time'] if v['current_time']
                 v['current_time'] = now
                 
                 if v['lat'] 
                 ambu = Ambulance.find  admit.ambulance_id 
                 if ambu
                   ambu.update_attributes :last_location=>"#{v['lat']},#{v['lng']}"
                 end
                 end
                 
                 if admit.period and admit.period!="" 
                   
                   t =  (now-admit.created_at).to_i/60%admit.period
                   lt =  (now-admit.created_at).to_i/60/admit.period
                   app.settings.last_map[v['station_id']] = 0 unless app.settings.last_map[v['station_id']]
                   llt = app.settings.last_map[v['station_id']]
                   puts "p #{admit.period} t #{t} lt #{lt} llt #{llt}"
                   if t==0 
                     
                     
                
                     if llt!=lt
                     
                       puts "Auto monitor #{v['station_id']}"
                       
                       
                       bp_sys,bp_dia = v['bp'].split('/')
                       
                       DataRecord.create :admit_id=>admit.id, :bp=>v['bp'], :bp_sys=>bp_sys, :bp_dia=>bp_dia, :pr=>v['pr'], :hr=>v['hr'], :spo2=>v['spo2'], :rr=>v['rr'], :stamp=> now
                       
                       # bp":"121/72","bp_stamp":"115806","pr":93,"rr":18,"spo2":97}]}
  
  
                       # key :admit_id, ObjectId
   #
   #                     key :data, String
   #                     key :bp, String
   #                     key :bp_sys, Integer
   #                     key :bp_dia, Integer
   #                     key :pr, Integer
   #                     key :hr, Integer
   #                     key :spo2, Integer
   #                     key :rr, Integer
   #                     key :temp, Float
   #
   #                     key :stamp, Time
   #
   #                     key :status, String
   #
   #                     key :score, Integer
                       
                       
                       
                     app.settings.last_map[v['station_id']] = lt
                  
                     end
                     
                   end 
                   
                   
                   
                 end
                 
                 Sense.create :admit_id=>v['admit_id'], :station_id => v['station_id'], :data=>v.to_json, :stop_time=>now, :start_time=>start_time
                 
                 v.delete 'vs'
                 end
                 
                 else
                 
                 v.delete 'admit_id'
                 
               end
                 
               end 
              
              
              # clear wave  
              v['wave'] = []
              
              # clear leads
              if v['leads']
                v['leads'].each_pair do |l,lv|
                    v['leads'][l] = []
                end
              end
              
              
            end
            
            
          end
          
          
          
          end
          
          end
        
        end
      end
      
    end

end
end


module Sinatra


 register EsmMiotMonitor

end