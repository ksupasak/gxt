
require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
# require 'em-http-server'


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


devices = []
r = 0.02

num.times do |i|
  data = {:id=>i}
  data[:device_no]= "gps#{format("%03d",i+1)}"
  
  data[:lat] = 13.6908282+r*Math.cos((Time.now.to_i*(360/(num+1)))*Math::PI/180)
  data[:lng] = 100.6987491+r*Math.sin((Time.now.to_i*(360/(num+1)))*Math::PI/180)
  data[:ws] = connect(solution, host)
  # data[:lat] = 13.6908282+0.005*Math.cos((Time.now.to_i*2+sp)*Math::PI/180)+sx
  # data[:lng] = 100.6987491+0.005*Math.sin((Time.now.to_i*2+sp)*Math::PI/180)+sy
  
  devices << data
  
end


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


while true


begin




# bind_event ws

period = 0

EventMachine.run {

  puts 'start em'

  EM.add_periodic_timer(speed) do


     now = Time.now
     stamp = now.to_json
 
     num.times do |i|
       
       d = devices[i]
       d[:receiver] = d[:device_no]
       d[:device_type] = 'mobile_sim'
       data = {:device_no=>d[:device_no]}
       data[:type] = 'gps'
       data[:ts] = Time.now.to_i
       data[:lat] = 13.6908282+r*Math.cos((Time.now.to_i+(360/(num+1))*(i+1))*Math::PI/180)
       data[:lng] = 100.6987491+r*Math.sin((Time.now.to_i+(360/(num+1))*(i+1))*Math::PI/180)
       d[:sender] =  d[:device_no]
       d[:stamp] = Time.now 
       d[:data] = data
       msg = <<MSG
GPS.Send sender_id=#{d[:device_no]} receiver_id=#{d[:device_no]}
#{d.to_json}
MSG
           puts msg
           puts "send #{Time.now}"
           ws = d[:ws]
        ws.send(msg)
       
       
     end




  end



}



rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

  sleep(5)
end


end