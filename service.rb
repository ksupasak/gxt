require 'rubygems'
require 'websocket-client-simple'

def connect
  WebSocket::Client::Simple.connect 'ws://192.168.100.6:1792/a/food/Terminal/index'
end


ws = connect()

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

bind_event ws

   
loop do

  # begin
    ws.send STDIN.gets.strip
  # rescue Exception=>e
  #    disconnect = true
  #    puts 'error connect'
  #    while !disconnect
  #    
  #    sleep 1
  #    
  #    begin 
  #    puts 'retry connect ..'
  #    ws = connect()
  #    disconnect = false
  #    rescue
  #    end
  #    
  #    end
  #    
  #    
  #  end

end


 

 