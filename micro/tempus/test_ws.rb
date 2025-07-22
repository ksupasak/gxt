require 'websocket-client-simple'
require 'eventmachine'
require "active_support"
require "active_support/core_ext/date/calculations"
require 'json'

def connect solution, host
  connect_url = "wss://#{host}/ws/#{solution}/Home/index"
  puts connect_url
  WebSocket::Client::Simple.connect connect_url
end




name = 'Bed01'
name = ARGV[0] if ARGV[0]

ref = '-'
ref = ARGV[1] if ARGV[1]

host = 'pcm-life.com'
host = ARGV[2] if ARGV[2]


solution = 'miot'
solution = ARGV[3] if ARGV[3]





begin

ws = connect solution, host
bind_event ws

EventMachine.run {

  puts 'start em'

  EM.add_periodic_timer(1) do
    now = Time.now
    stamp = now#.to_json
    name = "A10101"
    ref = "-"

    data = {}

    bp = "#{100+rand(22)}/#{70+rand(20)}"
    data[:bp] = bp if bp
    data[:pr] = 60 + rand(60)
    data[:hr] = data[:pr]
    data[:rr] = 18 + rand(4)
    data[:temp] = 36 + rand(4)

    data[:co2] = 30 + rand(20)

    data[:spo2] = 90+rand(10)
     bp_stamp = Time.now
    data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
    msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'receiver'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
        # puts msg
        puts "send #{Time.now} #{msg}"
     ws.send(msg)
    
  end  
    
}


rescue Exception=>e
  
  puts e
  
end