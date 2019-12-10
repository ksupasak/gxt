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

mode = 'application'
mode = ARGV[0] if ARGV[0]

puts "Mode : #{mode}"

require_relative 'config/init'


# Mongo config

require 'mongo'
require 'mongo_mapper'

set :mongo_prefix, @conf_mongo_prefix

# Redis config
require 'em-hiredis'
require 'redis'
require "hiredis"


redis = Redis.new(url: "redis://#{@conf_redis_host}:#{@conf_redis_port}/#{@conf_redis_db}",:driver => :hiredis)

# redis = EM::Hiredis.connect "redis://#{@conf_redis_host}:#{@conf_redis_port}/#{@conf_redis_db}"


set :redis, redis
set :redis_host, @conf_redis_host
set :redis_port, @conf_redis_port
set :redis_db, @conf_redis_db



# Server configuration

set :server, @conf_server

if mode == 'application'
  set :bind, @conf_server_bind
  set :port, @conf_server_port
else
  set :bind, @conf_service_bind
  set :port, @conf_service_port
end


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

set :mode, mode

require_relative 'apps/gxt/helper'

require_relative 'config/modules'

require_relative 'config/deploy'




register Sinatra::Partial
set :partial_template_engine, :erb



# default ap
set :name, DEFAULT_APP
set :app, settings.apps[settings.name]
set :root, File.join(File.dirname(__FILE__))
set :public_folder, File.dirname(__FILE__)+"/public"
set :layout, 'layout'



configure do
  enable :sessions
end




# =========================================
require_relative 'lib'


