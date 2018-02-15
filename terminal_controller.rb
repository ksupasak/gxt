
get '/terminal' do
  @info = 'Hello world'

  
  
  if !request.websocket?
      # erb 'This is a secret place that only <%=session[:identity]%> has access to!'

      erb :"terminal/index", :layout=>:"terminal/layout"

    else
       request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.sockets << ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
           settings.sockets.delete(ws)
         end
       end
     end
  
  
end
