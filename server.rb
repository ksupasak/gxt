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

require "hiredis-client"

# Mongo config

require 'mongo'
# require 'mongo_mapper'
require 'mongoid'
require 'sprockets'
require "yui/compressor"

require 'sinatra/cross_origin'
require 'sinatra/asset_pipeline'
# require 'sinatra/sprockets-helpers'
# require 'sprockets/environment'
# class App < Sinatra::Base

  # register Sinatra::Sprockets::Helpers



  
  register Sinatra::AssetPipeline


  # Include these files when precompiling assets
   set :assets_precompile, %w(app.js app.css *.png *.jpg *.svg *.eot *.ttf *.woff *.woff2)

   # The path to your assets
   set :assets_paths, %w(public/assets)

   # Use another host for serving assets
   # set :assets_host, '<id>.cloudfront.net'

   # Which prefix to serve the assets under
   set :assets_prefix, ['/assets']

   # Serve assets using this protocol (http, :https, :relative)
   set :assets_protocol, :http

   # CSS minification
   set :assets_css_compressor, :sass

   # JavaScript minification
   set :assets_js_compressor, :uglifier

   # set :sprockets, Sprockets::Environment.new('app')

   set :digest_assets, true
   
   configure do
     
     enable :cross_origin
  
    
   end
  
  
   class Assets < Sinatra::Base
     configure do
       set :assets, (Sprockets::Environment.new { |env|
         env.append_path(settings.root + "/public/assets/images")
         env.append_path(settings.root + "/public/assets/javascripts")
         env.append_path(settings.root + "/public/assets/stylesheets")

         # compress everything in production
         if ENV["RACK_ENV"] == "production"
           env.js_compressor  = YUI::JavaScriptCompressor.new
           env.css_compressor = YUI::CssCompressor.new
         end
       })
     end

     get "/assets/app.js" do
       content_type("application/javascript")
       settings.assets["app.js"]
     end

     get "/assets/app.css" do
       content_type("text/css")
       settings.assets["app.css"]
     end

     %w{jpg png}.each do |format|
       get "/assets/:image.#{format}" do |image|
         content_type("image/#{format}")
         settings.assets["#{image}.#{format}"]
       end
     end
   end
  
  
set :allow_origin, :any
# use Rack::SslEnforcer

# set :session_secret, SecureRandom.hex(64)

set :session_secret, "4fdd9f5514e196ed36cf07e0f8e168929320516c881946687382a1fc34b76cca"
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




set :mongo_prefix, @conf_mongo_prefix


# MongoMapper.setup({'production' => {'uri' => "mongodb://#{MONGO_HOST}/#{settings.mongo_prefix}"}}, 'production')
Mongoid.load!("config/mongoid.yml", :production)



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

# end

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
  set :session_secret, "4fdd9f5514e196ed36cf07e0f8e168929320516c881946687382a1fc34b76cca"
end


use Assets

# =========================================
require_relative 'lib'


# end