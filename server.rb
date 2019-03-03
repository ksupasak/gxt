require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/partial'
require 'sinatra-websocket'
require 'sinatra/form_helpers'

require_relative 'config/init'

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

# register Sinatra::Reloader

set :server, 'thin'
set :bind, '0.0.0.0'

set :port, 1792
set :sockets, []

set :stations, {}
set :senses, {}
set :live, {}

set :apps, {}
set :apps_ws, {}
set :apps_rv, {}
set :apps_ws_rv, {}

set :extended, {}

require_relative 'config/init'
require_relative 'apps/gxt/helper'

# require_relative 'apps/gxt-food-order/app'
# require_relative 'apps/gxt-food-extended/app'
# require_relative 'apps/gxt-cash-deposit/app'
# require_relative 'apps/gxt-gold-saving/app'
# require_relative 'apps/esm-media-stream/app'
# require_relative 'apps/esm-monitor/app'
require_relative 'apps/gxt-console/app'
# require_relative 'apps/gxt-ptz/app'
require_relative 'apps/esm-miot-monitor/app'

require_relative 'config/deploy'



register Sinatra::Partial


set :partial_template_engine, :erb

set :mongo_prefix, Proc.new {'gxt'}

# 
# name = solution_name
# app = solution_platform


# default ap
set :name, DEFAULT_APP
set :app, settings.apps[settings.name]


def switch name
  
  if name.index('.')==nil  
  settings.set :name, name 
  settings.set :app, settings.apps[name]
  settings.set :context, eval("#{settings.apps[name].gsub('-','_').camelize}")
  MongoMapper.setup({'production' => {'uri' => "mongodb://localhost/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  end
  
end

# m = GxtFoodOrder

# include GxtFoodOrder
# include GxtGoldSaving

# context = GxtGoldSaving

 
before do 
   
   # settings.set :app, 'gxt-food-order'
  
  solution_name = DEFAULT_APP
  
  # only   [solution].domain.com
  t = request.host.split(".")
  paths = request.path.split("/")
  
  puts "Host : #{t.inspect } Path : #{paths.inspect} #{ @default_app.inspect }" 
  
  if  t.size>2  and t[-1].to_i ==0  # detect sub domain 
    solution_name = t[0]  # solution_name
  elsif t.size==4 and t[-1].to_i!=0 or request.host=='localhost' # when using ip
    
   solution_name = paths[1] if paths[1]
   
    
  end
  
  if paths[1]!='__sinatra__' and paths[1]!='favicon.ico'
  
  
  puts "Solution Name : #{solution_name}"
  
  # paths = request.path.split("/")
  #   puts paths.inspect 
  #   if paths.size==4 and paths[0]=="" and paths[1].index(".") ==nil 
  #     solution_name = paths[1]
  #   end
  #   
  
  settings.set :context, nil
  
  
  switch solution_name
    
  # puts "Set link = #{solution_name}"
  # puts "Set name = #{settings.name}"
  # puts "Set app = #{settings.app}"
  
  # puts "Set context = #{settings.context}" 

  
  MongoMapper.setup({'production' => {'uri' => "mongodb://localhost/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
  
  
  
   # params[:request]  = request
    settings.set :current_user, nil
    settings.set :current_role, nil
    
    context = settings.context
    
    
     if settings.context and  session[:identity] 
       
       u  = context::User.find session[:identity] 
       
       if u
         @current_user = u.login
         role = context::Role.find u.role
         @current_role = role.name if role
         settings.set :current_user, @current_user
         settings.set :current_role, @current_role
         
       end
       
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

# =========================================

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




   # self.class.send :include, GxtFoodOrder
   
   # routing pattern :     /{solution}/Controller/Operation
   
   
def process_request
  
  puts "Access : #{1}"
  
   puts "Process Context : #{ settings.context.inspect }"
   self.class.send :include, settings.context
   
   
  
    root = File.dirname(__FILE__)
    settings.set :views, File.join(root, "apps", settings.app  ,"views") 
    settings.set :public_folder, File.dirname(__FILE__)+"/public"

    # load context solution
    require_relative "apps/#{settings.app}/app"

    @context = self

    # Service's class name
    params[:service] = "#{settings.context}::#{params[:service]}"

    puts  params[:service]

   @this = eval "#{params[:service]}Controller.new @context, settings"
   # eval "@this.init"
   @this.setRequest request
  
   # normal web http request
   if !request.websocket?
   
   
     puts 'xxxx '+ params[:operation]
   
   # get content of service
   content = eval "@this.#{params[:operation]} params"
   
   
   return content
   
   else
     
   # web socket request
    
   eval "@this.websocket request"   
      
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
  
 process_request
   
  
end

post '/:gxt/:service/:operation' do
  
  process_request
     # 
     # self.class.send :include, settings.context
     # 
     # switch params[:gxt]
     # 
     # if !request.websocket?
     # # settings.set  :app, settings.apps[params[:gxt]]
     # # settings.set  :name, params[:gxt]
     # # 
     # root = File.dirname(__FILE__)
     # settings.set :views, File.join(root, "apps", settings.app  ,"views") 
     # settings.set :public_folder, File.dirname(__FILE__)+"/public"
     # # puts 
     # # puts params
     # # puts
     # require_relative "apps/#{settings.app}/app"
     # 
     # @context = self
     # # @this = eval "#{params[:service]}Controller.new @context, settings"
     # # params[:service] = "GXTCMS::Setting"
     # params[:service] = "#{settings.context}::#{params[:service]}"
     # 
     # @this = eval "#{params[:service]}Controller.new @context, settings"
     # 
     # @this.setRequest request
     # # puts @this
     # content = eval "@this.#{params[:operation]} params"
     # return content
     # 
     # else
     #     request.websocket do |ws|
     #       ws.onopen do
     #         # ws.send("Hello World!")
     #         settings.apps_ws[settings.name] << ws
     #       end
     #       ws.onmessage do |msg|
     #         puts msg
     #         # 10.times do |i|
     #         EM.next_tick {  settings.apps_ws[settings.name].each{|s| s.send(msg) } }
     #         # sleep(1)
     #         # end
     #       end
     #       ws.onclose do
     #         warn("websocket closed")
     #          settings.apps_ws[settings.name].delete(ws)
     #       end
     #     end
     #   end
     # 
 
end




get '/:service/:operation' do

  
  process_request


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

get '/:gxt' do
   redirect to "/#{params[:gxt]}/Home/index"
end



get '/' do
   redirect to "/#{settings.name}/Home/index"
   
end



