
register_app 'ptz', 'gxt-ptz'

require 'serialport'



# require_relative 'models'
# begin
#   require 'rpi_gpio'
#   @serial_port = SerialPort.new("/dev/serial0", 9600, 8, 1, SerialPort::NONE)
# rescue
#   
# end


module GxtPtz
  
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
              
              ws.onclose do
                warn("websocket closed")
                @context.settings.apps_ws[@context.settings.name].delete(ws)
              end
              
              ws.onmessage do |msg|
                name =  @context.settings.apps_ws_rv[ws]
                switch name
                puts  "msg from #{@context.settings.name} #{msg}"


                def ptz ser, ch, target

                v = target
                ch = ch

                v1 = v&127 
                v2 = (v>>7)&127 
                c = [170,12,4,ch,v1,v2]

                for i in c
                ser.write i.chr  
                end
                ser.flush

                end
              
              
              ser = @serial_port 

              ts = msg.split(",")
              p = ts[1].to_i
              t = ts[2].to_i

              if ts[0]=='servo'
                
                ptz ser, 1, p
                ptz ser, 0 , t
              
              elsif ts[0]=='servo2'
                
                ptz ser, 2, p
                ptz ser, 3 , t
                
              elsif ts[0]=='servo3'

                ptz ser, 4, p
                ptz ser, 5, t

              elsif ts[0]=='gpio'
                
                # `ruby ~/gpio.rb #{p} #{t}`
                 # ws.send(msg.data)
                 
                for i in @context.settings.apps_ws[@context.settings.name]
                    if ws!=i
                      i.send(msg.data)
                    end
                 end
              end

     
             end
           end
            
      end      
     
   end
  
end



module Sinatra


 register GxtPtz

end