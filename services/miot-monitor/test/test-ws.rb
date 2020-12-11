

require 'net/http'
require 'websocket-client-simple'

require 'socket'
  
  connect_url = "ws://pcm-life.com:8020/miot/Home/index"
  
  connect_url = "wss://localhost:1792/miot/Home/index"
  
  
   ws = WebSocket::Client::Simple.connect connect_url
   
   
   ws.on :message do |msg|
      puts 'on message'
     puts msg.data
   end

   ws.on :open do
     puts 'on open'
     2000.times do |i|
       
#multi line string
msg = <<EOM
Monitor.Update zone_id=*
STATUS:M1|PR:#{rand(80)}|SPO2:99|SYS:120|DIA:80|MEAN:100
STATUS:S1|WEIGHT:90|HEIGHT:1.80
STATUS:T1|T1:35.4
EOM

     
       
     ws.send msg
     puts 'send'
     sleep(1)
     end
   end

   ws.on :close do |e|
      puts 'on close'
     p e
     exit 1
   end

   ws.on :error do |e|
      puts 'on error'
     p e
   end

   loop do
     ws.send STDIN.gets.strip
   end