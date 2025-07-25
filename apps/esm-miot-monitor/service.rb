
require_relative 'zello'
 
module EsmMiotMonitor

def self.settings
      @@settings
end


def self.deg2rad(deg)
		return deg * (3.1414/180)
end

def self.getDistanceFromLatLonInKm(lo1, lo2)
  
  lat1, lon1 = lo1.split(",").collect{|i| i.to_f}
  
  lat2, lon2 = lo2.split(",").collect{|i| i.to_f}
  
  # lat1, lon1, lat2, lon2
	r = 6371; # Radius of the earth in km
	dLat = deg2rad(lat2-lat1);  # deg2rad below
	dLon = deg2rad(lon2-lon1);
	a =
		Math.sin(dLat/2) * Math.sin(dLat/2) +
		Math.cos(deg2rad(lat1)) * Math.cos(deg2rad(lat2)) *
		Math.sin(dLon/2) * Math.sin(dLon/2)
		;
	c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	d = r * c; # Distance in km
	return d;
end

def self.registered(app)

     mode = app.settings.mode



     @@settings = app.settings

     settings.set :ws_map, {}
     settings.set :cmd_map, {}
     settings.set :ch_map,  {}
     settings.set :last_map, {}
     settings.set :zello_map, {}
     settings.set :ambu_status, {}
     settings.set :emd_map, {}


     settings.set :position_list, {}


    
     
     data = 0


     puts "Start MIOT Solution : #{mode}"

     if mode=='application'
       puts "Start MIOT Solution : App"

       EM.next_tick do



         redis = app.settings.redis

         c = "redis://#{":"+REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
         puts "REDIS CONFIG SERVICE 2 : #{c}"
         redis = EM::Hiredis.connect c

         # settings.set :redis, redis

         # settings.redis = redis


         EM.add_periodic_timer(1) do


             settings.ch_map.each_pair do |k,v|

               # puts "#{k} #{v.inspect}"


               unless v[:t]

                 EM.next_tick do


                                      begin
                                        # puts "PUBSUB #{k}"

                                        redis.pubsub.psubscribe(k) { |channel, message|

                                          # puts "PUBSUB #{k} #{channel} #{message.inspect}"

                                          ws_list = app.settings.ch_map[k][:ws].keys
                                          # puts app.settings.ch_map[channel][:ws].keys.inspect
                                          # puts message
                                           for i in ws_list
                                              ws = settings.ws_map[i]
                                              if ws

                                                 ws.send message
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

    elsif mode=='gps'

      puts mode

      EM.next_tick do

        require 'redis'
        require 'json'
        require "hiredis"

        redis = settings.redis


        jsessionid_map = {}
        connection_map = {}
        device_map = {}

        cache_stamp = nil
        cache_directions = {}


       EM.add_periodic_timer(10) do

         #update list

         if cache_stamp==nil or cache_stamp!=Time.now.strftime("%Y-%m-%d")
           
           cache_directions = {}
           cache_stamp = Time.now.strftime("%Y-%m-%d")

         end


         # for name in app.settings.apps_rv['esm-miot-monitor']
          for name in get_solutions('esm-miot-monitor')


            switch name, 'esm-miot-monitor'

            if key = Setting.get(:google_api_key)#cms_url = Setting.where(:name=>'cms_url').first and cms_url

              

              
              list = []

              # all running case in [Solution]
              
              ems_cases = EMSCase.where(:status=>{'$ne'=>'Completed'}).all


              for c in ems_cases

              ems_commands = EMSCommand.where(:case_id=>c.id).all

              admit = c.admit


              for cmd in ems_commands

                i = cmd.ambulance

               #Admit.where(:ambulance_id=>i.id, :status=>'Admitted' ).first

                if admit

                  route = AocCaseRoute.where(:admit_id=>admit.id,:status=>'STARTED').sort(:sort_order=>-1).first

                  if route
                    
                    # update start loc when no start loc

                    unless route.start_latlng

                      route.update_attributes :start_latlng=>i.last_location

                    end


                    unless route.est_distance
                      puts "#{route.start_latlng} - #{route.stop_latlng}"
                      direction = google_direction(route.start_latlng, route.stop_latlng, key)

                      if direction[:status]=='200 OK'
                        route.update_attributes :est_distance=>direction[:total_distance][:value], :est_duration=>direction[:total_duration][:value]
                      end

                    end
                    
                    dis = 999
                    dis = getDistanceFromLatLonInKm(i.last_location, route.last_location) if route.last_location and i.last_location

                    puts "Dis = #{dis}"
                    
                    if route.last_location == nil or dis > 0.1 #  and i.last_speed and
                      
                      

                    kcache = "#{i.last_location.split(",").collect{|j| j.to_f.round(4)}.join(",")}-#{route.stop_latlng}"
                    direction = cache_directions[kcache]

                    unless direction
                      direction = google_direction(i.last_location, route.stop_latlng, key)
                      cache_directions[kcache] = direction
                    end
                    
                    if direction[:status]=='200 OK'
                        route.update_attributes :act_distance=>direction[:total_distance][:value], :act_duration=>direction[:total_duration][:value], :last_location=>i.last_location, :last_cal=>Time.now
                   
path = "miot/#{name}/z/#{admit.zone.name}"
msg = 'NULL'
send_msg = <<MSG
#{'Zone.Message'} #{path}
#{msg.to_json}
MSG

                		settings.redis.publish(path, send_msg)

                  end

                    # puts cache_directions.keys
                    # unless route.act_distance
                      # fill estimate distance
                 


                  end


  #                   if i.last_speed > 10 or route.act_distance ==nil #  and i.last_speed and
#
#                      # puts "yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy #{i.name}"
#
#                     kcache = "#{i.last_location.split(",").collect{|j| j.to_f.round(4)}.join(",")}-#{route.stop_latlng}"
#                     direction = cache_directions[kcache]
#
#                     unless direction
#                       direction = google_direction(i.last_location, route.stop_latlng, key)
#                       cache_directions[kcache] = direction
#                     end
#
# path = "miot/#{name}/z/#{admit.zone.name}"
# msg = 'NULL'
# send_msg = <<MSG
# #{'Zone.Message'} #{path}
# #{msg.to_json}
# MSG
#
#                     settings.redis.publish(path, send_msg)
#
#
#                     # puts cache_directions.keys
#                     # unless route.act_distance
#                       # fill estimate distance
#                     if direction[:status]=='200 OK'
#                         route.update_attributes :act_distance=>direction[:total_distance][:value], :act_duration=>direction[:total_duration][:value]
#                     end
#
#
#                   end


                    # end
                    if  route.est_distance and route.act_distance and route.est_distance - route.act_distance > 10

                      departure_log = AdmitLog.find route.departure_log_id

                      if departure_log and departure_log.status=='PENDING'

                      departure_log.update_attributes :status=>'COMPLETED', :stamp=>Time.now , :note=>'Auto check'

                      route.update_attributes :start_time=>Time.now


                       accept = AdmitLog.where(:admit_id=>admit.id, :name=>'AOC Accept', :status=>'PENDING').first

                        if accept

                          accept.update_attributes :status=>'COMPLETED', :stamp=>Time.now , :note=>'Auto check'

                        end

                      end

                    end

                    # route.act_distance = 10

                    if route.act_distance and route.act_distance < 10 # arrive

                      arrival_log = AdmitLog.find route.arrival_log_id

                      if arrival_log and arrival_log.status=='PENDING'

                      arrival_log.update_attributes :status=>'COMPLETED', :stamp=>Time.now , :note=>'Auto check'

                      departure_log = AdmitLog.find route.departure_log_id

                      if departure_log.status=='PENDING'

                        departure_log.update_attributes :status=>'COMPLETED', :stamp=>Time.now , :note=>'Auto skip'
                        route.update_attributes :start_time=>Time.now


                        accept = AdmitLog.where(:admit_id=>admit.id, :name=>'AOC Accept', :status=>'PENDING').first

                         if accept

                           accept.update_attributes :status=>'COMPLETED', :stamp=>Time.now , :note=>'Auto check'


                         end

                      end


                      route.update_attributes :status=>'COMPLETED', :act_duration=>Time.now  - departure_log.stamp , :note=>'Auto check', :stop_time=>Time.now

                      end

                    end




                    # puts route.inspect

                  end

                  end

                end



                list << {:ambu=>i, :admit=>admit}


              end

              if cms_url = Setting.where(:name=>'cms_url').first and cms_url
                device_map[name] = {:url=>cms_url.value, :key=>key, :list=> list} 
              end
              
            end

        end

       end

       EM.add_periodic_timer(2) do


         puts "GPS CMS"


         if app.settings.apps_rv  and false 

         for name in app.settings.apps_rv['esm-miot-monitor'].uniq
           switch name, 'esm-miot-monitor'

          # puts "#{name} XXXX"

          if device_map[name] and device_map[name][:url] #cms_url = Setting.where(:name=>'cms_url').first and cms_url

           jsessionid = jsessionid_map[name]

           unless jsessionid
             # https://103.76.181.125:8080/StandardApiAction_getDeviceStatus.action?jsession=821e9919-3862-4352-ad23-e4863e8ebf40&devIdno=819112151&toMap=1&driver=0&language=th&
             # http://103.76.181.125:8080/808gps

             # response_body = Net::HTTP.get_response("example.com", "/", 443)

             # uri = URI("https://103.76.181.125:8080")

             # puts device_map[name][:url]
             uri = URI(device_map[name][:url])

             use_ssl = false

             http = Net::HTTP.new(uri.host, uri.port)
             # http.use_ssl = use_ssl
             http.verify_mode = OpenSSL::SSL::VERIFY_NONE

             result = nil

             http.start do |http|

             req = Net::HTTP::Get.new("/StandardApiAction_login.action?account=admin&password=minadadmin")

             response = http.request(req)
             json = JSON.parse(response.body)

             jid = json['JSESSIONID']

             jsessionid_map[name] = jid

             end


           end




           # start Zello
           # puts "DVR GPS update #{name} #{device_map[name][:url]} #{jsessionid}"

          # zello_connect = Setting.where(:name=>'zello_connect').first

          begin

          unless http = connection_map[name]

            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = use_ssl
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            connection_map[name] = http

          end
            
          # puts device_map[name].inspect 

          http.start do |http|

            results = {}

          # for ambu in Ambulance.where(:device_no=>{'$ne'=>''}).all

          for map in device_map[name][:list]


            ambu = map[:ambu]
            admit = map[:admit]
            
            # puts  "#{name} : #{ambu.name}"
            
            if ambu and ambu.device_no and ambu.device_no !="" and ambu.location_policy != "APP"

            req = Net::HTTP::Get.new("/StandardApiAction_getDeviceStatus.action?jsession=#{jsessionid}&devIdno=#{ambu.device_no}&toMap=1&driver=0&language=th")

            # 

            response = http.request(req)
            
            # puts response
            
            json = JSON.parse(response.body)

            json = json['status'][0]
            # puts json.inspect
            sp = 0
            sp = json['sp']/10.0 if json['sp']

            result = {:station_id=> ambu.station_id , :device_id=>ambu.device_no,:lat=>json['mlat'], :lng=>json['mlng'], :sp=>sp, :ol=>json['ol'], :hx=>json['hx']}

            # puts "#{ambu.name} #{result.inspect} #{admit.id if admit}"

            results[ambu.id] = result if json['mlat'].to_i!=0
            
            end

          end

            
          puts results.inspect
          
          if results.keys.size > 0 

            path = "miot/#{name}/in"
          

send_msg = <<MSG
#{'Ambu.Update'} #{path}
#{results.to_json}
MSG

  
            # puts "\t #{path} #{send_msg.to_json}"
            redis.publish(path, send_msg)
          end


         end


         rescue Exception=>e

           puts e.inspect
           puts e.backtrace

           http = nil


         end





         end


         end

        end


      end


    end



    elsif mode=='zello'

      EM.next_tick do

        require 'redis'
        require 'json'
        require "hiredis"

        redis = settings.redis

       EM.add_periodic_timer(1) do


         if app.settings.apps_rv

         for name in app.settings.apps_rv['esm-miot-monitor']
           switch name, 'esm-miot-monitor'

           # start Zello

           zello_connect = Setting.where(:name=>'zello_connect').first

           if zello_connect and zello_connect.value and zello_connect.value.size>0

             puts "zello : #{name}"




             unless app.settings.zello_map[name]


               zello = Zello::Connector.new zello_connect.value

               app.settings.zello_map[name] = zello


             end

             begin

             zello = app.settings.zello_map[name]

             msgs = zello.feed


             if msgs


                 for i in msgs

                   msg = nil

                   sz = i['recipient'].split('.')
                   zone = nil
                   station = nil
                   channel = nil
                   puts msg.inspect

                   channel_name = i['recipient']

                   channel = EMSChannel.where(:name=>channel_name).first

                   channel = EMSChannel.create(:name=>channel_name) unless channel

                   # pattern : [station_name]

                   puts sz.inspect


                   if sz.size==1
                     station = Station.where(:name=>sz[0]).first
                     if station
                       zone = station.zone
                     end

                   # pattern : [station_name].[zone].[solution]


                   elsif sz.size==3 and sz[2] == namez
                     zone = Zone.where(:name=> /#{sz[1]}/i).first

                     station = Station.where(:name=>sz[0],:zone_id=>zone.id).first
                   else
                     zone = Zone.where(:name=>sz[0]).first
                     unless zone
                       station = Station.where(:name=>sz[1]).first
                       if station
                         zone = station.zone
                       end
                     else
                       station = Station.where(:name=>sz[1], :zone_id=>zone.id).first
                     end
                   end


                   ems_case = EMSCase.where(:channel_id=>channel.id, :status=>{'$ne'=>'Completed'}).sort(:request_at=>1).first

                   puts ems_case.id if ems_case

                   puts EMSCase.where(:channel_id=>channel.id).count

                   if ems_case

                     station = Station.find ems_case.station_id

                     zone = Zone.find ems_case.zone_id

                   end




                   if station


                   station_id = station.id

                   admit_id = nil
                   admit = Admit.where(:station_id=>station.id, :status=>'Admitted').first
                   admit_id = admit.id if admit


                   if i['media_key']
                     media = zello.retrieve i['media_key']
                     puts "Sender #{i['sender']} To #{i['recipient']}  Type #{i['type']} Path #{media['url']}"

                     uri = URI("#{media['url']}?sid=#{zello.getSID}")
                     content = Net::HTTP.get(uri)
                     filename = media['url'].split("/")[-1]

                      connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override

                      grid = Mongo::Grid::FSBucket.new(connection.database)

                      fid = grid.upload_from_stream(filename,content)
                     # f = File.new "#{filename}", "w"
#
#                      f.write response
#                      f.flush



                     msg = Message.create :channel_id=> channel.id, :sender=> i['sender'], :recipient=> i['recipient'], :recipient_type=> i['recipient_type'], :content=> media['filename'], :ts=> i['ts'], :type=>i['type'], :media_type=>media['type'], :file_id=>fid, :station_id=>station_id, :admit_id=>admit_id


                   else
                     puts "Sender #{i['sender']} To #{i['recipient']} Text #{i['text']}  "

                     msg = Message.create :channel_id=> channel.id, :sender=> i['sender'], :recipient=> i['recipient'], :recipient_type=> i['recipient_type'], :content=> i['text'], :ts=> i['ts'], :type=>i['type'], :station_id=>station_id, :admit_id=>admit_id


                   end
                   end

                   # puts "xxxxx #{zone.inspect }"
                   # puts "xxxxx #{station.inspect }"

                   if zone and station
                   # puts result.to_json
                   path = "miot/#{name}/z/#{zone.name}"
                   puts "path #{path}"
                 # EM.next_tick do
send_msg = <<MSG
#{'Zone.Message'} #{path}
#{msg.to_json}
MSG

       # puts msg
                   redis.publish(path, send_msg)

                 end


                 end

              end


            rescue Exception=>e

              puts e.inspect

                 app.settings.zello_map.delete name


            end




           end




         end

       end


       end

         end






              elsif mode=='ptt'


                puts "Start PTT Solution : Service"

              EM.next_tick do


                thread = Thread.new {


                require 'redis'
                require 'json'
                require "hiredis"

                redis = settings.redis

                  # redis = app.settings.redis
                  #
                  c = "redis://#{":"+REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
                  puts "REDIS CONFIG SERVICE 1 : #{c}"
                  redis = EM::Hiredis.connect c
                  # settings.redis = redis

                begin


                  redis.pubsub.psubscribe("ptt/in/*") do |channel, message|

                          puts "msg in ptt #{channel} : #{message.size} :"

                          t = channel.split("/")
                          name = t[-1]
                          path_name = t[2..-1].join("/")

                          puts "PTT Rquest #{name}"

                          switch name, 'esm-miot-monitor'

                          # t = Thread.new{

                            lines = message.split("\n")
                            tags = lines[0].split(" ")
                            ptt_channel = tags[-1].split('=')[-1]


                            puts "Send to ptt/#{path_name}/#{ptt_channel}"
                            json = JSON.parse(lines[1])

                            obj = json['data']
                            # puts obj.inspect
                            redis.publish("ptt/#{name}/z/#{ptt_channel}", message)
                            redis.publish("ptt/out/#{path_name}/#{ptt_channel}", message)

                              
                             EM.next_tick do  
                              
                            if true # record

                              begin

                              filename = obj['filename']
                              content =   Base64.decode64(obj['file'])
                              audio_tag = "a#{Time.now.to_i}"
                              audio_input_path = File.join("tmp","#{audio_tag}.3gp")
                              audio_output_path = File.join("tmp","#{audio_tag}.mp3")
                              
                              audio_input = File.open(audio_input_path, 'w')
                              audio_input.write content
                              audio_input.close
                              
                              `ffmpeg -y -i #{audio_input_path} -vn -acodec libmp3lame  -af "loudnorm=I=-5:TP=-1.5:LRA=11" #{audio_output_path}`
                              
                              audio_output = File.open(audio_output_path)
                              content = audio_output.read()
                              audio_output.close
                              
                            rescue Exception=>e
                              
                              puts e
                              
                            end
                              
                              
                              connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override

                              grid = Mongo::Grid::FSBucket.new(connection.database)

                              fid = grid.upload_from_stream(filename,content)

                              station_id = nil
                              admit_id = nil
                              zone = nil
                              ems_channel = EMSChannel.where(:name=>obj['channel']).first


                              if ems_channel

                                  ems_case = EMSCase.where(:channel_id=>ems_channel.id, :status=>"New").sort(:request_at=>-1).first

                                  if ems_case
                                      zone = ems_case.zone
                                      admit_id = ems_case.admit_id
                                      station_id = ems_case.station_id if ems_case.station_id

                                  end

                              end

                              if ems_channel


                                text =""
                                 
                                if url = Setting.get("asr_url") and url != "" 
                              
                                  begin

                                # uri = URI('https://9e81-161-200-93-45.ngrok-free.app/transcribe/')
                              
                                uri = URI(url)
                              
                                request = Net::HTTP::Post.new(uri)
                                puts uri
                                # fout = File.open("tmp/voice_#{Time.now.to_i}.ogg",'w')
 #                                fout.write content
 #                                fout.close
 
                                 # form_data = [['file',  File.open("tmp/voice_#{Time.now.to_i}.ogg")]] # or File.open() in case of local file
                                 

                                form_data = [['file',  File.open(audio_output_path)]] # or File.open() in case of local file

                                request.set_form form_data, 'multipart/form-data'
                                response = Net::HTTP.start(uri.hostname, uri.port) do |http| # pay attention to use_ssl if you need it
                                  http.request(request)
                                end
                                body = response.body
                                # text =  JSON.parse(body)['text']
                                text = body.force_encoding('UTF-8').encode('UTF-8').split(" ").join
                                
                                puts "size : #{content.size} AI: #{text}"

                                # msg = Message.create :channel_id=> ems_channel.id, :sender=> obj['sender'], :recipient=> obj['channel'], :recipient_type=> "text", :content=> text, :ts=> Time.now.to_i, :type=>"text", :media_type=>"text2speech", :station_id=>station_id, :admit_id=>admit_id
                                
                                
                              rescue Exception =>e
                                puts e.inspect 
                      #          puts e.backtrace
                              end
                                
                                end

                              msg = Message.create :channel_id=> ems_channel.id, :sender=> obj['sender'], :recipient=> obj['channel'], :recipient_type=> "voice", :content=> text, :ts=> Time.now.to_i, :type=>"voice", :media_type=>"voice", :file_id=>fid, :station_id=>station_id, :admit_id=>admit_id



                              if zone
                              # puts result.to_json
                              path = "miot/#{name}/z/#{zone.name}"


send_msg = <<MSG
#{'Zone.Message'} #{path}
#{msg.to_json}
MSG

                              # puts msg
                              redis.publish(path, send_msg)



                      
                         

                            end
                            
                            
                          end
                            

                              end


                            end




                          # }


                  end





               end

           }

             end # em next_tick



     elsif mode=='service'

    

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

       # switch context for name

       name =  tag.split('/')[1]
       switch name, 'esm-miot-monitor'
       redis = settings.redis

       

       # forward to redis
       # redis.publish("miot/#{@context.settings.name}/in", msg_data)

       msg_data = message

       msgs = msg_data.split("EOL\n")

       for msg in msgs

       t = []
       msg.each_line do |line|
         t << line
       end


       headers = t[0].split()
       body = t[1..-1].join("\n")
       cmd = headers[0]
       puts "cmd : #{cmd}"

       case cmd

       when 'Monitor.Update'


       when 'GPS.Send'




         settings.position_list[name] = {} unless settings.position_list[name]
         settings.ambu_status[name] = {} unless settings.ambu_status[name]

         ambu_status = settings.ambu_status[name]


         sender = headers[1].split("=")[-1]

          
          
         puts "GPS Sender : #{sender}"
          
            settings.position_list[name][sender] = [] unless settings.position_list[name][sender]
            json = JSON.parse(body)
            obj = json['data']
            settings.position_list[name][sender] << obj
            
            puts obj
            
            if obj['fcm_token']
             
              device = EMSDevice.where(:name=>sender).first
              
              unless device
                device = EMSDevice.create(:name=>sender, :type=>last['type'], :fcm_token=>obj['fcm_token']) 
              else
                device.update_attributes :fcm_token=> obj['fcm_token']
              end
              
              receiver = headers[2].split("=")[-1]
              device.update_attributes :vehicle_id=>receiver
            end
            
            
            puts settings.position_list[name][sender].inspect
            
            if settings.position_list[name][sender].size > 20
              
              puts 'reset'
              
              last = settings.position_list[name][sender][-1]
              
                          
              default_zone = Zone.where(:default=>'true').first
              
              if default_zone and Ambulance.where(:device_no=>sender).first == nil 
                  # ambu = Ambulance.create :name=>sender.upcase,  :location_policy=>'APP', :device_no=>sender, :zone_id=> default_zone.id
              end
                
              device = EMSDevice.where(:name=>sender).first
              
              device = EMSDevice.create(:name=>sender, :type=>last['type']) unless device
              
              receiver = headers[2].split("=")[-1]
              device.update_attributes :vehicle_id=>receiver
              
              device_log = EMSDeviceLog.create :device_id=>device.id, :data=> settings.position_list[name][sender][0..-2]
              
              
              settings.position_list[name][sender] = [last]
              
              
            end
           
             

           # if obj['device_type']=='mobile'
           #
           #  puts "GPS #{obj.inspect}"
           #
           #  ambu = Ambulance.where(:device_no=>obj["device_no"]).first if obj["device_no"]
           #  ambu = Ambulance.where(:name=>json["receiver"]).first unless ambu
           #
           #
           #
           #  if ambu
           #
           #    ambu_status[ambu.id.to_s] = obj
           #
           #    puts ambu_status.inspect
           #
           #  end
           #
           # end









       when 'Ambu.Update'


        # puts "#{channel}: #{tag}: \n#{message} #{Time.now.to_f}"

        json = JSON.parse(body)


        settings.ambu_status[name] = {} unless settings.ambu_status[name]
        ambu_status = settings.ambu_status[name]


        json.each_pair do |k,v|


                ambu_status[k] = v


          #  ambu = Ambulance.find k
          #  puts "GPS #{k}"
          #
          #  puts v.inspect
          #
          # if ambu
          #
          #
          #    ambu.update_attributes :last_location=>"#{v['lat']},#{v['lng']}"
          #
          #    station_status[v['station_id']] = v
          #
          #
          # end


        end




# register message receiver
       when 'EMD.Update'
         
          pdata =  ActiveSupport::JSON.decode(body)
          
          settings.emd_map[name] = {} unless settings.emd_map[name]
          zone_name = pdata['zone_name']
          user_id = pdata['user_id']
          status = pdata['status']
          
          settings.emd_map[name][zone_name] = {} unless settings.emd_map[name][zone_name]
          last_update = Time.now 
          pdata['last'] = last_update
          pdata['work_load'] = EMSCase.where(:user_id=>user_id, :status=>'New').count
          user = User.find user_id
          puts pdata
          if user.status!=status
            puts 'setdata'
            user.update_attributes :status=>status
            
            
      
          end
          
          settings.emd_map[name][zone_name][user_id] = pdata # unless settings.emd_map[name][zone_name][user_id]
          
          puts  settings.emd_map.inspect 
         
         
       when 'WS.Select'

# store remote sensing

       when 'Zone.Data'

# store local sensing
        when 'Data.Spot' , 'SPOT.Send'
          puts "SPOT"
          puts body
         pdata =  ActiveSupport::JSON.decode(body)

         station_name = "Untitled"
         station_name = pdata['station'] if pdata['station']

         if cmd == 'SPOT.Send'
           puts 'SPOT'
           puts pdata.inspect




          station_name = pdata['receiver']
         end
         station_idx = "#{name}|#{station_name}"

         # fw : data sensing for direct receiver
         # EsmMiotMonitor::dispatch cmd, path, pdata.to_json

          puts station_idx

         ref = "-"
         ref = pdata['ref'] if pdata['ref']

         data = "{}"
         data = pdata['data'] if pdata['data']

         admit = nil

         station_id = nil
         station = nil


         settings.stations[name] = {} unless settings.stations[name]


         # register or retrieve station

         station = Station.where(:name=>station_name).first


         if cmd == 'SPOT.Send'

           ems_case = EMSCase.where(:status=>"New", :station_id=>station.id).first

           if ems_case
             puts 'ems_case'
             admit = ems_case.admit
           end

         end

         unless station

            zone = nil
            if station_name.index("_")
              zone = Zone.where(:name=>station_name.split("_")[0]).first
            end

            zone = Zone.first unless zone
            zone_id = nil
            zone_id = zone.id if zone
            station = Station.create(:name=>station_name,:zone_id=>zone_id)


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

         # data['score'] = 0


         # inject last score
         # unless admit
         if ref and ref!="" and ref !="-"

           patient = Patient.where(:hn=>ref).first


            puts "check patient #{patient.inspect}"


            unless patient

             # previous_admit = Admit.where(:station_id=>station.id,:status=>'Admitted').first
                   patient = Patient.create :hn=>ref
                   admit = Admit.where(:station_id=>station.id,:status=>'Admitted', :patient_id=>patient.id,:admit_stamp=>Time.now).first

            else

                     admit = Admit.where(:status=>'Admitted', :patient_id=>patient.id).first

                     unless admit
                       admit = Admit.create :status=>'Admitted', :patient_id=>patient.id, :station_id=>station.id ,:admit_stamp=>Time.now
                     else
                       if admit.admit_stamp and admit.admit_stamp.strftime("%d-%m-%Y")!=Time.now.strftime("%d-%m-%Y")
                         admit.update_attributes :status=>'Discharged', :discharge_stamp=>Time.now
                         admit = Admit.create :status=>'Admitted', :patient_id=>patient.id, :station_id=>station.id ,:admit_stamp=>Time.now
                       end
                     end

            end


         # end
        end

         if admit

           v = data
           puts 'insert'


           draft = {:admit_id=>admit.id, :station_id=>station.id, :stamp=>  Time.now, :bp_stamp=>v['bp_stamp'], :data=>data.to_json}

           # draft = {:admit_id=>admit.id, :station_id=>station.id,
  #            :bp=>v['bp'], :bp_sys=>v['bp_sys'], :bp_dia=>v['bp_dia'], :bp_mean=>v['bp_mean'],
  #            :pr=>v['pr'], :hr=>v['hr'], :spo2=>v['spo2'], :rr=>v['rr'],:co2=>v['co2'], :temp=>v['temp'], :stamp=>  Time.now, :bp_stamp=>v['bp_stamp'], :data=>data.to_json}
  #


        l = ["bp",
 "bp_sys",
 "bp_dia",
 "bp_mean",
 "pr",
 "hr",
 "spo2",
 "rr",
 "co2",
 "temp","score", "score_name", "weight", "height", "bmi", "patient_type", "staff_id"]

  for li in l

     draft[li.to_sym] = v[li] if v[li] and v[li] != 0  and v[li] != '0'

  end


  draft['station_name'] = v['serial_number']
  draft['send_status'] = true
  
  draft['remote_id'] = "#{ draft['station_name'] }_#{v['record_id']}"
  
           # draft[:bp] = v['bp'] if v['bp']
        #
        #    draft[:bp_sys] = v['bp_sys']
        #    draft[:bp_dia] = v['bp_dia']
        #    draft[:bp_mean] = v['bp_mean']
        #
        #    draft[:pr] = v['pr']
        #    draft[:hr] = v['hr']
        #    draft[:spo2] = v['spo2']
        #    draft[:rr] = v['rr']
        #    draft[:co2] = v['co2']
        #    draft[:temp] = v['temp']
        #    draft[:score] = v['score']


      
          exist_record = DataRecord.where(:remote_id=>draft['remote_id']).first
          


           DataRecord.create  draft unless exist_record



         end




         # data sensing

       when 'Data.Sensing', 'VTS.Send'


             pdata =  ActiveSupport::JSON.decode(body)
             
             puts Time.now.to_s
             puts pdata.inspect 
             puts 

             station_name = "Untitled"
             station_name = pdata['station'] if pdata['station']

             if cmd == 'VTS.Send'
              #  puts 'VTS'
              #  puts pdata.inspect
              station_name = pdata['receiver']
             end

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

             
             ##################################
             ##  find or create new station

             station = Station.where(:name=>station_name).first

             unless station
               
               zone = nil
               if station_name.index("_")
                 zone = Zone.where(:name=>station_name.split("_")[0]).first
               end

               zone = Zone.first unless zone
                    zone_id = nil
                    zone_id = zone.id if zone
                    station = Station.create(:name=>station_name ,:zone_id=>zone_id)
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

            #  if ref and ref!="" and ref !="-"

            #    patient = Patient.where(:hn=>ref).first

            #    unless patient

            #      # previous_admit = Admit.where(:station_id=>station.id,:status=>'Admitted').first


            #      patient = Patient.create :hn=>ref
            #      admit = Admit.where(:station_id=>station.id,:status=>'Admitted', :patient_id=>patient.id,:admit_stamp=>Time.now).first

            #     else

            #        admit = Admit.where(:status=>'Admitted', :patient_id=>patient.id).first

            #          unless admit
            #            admit = Admit.create :status=>'Admitted', :patient_id=>patient.id, :station_id=>station.id ,:admit_stamp=>Time.now
            #          else
            #            if admit.admit_stamp and admit.admit_stamp.strftime("%d-%m-%Y")!=Time.now.strftime("%d-%m-%Y")
            #              admit.update_attributes :status=>'Discharged', :discharge_stamp=>Time.now
            #              admit = Admit.create :status=>'Admitted', :patient_id=>patient.id, :station_id=>station.id ,:admit_stamp=>Time.now
            #            end
            #          end

            #     end


            # else

                admit = Admit.where(:station_id=>station.id,:status=>'Admitted').last
                

            # end
       

          
           
             if admit
               data['score'] = admit.current_score
             end



              settings.senses[name] = {} unless  settings.senses[name]
              # puts settings.senses[name].keys
              old = settings.senses[name][station_name]
              old = old.clone if old

              odata = settings.senses[name][station_name]
              odata = {} unless odata


              # mark history

              if admit!=nil and (data['pr'] or data['spo2'] or data['hr'] or data['bp'])

                odata['admit_id'] = admit.id

                now = Time.now
                

                unless data['bp']
                  # puts data.inspect
                  data['bp'] = odata['bp']
                  data['bp_stamp'] = odata['bp_stamp']
                end
                data['bp_sys'], data['bp_dia'] = data['bp'].split("/") if data['bp'] and data['bp_sys'] == nil
                
                
                
                data['pr'] = odata['pr'] unless data['pr']
                data['hr'] = odata['hr'] unless data['hr']
                data['rr'] = odata['rr'] unless data['rr']
                data['spo2'] = odata['spo2'] unless data['spo2']
                data['temp'] = odata['temp'] unless data['temp']
                data['co2'] = odata['co2'] unless data['co2']
                

                # core":0,"bp":"113/87","pr":114,"hr":114,"rr":18,"temp":37,"spo2":90,"bp_stamp":"133737","ref":"1234"}}}
                record = {:stamp=>now,:bp=>data['bp'],:bp_stamp=>data['bp_stamp'], :pr=>data['pr'],:hr=>data['hr'], :rr=>data['rr'],:spo2=>data['spo2'],:temp=>data['temp'],:co2=>data['co2']}

                odata['vs'] = [] unless odata['vs']

                odata['vs'] << record
                if  odata['vs'].size > 5 
                  odata['vs'].shift
                end

                if data['spot']
                  # puts 'spot'
                 

                  v = data
                  d = DataRecord.create :admit_id=>admit.id, :station_id=>station.id, :bp=>v['bp'], :bp_sys=>v['bp_sys'], :bp_dia=>v['bp_dia'], :bp_mean=>v['bp_mean'], :pr=>v['pr'], :hr=>v['hr'], :spo2=>v['spo2'], :rr=>v['rr'], :co2=>v['co2'], :temp=>v['temp'], :stamp=>  Time.now, :bp_stamp=>v['bp_stamp']

                  #  puts d.inspect
                   
                end


              else


                old_stamp = odata['bp_stamp']



                if data['bp'] and (old_stamp == nil or old_stamp!=data['bp_stamp'])

                  v = data #{:stamp=>now,:bp=>data['bp'],:bp_stamp=>data['bp_stamp'], :pr=>data['pr'],:hr=>data['hr'], :rr=>data['rr'],:spo2=>data['spo2'],:temp=>data['temp'],:co2=>data['co2']}

                  #puts v.inspect
                  puts "#{name} #{station.name} BP = #{data['bp']} #{old_stamp.inspect } #{data['bp_stamp'].inspect}"
                  bp_sys,bp_dia = v['bp'].split('/')
                  DataRecord.create :station_id=>station.id, :bp=>v['bp'], :bp_sys=>bp_sys, :bp_dia=>bp_dia, :pr=>v['pr'], :hr=>v['hr'], :spo2=>v['spo2'], :rr=>v['rr'], :co2=>v['co2'], :temp=>v['temp'], :stamp=>  Time.now, :bp_stamp=>v['bp_stamp']




                end



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

               # keep sensing data
               
              #  puts "settings.senses"
              #   puts settings.senses[name].keys.inspect

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
       puts e.backtrace

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


      } # end thread

      redis = app.settings.redis

      # c = "redis://#{app.settings.redis_password+"@"  if app.settings.redis_password }#{app.settings.redis_host}:#{app.settings.redis_port}/#{app.settings.redis_db}"
      c = "redis://#{":"+REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"

      puts "REDIS CONFIG SERVICE : #{c}"
      # redis = Redis.new(url: "redis://#{@conf_redis_host}:#{@conf_redis_port}/#{@conf_redis_db}",:driver => :hiredis)
      redis = EM::Hiredis.connect c



      # Redis.new(url: c,:driver => :hiredis)

      redis = Redis.new(url: c,:driver => :hiredis)


      active_zone = {}
      active_list = {}
      senses_queue = {}
      position_list = {}

      ambu_map = {}
      admit_map = {}



      randx = {}

        for name in redis.smembers('esm-miot-monitor')

            randx[name] = rand(10)

        end

        # EM.add_periodic_timer(10) do
        #
        #
        # end


        EM.add_periodic_timer(1) do


          # eout = File.open("err_service.log","a")


          begin

          puts '.'
          now = Time.now
          inow = now.to_i

          if app.settings.apps_rv


          for name in redis.smembers('esm-miot-monitor')#app.settings.apps_rv['esm-miot-monitor']



            active_list[app.settings.name] = {} unless active_list[app.settings.name]
            active_zone[app.settings.name] = {} unless active_zone[app.settings.name]
            senses_queue[app.settings.name] = [] unless senses_queue[app.settings.name]
            # position_list[app.settings.name] = {} unless position_list[app.settings.name]

              # puts "#{name} station = #{app.settings.stations[name]==nil} sense = #{app.settings.stations[name]==nil}"
              #
              # if app.settings.stations[name] == nil and app.settings.senses[name] == nil
              #
              #   puts active_list.inspect
              #   puts active_zone.inspect
              #   puts
              # end
              
              ambu_status = app.settings.ambu_status[name]
              position_list = app.settings.position_list[name]


              if  true || app.settings.apps_ws[app.settings.name] #and app.settings.stations[name] and app.settings.senses[name]





                  switch name, 'esm-miot-monitor'

                  # puts app.settings.stations[name].inspect
                  # puts  app.settings.senses[name].inspect


                  # routin 10 sec

                  if inow!=nil and randx[name]!=nil and (inow+randx[name])%10 == 0




                  puts "app : #{name}"


                    if senses_queue[app.settings.name]

                      # puts "queue #{senses_queue[app.settings.name].size}"

                      # insert(senses_queue[app.settings.name].collect{|i| i.to_json})

                      for sense in senses_queue[app.settings.name]

                        sense.save

                      end

                      senses_queue[app.settings.name].clear

                    end

                    active_zone[app.settings.name] = {}


                    # if admit = Admit.where(:status=>'Admitted', :zone_id=>{'$ne'=>nil}).first
      #
      #                 zone = admit.zone
      #
      #               if zone
      #                 active_zone[app.settings.name][zone.id] = zone
      #                 app.settings.senses[app.settings.name] = {} unless app.settings.senses[app.settings.name]
      #
      #               end
      #
      #               end
      
                    now = Time.now 
                    now24 = now - 24*60*60
                    # now24 = now - 5*60

                    for zone in Zone.all 
                        

                        if admit = Admit.where(:admit_stamp.gte=>now24, :status=>'Admitted', :zone_id=>zone.id).sort(:admit_stamp.desc).first or zone.mode =='ems' or zone.mode =='telecare'
                         
                                               
                         active_zone[app.settings.name][zone.id] = zone
                         app.settings.senses[app.settings.name] = {} unless app.settings.senses[app.settings.name]
                       
                        end
                        
                      
                    end
                      

                    for s in Station.all


                      if app.settings.live[name] and app.settings.live[name][s.name]

                        active_list[app.settings.name][s.name] = s
                        active_zone[app.settings.name][s.zone_id] = Zone.find s.zone_id

                      end




                    end

                   unless active_zone[app.settings.name]
                     puts "Problem :"
                     puts app.settings.name.inspect
                     puts active_zone.inspect
                     puts
                   else
                      active_zone[app.settings.name].values.each  do |z|

                              puts "Check Zone : #{z.name}"


                                    admits = Admit.where(:admit_stamp.gte=>now24, :zone_id=>z.id, :status=>'Admitted').all

                                    admit_map[name] = {} unless admit_map[name]

                                    admit_map[name][z.id] = admits
                                    
                                    stations = Station.where(:zone_id=>z.id).all
                                    
                                    for a in admits
                                      for s in stations
                                        si =  app.settings.senses[app.settings.name][s.name]
                                        si.delete 'admit_id' if si and si['admit_id'] == a.id and a.station_id!= si['station_id']
                                      end
                                      
                                    end


                                    if z.mode == 'aoc' || z.mode == 'ems'

                                            if list = Ambulance.where(:zone_id=>z.id).all and list.size > 0

                                              

                                              if ambu_status and position_list

                                              for i in list

                                                last =  ambu_status[i.id.to_s]

                                                if  vl = position_list[i.device_no]    # v = ambu_status[i.id.to_s]
                                                  
                                                
                                                  
                                                  v = vl[-1]
                                                  
                                                  
                                                  
                                                  if v and ( last == nil or last['ts']!=v['ts'])
                                                  
                                                    i.update_attributes :last_location=>"#{v['lat']},#{v['lng']}"
                                                    
                                                    ambu_status[i.id.to_s] = v
                                                    
                                                    # position_list[i.device_no] = []
                                                   
                                                  end
                                                  

                                                end

                                              end

                                              end

                                              ambu_map[name] = {} unless ambu_map[name]

                                              ambu_map[name][z.id] = list


                                            end
                                    end






                      end

                    end


                  end




                # each Zone

                # puts  active_zone[app.settings.name].inspect
               #  puts  active_list[app.settings.name].inspect

               if  active_zone[app.settings.name]
                 
           
                 
                active_zone[app.settings.name].values.each  do |z|
                  

                  puts "Active Zone :#{app.settings.name} #{z.name if z }"

                  active_list[app.settings.name] = {} unless active_list[app.settings.name]

                  snames = active_list[app.settings.name].values.collect{|i| i.name if i['zone_id']==z.id }.compact

                  ss = {}
                  ss = app.settings.senses[name].select{|k,v| snames.index(k) } if app.settings.senses[name]

                  result = {:time=>Time.now, :list=>snames,:data=>ss}
                  
                  
                  
                  result[:emd] = app.settings.emd_map[app.settings.name][z.name]  if  app.settings.emd_map[app.settings.name]
                

                  emt_result = nil
                  emt_result = {:time=>Time.now, :ems_data=>{}} if z.mode=='ems'
                  
                  
                  

                  admits = admit_map[name][z.id]
                  
         
                  

                  if z.mode == 'aoc' || z.mode == 'ems'

                  
                
                  
                          if ambu_map[name] and list = ambu_map[name][z.id] and list.size > 0 #and position_list

                       
                            result[:ambu_data] = {}

                            ambu_status = app.settings.ambu_status[name]

                        

                            for i in list
                                  am = i

                                  # l = admits.collect{|a| a if a.ambulance_id==i.id }.compact   #            Admit.where(:ambulance_id=>i.id, :status=>'Admitted').first
                                  #
                                  # puts l.inspect
                                  #
                                  # admit = l[0] if l.size==1
                                  #
                                  # am[:admit_id] = admit.id if admit
                                  
                                  if position_list and position_list[i.device_no]  
                                  
                                  vl = position_list[i.device_no] 
                                   
                                  last =  ambu_status[i.id.to_s]
                                  v = nil
                                  
                                  v = vl[-1] if vl and vl.size > 0 
                                  
                        
                                  if ambu_status and v and ( last == nil or  last['ts']!=v['ts'] )
                                      
                                      
                                      
                                      am.last_location = "#{v['lat']},#{v['lng']}"

                                      # puts "Location #{am.name} #{am.last_location}"

                                      # ambu_status.delete am.id.to_s
                                      
                                      ambu_status[am.id.to_s] = v

                                  end
                                  
                                  end


                                  result[:ambu_data][i.id] = am
                                  
                                  
                                  

                            end

                          end

                  end







                              if admits and admits.size > 0

                                result[:admit_data] = {}



                                for i in admits

                                  ad = {}

                                  ad[:patient] = i.patient
                                  ad[:station_name] = nil
                                  ad[:station_name] = i.station.name if i.station
                                  ad[:note] = i.note

                                  puts "#{i.id} #{i.admit_stamp} #{now - i.admit_stamp}"

                                  if z.mode == 'ems'

                                      case_record = EMSCase.where(:admit_id=>i.id).first

                                      if case_record

                                          commands = EMSCommand.where(:case_id=>case_record.id).all

                                          routes = AocCaseRoute.where(:admit_id=>i.id, :response=>nil).all
                                          
                                          if target_route = AocCaseRoute.where(:admit_id=>i.id, :status=>'STARTED' ).first and target_route.last_cal
                                            emt_result[:est_time] = "#{target_route.act_duration-(Time.now - target_route.last_cal)}"
                                            emt_result[:arrival_at] = " #{(target_route.last_cal+target_route.act_duration).strftime('%H:%M:%S')}"
                                            
                                          end
                                          
                                          emt_result[:ems_data][case_record.id] = {:case_record=>case_record, :commands=>commands, :routes=>routes, :current_time=>Time.now}

                                      end

                                      emt_result[:ambu_data] = result[:ambu_data]

                                  end
                                  result[:admit_data][i.id] = ad


                                end

                                  result[:admit_id] = admits.collect{|i| i.id}

                              end

                              result[:status] = '200 OK'

                              # puts result.to_json
                              path = "miot/#{name}/z/#{z.name}"
                            # EM.next_tick do
msg = <<MSG
#{'ZoneUpdate'} #{path}
#{result.to_json}
MSG
redis.publish(path, msg)

if z.mode=='ems'
  puts 'ems'
  path = "miot/#{name}/z/#{z.name}/EMT"
msg = <<MSG
#{'EMS.Update'} #{path}
#{emt_result.to_json}
MSG
  redis.publish(path, msg)
end

                end
                     end

                # each Station
                if  active_list[name]

              

                active_list[name].values.each do |s|

                    if settings.live[name]

                    settings.live[name][s.name]-=1 if  settings.live[name][s.name] and settings.live[name][s.name]>0

                    if  settings.live[name][s.name] and  settings.live[name][s.name]<=0

                      # settings.senses[name].delete s.name
                      settings.live[name].delete s.name

                      e = settings.senses[name][s.name]

                      e['pr'] = '-'
                      e['spo2'] = '-'
                      e['bp'] = '-'
                      e['hr'] = '-'
                      e['rr'] = '-'
                      e['temp'] = '-'
                      e['co2'] = '-'
                      e['msg'] = '-'



                      puts "Deleted #{s.name}"

                    else
                    ##############################################################################################
                    # puts '-----------------------------live---'
                    # puts settings.live[name].inspect

                    v = app.settings.senses[name][s.name]

            
                    # puts '-----------------------------senses---'
                    # puts v.inspect
                    # puts '-----------------------------senses---'
                    # puts v['admit_id']

                                               #    
                            #       # store to sense



                            # if  v['admit_id'] == nil
                              # puts "YYY #{v['admit_id']}"
                            # end 
                                # puts '--------------------------------'
                                # puts v.inspect

                            #
                                   if v and v['station_id'] and v['admit_id']
                                      #  puts "YYY #{v['admit_id']}"
                                     # puts 'enter 1 '

                                     # admit = Admit.find v['admit_id']


                                     if v['admit_id']


                                     # admit = Admit.find v['admit_id']
                                     la =  admit_map[name][s.zone_id].collect{|a| a if a.id==v['admit_id']}.compact
                                     admit = nil
                                     admit = la[0] if la.size==1

                                     # admit = nil

                                     # puts 'admit'


                                     if admit and admit.status == 'Admitted'

                                     start_time = now
                                     start_time = v['current_time'] if v['current_time']
                                     v['current_time'] = now

                                     # if v['lat']
                                     #
                                     # ambu = Ambulance.find  admit.ambulance_id
                                     #
                                     # if ambu
                                     #   # ambu.update_attributes :last_location=>"#{v['lat']},#{v['lng']}"
                                     # end
                                     #
                                     # end

                                     if admit.period and admit.period!=""

                                       t =  (now-admit.created_at).to_i/60%admit.period
                                       lt =  (now-admit.created_at).to_i/60/admit.period
                                       app.settings.last_map[v['station_id']] = 0 unless app.settings.last_map[v['station_id']]
                                       llt = app.settings.last_map[v['station_id']]
                                       # puts "p #{admit.period} t #{t} lt #{lt} llt #{llt}"



                                       if t==0



                                         if llt!=lt

                                           puts "Auto monitor #{v['station_id']}"


                                           bp_sys,bp_dia = v['bp'].split('/')


                                           if admit.record_status!='Stop'
                                             
                                             DataRecord.create :admit_id=>admit.id, :bp=>v['bp'], :bp_sys=>bp_sys, :bp_dia=>bp_dia, :pr=>v['pr'], :hr=>v['hr'], :spo2=>v['spo2'], :co2=>v['co2'], :rr=>v['rr'], :temp=>v['temp'], :stamp=> now

                                           end

                                           app.settings.last_map[v['station_id']] = lt

                                         end

                                       end

                                     end
                            #
                            #
                            #
                            #          # puts 'enter 2 '
                            #
                            #
                                     px = {:admit_id=>v['admit_id'], :station_id => v['station_id'],  :stop_time=>now, :start_time=>start_time,:bp=>v['bp'],:temp=>v['temp'],:co2=>v['co2'], :bp_sys=>bp_sys, :bp_dia=>bp_dia, :pr=>v['pr'], :hr=>v['hr'], :spo2=>v['spo2'], :rr=>v['rr'], :stamp=> now}

                                     px[:bp_stamp] = v['bp_stamp']

                                     if v['bp'] and v['bp'].index('/')

                                       t = v['bp'].split('/')
                                       px[:bp_sys] = t[0].to_i
                                       px[:bp_dia] = t[1].to_i

                                     end

                                     px[:lat] = v['lat']
                                     px[:lng] = v['lng']

                                     px[:dvr_sp] = v['dvr_sp']
                                     px[:dvr_hx] = v['dvr_hx']
                                     px[:dvr_ol] = v['dvr_ol']

                                     px[:msg] = v['msg']

                                     px[:vs] = v['vs'].to_json

                                     v.delete 'vs'

                                     px[:data] = v.to_json
                                     
                                     if admit.record_status!='Stop' #and v['vs']
                                     
                                     senses_queue[name] << Sense.new(px)

                                     end

                                     end

                                     else

                                     v.delete 'admit_id'

                                   end

                                   end


                                   if v

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
      rescue Exception=>e

        puts e.inspect
        puts e.backtrace



        # eout.puts e.inspect
     #    eout.puts e.backtrace


      end

        end
      end

    end

end
end


module Sinatra


 register EsmMiotMonitor

end
