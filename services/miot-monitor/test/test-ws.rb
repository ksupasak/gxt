

require 'net/http'
require 'websocket-client-simple'

require 'socket'
  
  connect_url = "ws://pcm-life.com:8020/miot/Home/index"
  
  connect_url = "wss://pcm-life.com:8020/miot/Home/index"
  
  
   ws = WebSocket::Client::Simple.connect connect_url
   
   
   ws.on :message do |msg|
     puts msg.data
   end

   ws.on :open do
     10.times do |i|
     ws.send 'hello!!!'
     # sleep(1)
     end
   end

   ws.on :close do |e|
     p e
     exit 1
   end

   ws.on :error do |e|
     p e
   end

   loop do
     ws.send STDIN.gets.strip
   end