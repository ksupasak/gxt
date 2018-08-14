
require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
require 'em-http-server'
def connect solution, host, port
  connect_url = "ws://#{host}:#{port}/#{solution}/Home/index"
  puts connect_url
  WebSocket::Client::Simple.connect connect_url
end




name = 'Bed01' 
name = ARGV[0] if ARGV[0]

host = 'miot.esm.local'
host = ARGV[2] if ARGV[2]
port = 1792

ref = '-'
ref = ARGV[1] if ARGV[1]


solution = host.split(".")[0]
solution = ARGV[3] if ARGV[3] 





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

ws = connect solution, host, port


puts "Start"
count = 0
ls = 10

bp = '90/120'
bp_stamp = Time.now


bind_event ws

period = 0

EventMachine.run {
  
  puts 'start em'
  
  EM.add_periodic_timer(0.5) do
  
  
  
  
    
     now = Time.now
     stamp = now.to_json

     
data = {}
wave = []

w = 2
rps =32

rps.times do |i|
  y = Math.sin(300*w/rps*period*Math::PI/180)*50+50
  wave << format("%.3f",y) 
  
  period += rand(10)
end

# puts wave

data[:wave] = wave
 
msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
    # puts msg
 ws.send(msg)
     
    
  
  
  
  end
  
  # timer method
  EM.add_periodic_timer(1) do
    
    
     now = Time.now
     stamp = now.to_json

     
     data = {}


     data[:bp] = bp
     data[:pr] = 60 + rand(60)
     data[:hr] = data[:pr]
     data[:rr] = 18 + rand(4)
     data[:so2] = 90+rand(10)
     data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
    # puts msg
     ws.send(msg)
     
     
    
     count += 1

   

     if count%ls==0
       bp_stamp = Time.now

       bp = "#{100+rand(20)}/#{70+rand(20)}"
       ls = 20+rand(10)
       puts "Data sent #{count} times + BP : #{bp}"
       
     end
    
    
  end
  
  ## fire one 
  # 100.times do |i|
  #   t = rand(5000)
  #   EM.add_timer(t/1000.0) do
  #   puts "Quitting #{i} #{t}"
  #   # EM.stop_event_loop
  #   # 
  #   end
  # end
  
}



rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  sleep(5)
end
  

end


# 
# 
# puts "Start"
# count = 0
# ls = 10
# 
# bp = '90/120'
# bp_stamp = Time.now
# while true do 
#   
#   begin
#   
#   uri = URI("http://#{host}:#{port}/miot/Sense/sense")
#   now = Time.now
#   stamp = now.to_json
#   
#   
#   data = {}
#   
#   
#   data[:bp] = bp
#   data[:pr] = 60 + rand(60)
#   data[:hr] = data[:pr]
#   data[:rr] = 18 + rand(4)
#   data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
#   
#   res = Net::HTTP.post_form(uri, 'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)
#   count += 1
#   
#   puts res
# 
#   if count%ls==0
#     bp_stamp = Time.now
#     
#     bp = "#{70+rand(20)}/#{100+rand(20)}"
#     ls = 20+rand(10)
#     puts "Data sent #{count} times + BP : #{bp}"
#   
#   end
#   
#   
#   rescue Exception=>e
#     puts 'Connect Error'+e.inspect 
#   end
#   
#   sleep 1
# end
