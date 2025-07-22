require 'net/http'
require 'eventmachine'
require 'em-http-server'

class HTTPHandler < EM::HttpServer::Server
      def process_http_request
            puts  @http_request_method
            puts  @http_request_uri
            puts  @http_query_string
            puts  @http_protocol
            puts  @http_content
            puts  @http[:cookie]
            puts  @http[:content_type]
            # you have all the http headers in this hash
            puts  @http.inspect

            response = EM::DelegatedHttpResponse.new(self)
            response.status = 200
            response.content_type 'text/html'
            response.content = 'It works'
            response.send_response
      end

      def http_request_errback e
        # printing the whole exception
        puts e.inspect
      end

  end

require_relative 'conf'



module EchoServer
   def post_init
     puts "-- someone connected to the echo server!"
   end

   def receive_data data
     send_data ">>>you sent: #{data}"
     close_connection if data =~ /quit/i
   end

   def unbind
     puts "-- someone disconnected from the echo server!"
   end
end

# Note that this will block current thread.
EventMachine.run {
  
  
  ## Echo socket 
  EventMachine.start_server "127.0.0.1", 8081, EchoServer
  
  ## HTTP server
  EventMachine::start_server "127.0.0.1", 8080, HTTPHandler
  
  ## timer method
  # EM.add_periodic_timer(1) do
  #   puts 'ok'
  # end
  
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






# require_relative 'devices/vista-120-gw'
# require_relative 'devices/vista-120-v1-gw'
# require_relative 'devices/b450-gw'
# 
# 
# puts HOST_IP
# 
# threads = []
# 
# 
# threads << Thread.new {
# Device::monitor_vista_120_v1()
# }
# 
# 
# threads << Thread.new {
# Device::monitor_b450_v1()
# }
# 
# 
# threads << Thread.new {
# Device::monitor_vista_120_v2()
# }
# 
# 
# for i in threads
#   
#   i.run
#   
# end
# 
# for i in threads
#   i.join
# end
