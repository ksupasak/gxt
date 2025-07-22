
register_app 'ptz', 'gxt-ptz'

require 'serialport'





module GxtPtz
  
  
  class CameraSetting
    include MongoMapper::Document
    key :name, String
  
    key :servo1_name, String
    key :servo2_name, String
    key :servo3_name, String
    key :servo4_name, String
    key :servo5_name, String
    key :servo6_name, String
    
    key :servo1, String
    key :servo2, String
    key :servo3, String
    key :servo4, String
    key :servo5, String
    key :servo6, String
    
    key :power_gpio, String # 13
    
    key :power_schedule_1, String
    key :power_schedule_2, String
    key :power_schedule_3, String
    key :power_schedule_4, String
    key :power_schedule_5, String
    key :power_schedule_6, String
    key :power_schedule_7, String
    
    key :servo12, String
    
    
 
  end
  
  class CameraSettingController < GXTDocument

  end
  
   class HomeController < GXT
     
     
     
     def websocket request
       
      
           request.websocket do |ws|

             puts 'init websocket '
             

              ws.onopen do
                puts 'init websocket '
                @context.settings.apps_ws[@context.settings.name] << ws
                @context.settings.apps_ws_rv[ws] = @context.settings.name
                
              end
              
              ws.onclose do
                warn("websocket closed")
                @context.settings.apps_ws[@context.settings.name].delete(ws)
              end
              
              ws.onmessage do |msg|
                name =  @context.settings.apps_ws_rv[ws]
                switch name
                puts  "msg from #{@context.settings.name} #{msg}"

                t = msg.split(",")
                if t[0]=='servo12'
                  
                      
                  # puts @context.settings.settings.methods.inspect
                  
                      @context.settings.last = msg
                  
                     # setting = CameraSetting.first
 #                     if setting
 #                       setting.update_attributes :servo12=>msg
 #                     end
                     
                     
                end
                 
                for i in @context.settings.apps_ws[@context.settings.name]
                    # if ws!=i
                      i.send(msg)
                    # end
                 end
              # end

     
             end
           end
            
      end      
     
   end
  
end

module GxtPtz

def self.settings
      @@settings
end



def self.stamp text
  
  t = text.split(':').collect{|i| i.to_i}
  t = t[0]*60+t[1]
  
end

def self.registered(app)
  
     puts 'PTZ Ctrl Daemon'
     @@settings = app.settings
     
     settings.set :ws_map, {}
     settings.set :cmd_map, {}
     settings.set :last, nil
     
     gpio_stage = 1
     flush = true
     
     
     EM.next_tick { 
        EM.add_periodic_timer(1) do
          if app.settings.apps_rv
            
          
      
            
            
          for name in app.settings.apps_rv['gxt-ptz']
          switch name
          
          
          
          if app.settings.apps_ws[app.settings.name]
        
         
            setting = CameraSetting.first
            
            if setting
              # gpio,13,0
              
              day = Time.now.wday
              day = 7 if day == 0 
              period = setting["power_schedule_#{day}"]
              # puts "power_schedule_#{day}"
              # puts setting["power_schedule_#{day}"].inspect 
              if period and period.size > 0 and t = period.split("-") and t.size==2
                puts "Today Power Schdule : #{period} - Now : #{Time.now.strftime('%H:%M')} #{gpio_stage}"
             
                
                now = stamp(Time.now.strftime('%H:%M'))
                   for ws in app.settings.apps_ws[app.settings.name]
                     ws.send "schedule,#{Time.now.strftime('%H:%M:%S')},#{period}"
                    end
                    
                start = stamp(t[0])
                stop = stamp(t[1])
                
                if now >= start and now <= stop
                  flush = true if gpio_stage == 0
                  gpio_stage = 1
                else
                  flush = true if gpio_stage == 1
                  gpio_stage = 0
                end
                
                if flush
                  
                if gpio_stage == 1
                  for ws in app.settings.apps_ws[app.settings.name]
                    puts "Power On"
                    ws.send "gpio,#{setting.power_gpio},1"
                  end
                else
                  for ws in app.settings.apps_ws[app.settings.name]
                    puts "Power Off"
                    ws.send "gpio,#{setting.power_gpio},0"
                  end
                end
            
                end
                    flush = false
                
                
                # for ws in app.settings.apps_ws[app.settings.name]
                #                  ws.send "alive now #{now} : start #{start} - stop #{stop}"
                #  end
                if Time.now.to_i%10==0
                for ws in app.settings.apps_ws[app.settings.name]
                  # ws.send setting.servo12
                  app.settings.last = setting.servo12 if setting.servo12 and  app.settings.last ==nil
                  setting.update_attributes :servo12=>app.settings.last if setting.servo12 != app.settings.last
                  ws.send app.settings.last if app.settings.last
                  
                end
                end
                
              else
                puts "Schedule is not Set"
                
              end
              
               
              
            else
                # gpio,13,0
            end
            
           
            
          end
          
          
          
          end
          
          end
        
        end
      }

end
end

module Sinatra


 register GxtPtz

end