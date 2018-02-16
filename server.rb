require 'rubygems'
require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/partial'
require 'sinatra-websocket'
require 'active_support/all'

require 'mongo'
require 'mongo_mapper'

require 'barby'
require 'barby/barcode/code_128'
require 'barby/barcode/ean_13'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'
require 'crc'

register Sinatra::Reloader

set :server, 'thin'
# set :public_folder, File.dirname(__FILE__)+"/public"
# set :bind, '192.168.100.8'
# set :bind, '192.168.100.8'
# set :bind, '202.114.4.119'
# set :bind, '192.168.100.7'
set :bind, '0.0.0.0'

set :port, 1792
set :sockets, []

set :stations, {}
set :senses, {}

set :apps, {}
set :apps_ws, {}
set :extended, {}

require_relative 'apps/gxt/helper'
require_relative 'apps/gxt-food-order/app'
# require_relative 'apps/gxt-food-order2/app'
require_relative 'apps/gxt-food-extended/app'
require_relative 'apps/gxt-cash-deposit/app'
require_relative 'apps/gxt-gold-saving/app'

require_relative 'apps/esm-monitor/app'

register Sinatra::Partial
set :partial_template_engine, :erb

set :mongo_prefix, Proc.new {'gxt'}

# 
# name = solution_name
# app = solution_platform


# default ap
set :name, 'monitor'


def switch name
  
  settings.set :name, name 
  settings.set :app, settings.apps[name]
  MongoMapper.setup({'production' => {'uri' => "mongodb://localhost/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
end

before do 
   
   # settings.set :app, 'gxt-food-order'
  
  if t = request.host.split(".") and t.size>2  and t.size!=4   # detect sub domain 
    solution_name = t[0]  # solution_name
    settings.set :name, solution_name
    MongoMapper.setup({'production' => {'uri' => "mongodb://localhost/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  end
  
    @app = settings.apps[settings.name]
    settings.apps_ws[settings.name] = [] unless settings.apps_ws[settings.name] 
  
    if @app
      settings.set :app, @app
    end
  
   # params[:request]  = request
          settings.set :current_user, 'x'
          settings.set :current_role, 'y'
     if session[:identity] 
       
       u  = User.find session[:identity] 
       
       if u
         @current_user = u.login
         role = Role.find u.role
         @current_role = role.name if role
         settings.set :current_user, @current_user
         settings.set :current_role, @current_role
         
       end
       
     end
     
  

end

configure do
  enable :sessions
  MongoMapper.setup({'production' => {'uri' => "mongodb://localhost/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
end


set :root, File.join(File.dirname(__FILE__))


set :layout, 'layout'
set :public_folder, File.dirname(__FILE__)+"/public"
# set :views, File.dirname(__FILE__)+"/views"

get '/barcode' do
  
 
       mode = 'code_128'
       mode = params[:type] if params[:type]
       barcode = nil
       case mode
       when 'code_128'
         barcode = Barby::Code128B.new(params[:code])
       when 'code_39'
         barcode = Barby::Code39.new(params[:code])
       when 'ean_13'
         barcode = Barby::Ean13.new(params[:code])
       when 'qr_code'
         barcode = Barby::QrCode.new(params[:code])
       end
       code = params[:code].split("/").join("-")
       xdim = 2
       xdim = params[:xdim].to_i if params[:xdim]
       xdim = 1 if xdim <1
       height = 50
       height = params[:height].to_i if params[:height]
       height = 30 if height < 30
       margin = 5
       margin = params[:margin].to_i
       # name = File.join("tmp","#{Time.now.to_i}.#{code}.#{mode}.png")
       # File.open(name, 'w'){|f| f.write  }
       content = barcode.to_png :xdim => xdim, :height => height, :margin =>margin
       headers('Content-Type' => "image/jpeg")
       return content
  
end


get '/promptpay' do
  
       total = params[:total]
       
       head = "00020101021129370016A000000677010111"
       acc = params[:acc]
       acc_value = "02#{format('%02d',acc.size)}#{acc}"
       acc_origin = "5802TH"
       total_value = "54#{format('%02d',total.to_s.size)}#{total}"
       tail = "53037646304"
       tag = "#{head}#{acc_value}#{acc_origin}#{total_value}#{tail}".upcase
       sum = CRC.crc('CRC-16-XMODEM', tag ,0xFFFF).to_s(16)
      
       mode = 'qr_code'
       params[:xdim] = 5
       params[:code] = tag+sum
       
       mode = params[:type] if params[:type]
       barcode = nil
       case mode
       when 'code_128'
         barcode = Barby::Code128B.new(params[:code])
       when 'code_39'
         barcode = Barby::Code39.new(params[:code])
       when 'ean_13'
         barcode = Barby::Ean13.new(params[:code])
       when 'qr_code'
         barcode = Barby::QrCode.new(params[:code])
       end
       code = params[:code].split("/").join("-")
       xdim = 2
       xdim = params[:xdim].to_i if params[:xdim]
       xdim = 1 if xdim <1
       height = 50
       height = params[:height].to_i if params[:height]
       height = 30 if height < 30
       margin = 5
       margin = params[:margin].to_i
       # name = File.join("tmp","#{Time.now.to_i}.#{code}.#{mode}.png")
       # File.open(name, 'w'){|f| f.write  }
       content = barcode.to_png :xdim => xdim, :height => height, :margin =>margin
       headers('Content-Type' => "image/jpeg")
       return content

  
  
end


get '/a/:gxt/:service/*.*' do
  
  
   switch params[:gxt]
   
   
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps", settings.app ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
     
     
   file_path,ext = params[:splat]
   
   
   app_public = File.join("apps",settings.app ,"public")
   app_service_public = File.join(app_public,params[:service].downcase)
   gxt_public = File.join("public")
   l = [app_service_public, app_public, gxt_public]
   file = nil
   for i in l
     
     f = File.join(i,"#{file_path}.#{ext}")
     puts "check for #{f}"
     if File.exist? f
      file = f
      break
      end
   end   
     if file     
   send_file file
 end
   # erb :home

end

get '/:service/*.*' do
  
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps",settings.app ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
     
     
   file_path,ext = params[:splat]
   
   
   app_public = File.join("apps",settings.app ,"public")
   app_service_public = File.join(app_public,params[:service].downcase)
   gxt_public = File.join("public")
   l = [app_service_public, app_public, gxt_public]
   file = nil
   for i in l
     
     f = File.join(i,"#{file_path}.#{ext}")
     puts "check for #{f}"
     if File.exist? f
      file = f
      break
      end
   end   
   if file   
   send_file file
  end
   # erb :home

end





get '/a/:gxt/:service/:operation' do
  
   switch params[:gxt]
  
   if !request.websocket?
   settings.set  :app, settings.apps[params[:gxt]]
   settings.set  :name, params[:gxt]
   
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps", settings.app  ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
   
   @context = self
   @this = eval "#{params[:service]}Controller.new @context, settings"
   # puts @this
   content = eval "@this.#{params[:operation]} params"
   return content
   
   else
       request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.apps_ws[settings.name] << ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
            settings.apps_ws[settings.name].delete(ws)
         end
       end
     end
   
 
end

post '/a/:gxt/:service/:operation' do
  

   switch params[:gxt]
   
   if !request.websocket?
   settings.set  :app, settings.apps[params[:gxt]]
   settings.set  :name, params[:gxt]
   
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps", settings.app  ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   puts 
   puts params
   require_relative "apps/#{settings.app}/app"
   
   @context = self
   @this = eval "#{params[:service]}Controller.new @context, settings"
   # puts @this
   content = eval "@this.#{params[:operation]} params"
   return content
   
   else
       request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.apps_ws[settings.name] << ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
            settings.apps_ws[settings.name].delete(ws)
         end
       end
     end
   
 
end





get '/:gxt/:service/:operation' do
  
   switch params[:gxt]
  
   if !request.websocket?
   # settings.set  :app, settings.apps[params[:gxt]]
   # settings.set  :name, params[:gxt]
   
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps", settings.app  ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
   
   @context = self
   @this = eval "#{params[:service]}Controller.new @context, settings"
   # puts @this
   content = eval "@this.#{params[:operation]} params"
   return content
   
   else
       request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.apps_ws[settings.name] << ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
            settings.apps_ws[settings.name].delete(ws)
         end
       end
     end
   
 
end

post '/:gxt/:service/:operation' do
  

   switch params[:gxt]
   
   if !request.websocket?
   # settings.set  :app, settings.apps[params[:gxt]]
   # settings.set  :name, params[:gxt]
   # 
   root = File.dirname(__FILE__)
   settings.set :views, File.join(root, "apps", settings.app  ,"views") 
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   puts 
   puts params
   require_relative "apps/#{settings.app}/app"
   
   @context = self
   @this = eval "#{params[:service]}Controller.new @context, settings"
   # puts @this
   content = eval "@this.#{params[:operation]} params"
   return content
   
   else
       request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.apps_ws[settings.name] << ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
            settings.apps_ws[settings.name].delete(ws)
         end
       end
     end
   
 
end




get '/:service/:operation' do

  if !request.websocket?
      # erb 'This is a secret place that only <%=session[:identity]%> has access to!'

    

      root = File.dirname(__FILE__)
      extended = settings.extended[settings.app]
      unless extended
      settings.set :views, File.join(root, "apps", settings.app ,"views") 
      else
      settings.set :views, File.join(root, "apps", extended ,"views") 
      end

      settings.set :public_folder, File.dirname(__FILE__)+"/public"

      require_relative "apps/#{settings.app}/app"

      @context = self
      unless extended
      @this = eval "#{params[:service]}Controller.new @context, settings"
      else
      @this = eval "Food2::#{params[:service]}Controller.new @context, settings"

      end
      # puts @this
      content = eval "@this.#{params[:operation]} params"
      return content
      

    else
       request.websocket do |ws|
         ws.onopen do
           # ws.send("Hello World!")
           settings.apps_ws[settings.name]<< ws
         end
         ws.onmessage do |msg|
           puts msg
           # 10.times do |i|
           EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
           # sleep(1)
           # end
         end
         ws.onclose do
           warn("websocket closed")
            settings.apps_ws[settings.name].delete(ws)
         end
       end
     end



end


post '/:service/:operation' do

  
   root = File.dirname(__FILE__)
   extended = settings.extended[settings.app]
   unless extended
   settings.set :views, File.join(root, "apps", settings.app ,"views") 
   else
   settings.set :views, File.join(root, "apps", extended ,"views") 
   end
   
   settings.set :public_folder, File.dirname(__FILE__)+"/public"
   
   require_relative "apps/#{settings.app}/app"
   
   @context = self
   unless extended
   @this = eval "#{params[:service]}Controller.new @context,settings"
   else
   @this = eval "Food2::#{params[:service]}Controller.new @context,settings"
   
   end
   # puts @this
   content = eval "@this.#{params[:operation]} params"
   return content
end





get '/' do
   puts request.host 
   erb :home  
end



# 
# class User
#   include MongoMapper::Document
#   key :name, String
#   key :age,  Integer
# end
# 
# class Station
#   include MongoMapper::Document
#   key :name, String
#   
# end
# 
# class Sense
#   include MongoMapper::Document
#   key :stamp, Time
#   key :name, String
#   key :station_id, ObjectId
#   key :ip, String
#   key :ref, String
#   key :data,  String
# end
# 
# 
# 
# helpers do
#   def username
#     session[:identity] ? session[:identity] : 'Hello stranger'
#   end
# end
# 
# 
# 
# before '/secure' do
#   unless session[:identity]
#     session[:previous_url] = request.path
#     @error = 'Sorry, you need to be logged in to visit ' + request.path
#     halt erb(:login_form)
#   end
# end
# 
# 
# 
# get '/' do
#   # user = User.create :name=>'Soup'
#   # user = User.collection.insert([{:name=>'Soup'}])
#   # erb 'Can you handle a <a href="/secure/place">secret</a>? '+User.collection.count.to_s
#   #{$sum}
#   erb :home  
# end
# 
# 
# require_relative 'terminal_controller'
# 
# 
# 
# get '/monitor' do
#   # user = User.create :name=>'Soup'
#   # user = User.collection.insert([{:name=>'Soup'}])
#   # erb 'Can you handle a <a href="/secure/place">secret</a>? '+User.collection.count.to_s
#   
#   
#   if !request.websocket?
#      # erb 'This is a secret place that only <%=session[:identity]%> has access to!'
# 
#      erb :monitor
#      
#    else
#       request.websocket do |ws|
#         ws.onopen do
#           # ws.send("Hello World!")
#           settings.sockets << ws
#         end
#         ws.onmessage do |msg|
#           puts msg
#           # 10.times do |i|
#           EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
#           # sleep(1)
#           # end
#         end
#         ws.onclose do
#           warn("websocket closed")
#           settings.sockets.delete(ws)
#         end
#       end
#     end
#   
# end
# 
# get '/sense/list' do
#   
#   erb :sense_list
#   
# end
# 
# get '/sense/reset' do
#   
#   Sense.collection.remove()
#   
#   redirect to '/sense/list'
#   
# end
# 
# post '/sense' do 
#   
#   # user = User.create :name=>'Soup'
#   
#   # key :stamp, DateTime
#   #   key :station_id, ObjectId
#   #   key :ip, String
#   #   key :ref, String
#   #   key :data,  String
#   
#   
#   stamp = Time.now
#   stamp = params['stamp'] if params['stamp']
#   
#   ip = request.ip
#   ip = params['ip'] if params['ip']
#   
#   
#   # station_name
#   # 1. monitor ip
#   # 2. bed index
#   
#   station_name = ip
#   station_name = params['station'] if params['station'] 
#   # puts "Name = #{params.inspect }"
#   ref = "-"
#   ref = params['ref'] if params['ref']
#   
#   data = "{}"
#   data = params['data'] if params['data']
#   
#   station_id = nil
#   
#   station = nil
#   
#   unless station = settings.stations[station_name]
#     
#     station = Station.where(:name=>station_name).first
#     
#     unless station
#         
#     station = Station.create(:name=>station_name)
#       
#     end
#     
#     settings.stations[station_name] = station
#     
#   end
#   
#   
#   if station
#       station_id = station['_id']
#   end  
#   
#   data = JSON.parse(data)
#   data['ref'] = ref
#   settings.senses[station_name] = data
#   
#   
#   
#   records = Sense.collection.insert([{:station_id=>station_id, :name=>station_name,:stamp=>stamp,:ip=>ip,:ref=>ref,:data=>data}])
#   # puts station_name
#   #  puts settings.stations.inspect 
#   #  puts Station.count
#   
#    "200 OK\nSense " + Sense.collection.count.to_s + "\nId "+records[0].inspect 
#   
# end
# 
# $sum = 0
# #  off load service ================================================
# # Thread.new do # trivial example work thread
# #   while true do
# #      sleep 1
# #      EM.next_tick { settings.sockets.each{|s| s.send({:time=>Time.now, :list=>settings.stations.keys.sort,:data=>settings.senses}.to_json) } }
# #   end
# # end
# # ================================================
# 
# 
# get '/login/form' do
#   erb :login_form
# end
# 
# post '/login/attempt' do
#   session[:identity] = params['username']
#   where_user_came_from = session[:previous_url] || '/'
#   redirect to where_user_came_from
# end
# 
# get '/logout' do
#   session.delete(:identity)
#   erb "<div class='alert alert-message'>Logged out</div>"
# end
# 
# get '/secure/place' do
#   if !request.websocket?
#     # erb 'This is a secret place that only <%=session[:identity]%> has access to!'
#     
#     erb :ptz  
#   else
#     request.websocket do |ws|
#       ws.onopen do
#         ws.send("Hello World!")
#         settings.sockets << ws
#       end
#       ws.onmessage do |msg|
#         puts msg
#         EM.next_tick { settings.sockets.each{|s| s.send(msg) } }
#       end
#       ws.onclose do
#         warn("websocket closed")
#         settings.sockets.delete(ws)
#       end
#     end
#   end
# end
