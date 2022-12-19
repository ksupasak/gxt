
require 'sinatra'
require 'socket'
require 'sinatra/base'
require 'net/http'
require 'nokogiri'

  require 'sinatra-websocket'
require 'websocket-client-simple'

require_relative '../lib/miot'



# class MyThinBackend < ::Thin::Backends::TcpServer
#   def initialize(host, port, options)
#     super(host, port)
#     @ssl = true
#     @ssl_options = options
#   end
# end
#
# configure do
#   set :environment, :production
#   set :bind, '0.0.0.0'
#   set :port, 9292
#   set :server, "thin"
#   class << settings
#     def server_settings
#       {
#         :backend          => MyThinBackend,
#         :private_key_file => "../../private.key",
#         :cert_chain_file  => "../../server.crt",
#         :verify_peer      => false
#       }
#     end
#   end
# end


  set :bind, '0.0.0.0'
  set :port, 8080



  set :sockets, []

  get '/' do

    if !request.websocket?
      erb :index
    else
      request.websocket do |ws|
        ws.onopen do
          # ws.send("Hello World!")
          settings.sockets << ws
        end
        ws.onmessage do |msg|
          # EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
        end
        ws.onclose do
          # warn("websocket closed")
          settings.sockets.delete(ws)
        end
      end
    end
  end




 EM.next_tick do

   lung_data = File.open(File.join(File.dirname(__FILE__),'views/lung.tsv')).read().split("\n").collect{|i| t = i.split("\t").collect{|j| j.to_i} ; [t[1],t[3],t[2]]  }
   idx = 0

   buffer = []

   EM.add_periodic_timer(0.25) do
     puts '.'

     15.times do |i|
       d = lung_data[idx]

       if d

       # buffer << [d[0]+rand(10),d[1]+rand(10),d[2]+rand(10)]
       # buffer << [100,100,d[2]+rand(10)]
       buffer << [d[0],d[1],d[2]]


       end

     idx+=1
     idx=0 if idx > lung_data.size
     end

   end

   EM.add_periodic_timer(1) do

      puts "tick #{buffer.size}"



      EM.next_tick {

        settings.sockets.each{|s|

          s.send(buffer.to_json)

        }

        buffer.clear
      }






   end


 end
