require 'faye/websocket'
require 'eventmachine'

EM.run {
  
  def connect()
  
  ws = Faye::WebSocket::Client.new('ws://127.0.0.1:1792/a/food/Terminal/index')

  ws.on :open do |event|
    p [:open]
    ws.send('Hello, world!')
  end

  ws.on :message do |event|
    p [:message, event.data]
    
    lines = event.data.split("\n")
    if lines[0]=='print'
      open("| lpr", "w") { |f| f.puts lines[1..-1] }
    end
    
  end

  ws.on :close do |event|
    p [:close, event.code, event.reason]
    ws = nil
    sleep 5
    connect()
  end
  
  end
  
  connect()
  
} 