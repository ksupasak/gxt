
require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
# require 'em-http-server'
require 'mqtt'

def connect solution, host, port=nil
  

  connect_url = "wss://#{host}/ws/#{solution}/Home/index"
  connect_url = "wss://#{host}:#{port}/ws/#{solution}/Home/index" if port
  
  puts connect_url
  
  return WebSocket::Client::Simple.connect connect_url
end


uri = 'localhost:1792/miot'
uri = ARGV[0] if uri

host, solution = uri.split('/')

mode = 'gps'
mode = ARGV[1].to_i

num = 1
num = ARGV[2].to_i if ARGV[2]

speed = 1
speed = ARGV[3].to_f if ARGV[3]

mqtt_string = "admin:Scu_2010@880b22a0429744488df2940b1696bfe7.s1.eu.hivemq.cloud:8883/inDevices"

mqtt_string = ARGV[4].to_f if ARGV[4]


# MQTT connection details
BROKER_HOST =  mqtt_string.split('@')[1].split(':')[0]#'880b22a0429744488df2940b1696bfe7.s1.eu.hivemq.cloud'
BROKER_PORT =  mqtt_string.split(':')[-1].split('/')[0]#8883 # SSL port
USERNAME =  mqtt_string.split(':')[0]
PASSWORD =  mqtt_string.split(':')[1].split('@')[0] #'Scu_2010'
TOPIC =  mqtt_string.split('/')[1]
CLIENT_ID = 'pcm-life'
puts "MQTT config"
puts "BROKER_HOST #{BROKER_HOST}"
puts "BROKER_PORT #{BROKER_PORT}"
puts "USERNAME #{USERNAME}"
puts "PASSWORD #{PASSWORD}"
puts "TOPIC #{TOPIC}"
puts "CLIENT_ID #{CLIENT_ID}"



devices = []
r = 0.02


# num.times do |i|
#   data = {:id=>i}
#   data[:device_no]= "gps#{format("%03d",i+1)}"
#
#   data[:lat] = 13.6908282+r*Math.cos((Time.now.to_i*(360/(num+1)))*Math::PI/180)
#   data[:lng] = 100.6987491+r*Math.sin((Time.now.to_i*(360/(num+1)))*Math::PI/180)
#   data[:ws] = connect(solution, host)
#   # data[:lat] = 13.6908282+0.005*Math.cos((Time.now.to_i*2+sp)*Math::PI/180)+sx
#   # data[:lng] = 100.6987491+0.005*Math.sin((Time.now.to_i*2+sp)*Math::PI/180)+sy
#
#   devices << data
#
# end


def bind_event ws

ws.on :message do |msg|
  puts msg.data
  lines = msg.data.split("\n")
  if lines[0]=='print'
    open("| lpr", "w") { |f| f.puts lines[1..-1] }
  end

end

ws.on :open do
  ws.send 'hello!!!'
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws = connect()
   bind_event ws
   puts 'retry connect ..'
end

end

#
while true


begin
  
  

  ws = connect(solution, host)
  bind_event ws
  

#
#
#   def random_gps_movement(lat, lon, radius_in_meters = 50)
#     # Earth radius in meters
#     earth_radius = 6_371_000.0
#
#     # Convert radius from meters to radians
#     radius_in_radians = radius_in_meters.to_f / earth_radius
#
#     # Random angle in radians for the direction of movement
#     random_angle = rand(0..2 * Math::PI)
#
#     # Random distance in radians from the start point
#     random_distance = rand(0..radius_in_radians)
#
#     # Calculate new latitude and longitude using haversine formula
#     new_lat = Math.asin(Math.sin(lat * Math::PI / 180) * Math.cos(random_distance) +
#                 Math.cos(lat * Math::PI / 180) * Math.sin(random_distance) * Math.cos(random_angle))
#     new_lon = lon * Math::PI / 180 + Math.atan2(Math.sin(random_angle) * Math.sin(random_distance) * Math.cos(lat * Math::PI / 180),
#                                       Math.cos(random_distance) - Math.sin(lat * Math::PI / 180) * Math.sin(new_lat))
#
#     # Convert radians back to degrees
#     new_lat_deg = new_lat * 180 / Math::PI
#     new_lon_deg = new_lon * 180 / Math::PI
#
#     return { :lat => new_lat_deg, :lng => new_lon_deg }
#   end




require 'mqtt'
require 'json'


# Buffer to hold incoming messages
message_buffer = []

# Thread to handle displaying messages from buffer every 2 seconds
# Thread.new do
#   loop do
#     unless message_buffer.empty?
#       puts "Buffered Messages:"
#       message_buffer.each_with_index do |msg, index|
#         puts "#{index + 1}: #{msg}"
#       end
#       message_buffer.clear
#     else
#       puts "No new messages."
#     end
#     sleep 1 # Display messages every 2 seconds
#   end
# end

# Connect to the MQTT broker and subscribe to the topic
client = MQTT::Client.connect(
  host: BROKER_HOST,
  port: BROKER_PORT,
  ssl: true,           # Enable SSL for secure connection
  username: USERNAME,
  password: PASSWORD,
  client_id: CLIENT_ID
)

puts "Subscribed to #{TOPIC} on broker #{BROKER_HOST}"




Thread.new do
  loop do
  
      # Listen to incoming messages and add them to the buffer
      client.subscribe(TOPIC)

      client.get do |topic, message|
        puts "Received a message on topic #{topic}"
        # Add received message to the buffer
        message_buffer << message
      end
  
  end
end


period = 0

EventMachine.run {

  puts 'start em'
  

  EM.add_periodic_timer(speed) do

    puts 'xx'
     now = Time.now
     stamp = now.to_json
 
     message_buffer.each do |i|
       
       # d = devices[i]
     #   d[:receiver] = d[:device_no]
#        d[:device_type] = 'mobile_sim'
#        data = {:device_no=>d[:device_no]}
#        data[:type] = 'gps'
#        data[:ts] = Time.now.to_i
#
#        data[:lat] = 13.6908282+r*Math.cos((Time.now.to_i+(360/(num+1))*(i+1))*Math::PI/180)
#        data[:lng] = 100.6987491+r*Math.sin((Time.now.to_i+(360/(num+1))*(i+1))*Math::PI/180)
#        data[:spd] = 22
# # =>

      
       # e = random_gps_movement(d[:lat] ,  d[:lng], 50)
      #  d[:lat] = e[:lat]  #13.6908282+r*Math.cos((Time.now.to_i+(360/(num+1))*(i+1))*Math::PI/180)
      #  d[:lng] = e[:lng]
      #  data[:lat] = d[:lat]
      #  data[:lng] = d[:lng]
      
      # {"device_id":"D0001","lat":13.6931658,"lng":100.6920242,"temp":42.1,"rh": 69.4 }
      d = {}
       
      obj = JSON.parse(i)
      
       d[:sender] =  obj['device_id']
       d[:stamp] = Time.now 
       d[:data] = obj
       msg = <<MSG
GPS.Send sender_id=#{d[:sender]} receiver_id=#{d[:sender]}
#{d.to_json}
MSG
           puts msg
           puts "send #{Time.now}"
    
    
           # Check if the connection is open
             if ws.open?
                    ws.send(msg)
             else
               sleep(5)
               ws = connect(solution, host)
               bind_event ws
              
           end
    
   
       
       
     end

  message_buffer.clear


  end



}

  sleep(5)

rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

  sleep(5)
end


end
