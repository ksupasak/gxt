
require 'rubygems'
require 'mqtt'

register_app 'planto', 'esm-planto'


module EsmPlanto


  class HomeController < GXT




   end



#

   
       
end
   
module EsmPlantoService
  
  def self.settings
        @@settings
  end

  def self.registered(app)

       puts 'Start Planto Solution  '

       @@settings = app.settings

       settings.set :ws_map, {}
       settings.set :cmd_map, {}


       thread = Thread.new {

          MQTT::Client.connect('test.mosquitto.org') do |c|
           # If you pass a block to the get method, then it will loop
           c.get('planto/#') do |topic,message|
             puts "#{topic}: #{message}"
           end
         end


       }
       thread.run 


       EM.next_tick { 
          EM.add_periodic_timer(1) do

            puts "planto ok"

          end  

        }

  end
  
  
  end   
   
   
   
   module Sinatra


    register EsmPlantoService

   end
   
          