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

require 'rack/ssl-enforcer'
# use Rack::SslEnforcer

# set :session_secret, 'asdfa2342923422f1adc05c837fa234230e3594b93824b00e930ab0fb94b'

#Enable sinatra sessions
# use Rack::Session::Cookie, :key => '_rack_session',
#                            :path => '/',
#                            :expire_after => 2592000, # In seconds
#                            :secret => settings.session_secret

  # set :ssl, true

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

redis_url = "redis://#{":"+REDIS_PASS+"@" if REDIS_PASS}#{REDIS_HOST}:#{REDIS_PORT}/#{REDIS_DB}"
redis = Redis.new(url: redis_url,:driver => :hiredis)
puts "REDIS CONFIG : #{redis_url}" 
# redis = EM::Hiredis.connect "redis://#{@conf_redis_host}:#{@conf_redis_port}/#{@conf_redis_db}"


set :redis, redis
set :redis_host, REDIS_HOST
set :redis_port, REDIS_PORT
set :redis_db, REDIS_DB
set :redis_password, REDIS_PASS 



# Server configuration

set :server, @conf_server

if mode == 'application'
  set :bind, @conf_server_bind
  set :port, @conf_server_port
elsif mode =='service'
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


