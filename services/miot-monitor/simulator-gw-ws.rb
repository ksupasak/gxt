
require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
# require 'em-http-server'


def connect solution, host, port
  connect_url = "wss://#{host}:#{port}/#{solution}/Home/index"
  puts connect_url
  WebSocket::Client::Simple.connect connect_url
end




name = 'Bed01' 
name = ARGV[0] if ARGV[0]


ref = '-'
ref = ARGV[1] if ARGV[1]

host = 'miot.esm.local'
host = ARGV[2] if ARGV[2]
port = 1792


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



lead_idx = 0 
leads = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

while true


begin 

ws = connect solution, host, port


puts "Start"
count = 0
ls = 10

bp = '119/80'
bp_stamp = Time.now


bind_event ws

period = 0

EventMachine.run {
  
  puts 'start em'
  
  EM.add_periodic_timer(1) do
  
  
  
  
    
     now = Time.now
     stamp = now.to_json

     
data = {}
wave = []


lead_template = [700, 876, 880, 588, 304, 40, -168, -216, -204, -120, -76, -96, -92, -76, -76, -88, -84, -76, -84, -72, -72, -72, -80, -68, -76, -80, -68, -64, -72, -64, -60, -68, -72, -60, -60, -48, -16, 16, 52, 80, 124, 160, 196, 220, 240, 260, 284, 300, 312, 316, 320, 320, 320, 312, 300, 276, 264, 236, 200, 152, 108, 68, 20, -32, -68, -96, -124, -132, -144, -148, -136, -128, -124, -120, -120, -124, -116, -116, -112, -112, -112, -112, -112, -108, -104, -104, -104, -104, -100, -84, -80, -72, -68, -64, -60, -52, -48, -44, -40, -36, -36, -36, -36, -20, 8, 48, 88, 116, 128, 140, 152, 148, 144, 128, 112, 84, 60, 24, -20, -48, -56, -60, -52, -48, -48, -48, -48, -48, -48, -44, -44, -44, -44, -44, -44, -44, -64, -108, -140, -100, 80, 340, 604, 824]

w = 2
rps =32
s = 4

max = 1024
min = -1024

rps.times do |i|
  
  # y = Math.sin(300*w/rps*i*Math::PI/180)*rand()*50+50
#   wave << format("%.3f",y).to_f
#
 wave <<  50-(lead_template[lead_idx*s].to_f / 1024) *50
 lead_idx += 1
 lead_idx = 0 if lead_idx*s > lead_template.size
 
  # period += rand(10)
end


rps2 = 200
s2 = 2

# puts wave

# data[:wave] = wave
 

data[:leads] = {} unless data[:leads]


16.times do |x|
  
  # data[:leads][x] = [] unless data[:leads][x] 
  
  id = leads[x]
  wave = []
  
  rps2.times do |i|
  
    # y = Math.sin(300*w/rps*i*Math::PI/180)*rand()*50+50
  #   wave << format("%.3f",y).to_f
  #
   # wave <<  50-(lead_template[id*s2].to_f / 1024) *50
   
   # if(x==2)
   #
   #   wave << 1
   # else
       wave << lead_template[id*s2] if lead_template[id*s2] 
       
       
   # end   
     
     
   
   
   id += 1
   id = 0 if id*s2 > lead_template.size
 
    # period += rand(10)
  end
  data[:leads][x] = wave
  
  leads[x] = id
  
end 
 
 
msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
    # puts msg
    puts "send #{Time.now}"
 ws.send(msg)
     
  
  end
  
  sx = rand()*0.11
  sy = rand()*0.11
  sp = rand()*360
  
  
  # timer method
  EM.add_periodic_timer(1) do
    
    
     now = Time.now
     stamp = now.to_json

     
     data = {}


     data[:bp] = bp
     data[:pr] = 60 + rand(60)
     data[:hr] = data[:pr]
     data[:rr] = 18 + rand(4)
     data[:temp] = 36 + rand(4) 
     
     data[:co2] = 30 + rand(20) 
     
     data[:spo2] = 90+rand(10)
     
     data[:lat] = 13.6908282+0.005*Math.cos((Time.now.to_i*2+sp)*Math::PI/180)+sx
     data[:lng] = 100.6987491+0.005*Math.sin((Time.now.to_i*2+sp)*Math::PI/180)+sy
     # puts Time.now.to_i%360+90
     data[:dvr_sp] = 30
     data[:dvr_hx] = Time.now.to_i*2%360+90
     data[:dvr_ol] = 1
     
     
     data[:msg] = "ALERT:#{Time.now.inspect}"
     
     # puts data.inspect 
     
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

       bp = "#{100+rand(22)}/#{70+rand(20)}"
       ls = 20+rand(10)
       puts "Data sent #{count} times + BP : #{bp}"
       
     end
    
    
  end
  

  
}



rescue Exception=>e
  puts "Try to connect in 5 seconds due to : #{e}"
  puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
  
  sleep(5)
end
  

end



