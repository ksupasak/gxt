require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/partial'
require 'sinatra-websocket'
require 'sinatra/form_helpers'
require 'json'
require 'barby'
require 'barby/barcode/code_128'
require 'barby/barcode/ean_13'
require 'barby/barcode/code_39'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'
require 'crc'
require 'active_support/all'

require 'mongo'
require 'mongoid'




require_relative 'config/init'


# Mongo config




set :mongo_prefix, @conf_mongo_prefix

# Redis config

require 'redis'
require "hiredis"

redis_url = "redis://#{":"+REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
redis = Redis.new(url: redis_url, :driver => :hiredis)

puts "REDIS CONFIG : #{redis_url}" 

set :redis, redis


# Server configuration

set :server, @conf_server
set :bind, @conf_service_bind
set :port, @conf_service_port






# Application configuration

set :sockets, []
set :stations, {}
set :senses, {}
set :live, {}
set :apps, {}
set :apps_ws, {}
set :apps_rv, {}
set :apps_ws_rv, {}
set :extended, {}

set :mode, :service

require_relative 'apps/gxt/helper'
require_relative 'config/modules'
require_relative 'config/deploy'




register Sinatra::Partial
set :partial_template_engine, :erb



# default ap
set :name, DEFAULT_APP
set :app, settings.apps[settings.name]




def switch name
  
  # if name.index('.')==nil  
  settings.set :name, name 
  settings.set :app, settings.apps[name]
  settings.set :context, eval("#{settings.apps[name].gsub('-','_').camelize}")
  # MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  # end
  Mongoid.override_database("#{settings.mongo_prefix}-#{settings.name}")
  
  
  
  
end

 
before do 
   
  
  solution_name = DEFAULT_APP
  @prefix_solution = false
  # only   [solution].domain.com
  t = request.host.split(".")
  paths = request.path.split("/")
  
  puts "-  Host : #{t.inspect } Path : #{paths.inspect} #{ @default_app.inspect }" 
  
  if  t.size>2  and t[-1].to_i ==0  # detect sub domain 
    @prefix_solution = true
    solution_name = t[0]  # solution_name
    
  elsif t.size==2 and app = settings.apps[paths[1]]
    
    solution_name =  paths[1] if paths[1]
    
  elsif t.size==4 and t[-1].to_i!=0 or request.host=='localhost' # when using ip
    
   solution_name = paths[1] if paths[1]
    
  end
  
  
  # configure solution and user
  
  
  if paths[1]!='__sinatra__' and paths[1]!='favicon.ico'
  
  
  puts "-  Solution Name : #{solution_name}"
  
  # paths = request.path.split("/")
  #   puts paths.inspect 
  #   if paths.size==4 and paths[0]=="" and paths[1].index(".") ==nil 
  #     solution_name = paths[1]
  #   end
  #   \
  settings.set :context, nil
  # if solution_name!='promptpay' and solution_name!='barcode'
  switch solution_name
  # end
  
  # MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
  
  settings.set :current_user, nil
  settings.set :current_role, nil
  
    
    context = settings.context
    
    
     if settings.context and session[:identity] 
       
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
  # MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}-#{settings.name}"}}, 'production')
  
end


set :root, File.join(File.dirname(__FILE__))
set :public_folder, File.dirname(__FILE__)+"/public"
set :layout, 'layout'


# =========================================
require_relative 'lib'


