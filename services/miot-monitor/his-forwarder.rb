require 'rubygems'
require 'websocket-client-simple'
require 'json'
require 'eventmachine'
require 'active_support'

require 'net/http'

require_relative 'conf'

def connect solution
  WebSocket::Client::Simple.connect "ws://localhost:1792/#{solution}/Home/index"
end

def bind_event ws

ws.on :message do |msg|
 #  puts msg.data
#   cmd = `python /home/pi/camera.py`
#
  begin
#   img = Base64.encode64(open("/home/pi/Desktop/image.jpg"){|io|io.read})
#   puts img.size
# msg = <<MSG
# Data.Image station_id=*
# #{img.encode('utf-8').to_json}
# MSG
#
#   ws.send(msg)

      
      
       header,body = msg.data.split("\n")
  
  
       data = ActiveSupport::JSON.decode(body)
       
       

       puts "Get Record #{data.inspect }"
       
       hn = data['ref']

       prefix = hn[0..5].to_i

       if hn.index('/')

         hn = "#{hn[-2..-1]}#{format("%06d",hn[0..hn.index('/')-1])}"

       elsif hn.size==8 and prefix < 300000

         hn = "#{hn[6..-1]}#{format("%06d",prefix)}"

       elsif hn.size<8

         hn = "#{hn[-2..-1]}#{format("%06d",hn[0..-3].to_i)}"
       end

      data['ref'] = hn
       
 
      
      his_host = GW_HIS_IP
      his_port = GW_HIS_PORT

      urix = URI("http://#{his_host}:#{his_port}/his/test_send_anpacurec")
       
      
      res = Net::HTTP.post_form(urix, :hn=>data['ref'], :bp=>data['bp'],:hr=>data['hr'], :bp_stamp=>data['bp_stamp'])
      
  
  rescue Exception=>e

  puts e
end

end

ws.on :open do

end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|d
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws = connect() 
   bind_event ws
   puts 'retry connect ..'
end

end


while true


begin 


  solution = 'miot'
  solution = ARGV[0] if ARGV[0] 

  ws = connect(solution)
  puts 'connect'

bind_event ws

sleep(1)

 protocols = ['Record station_id=*']
# protocols << 'Data.Sensing device_id=Bed01'
# protocols << 'ZoneUpdate zone_id=*'
 
 msg = "WS.Select name=1234\n#{protocols.to_json}"
 puts msg
 ws.send msg


 EventMachine.run {
   
    EM.add_periodic_timer(5) do
       
       msg = "WS.Alive name=1234\n#{Time.now}"
       ws.send msg
        
   end


 }

rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  sleep(5)
end
  

end

 

