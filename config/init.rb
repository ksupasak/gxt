require_relative 'server_config'
require_relative 'mongo_config'
require_relative 'redis_config'
require_relative 'config'
require_relative 'mongoid'

if ENV['DEFAULT_APP']
  DEFAULT_APP =  ENV['DEFAULT_APP'] 
else
  DEFAULT_APP = @conf_default_app
end


if ENV['MONGO_HOST']
  MONGO_HOST = ENV['MONGO_HOST'] 
else
  MONGO_HOST = @conf_mongo_host
end
  


if ENV['REDIS_HOST']
  REDIS_HOST = ENV['REDIS_HOST'] 
else
  REDIS_HOST = @conf_redis_host
end

if ENV['REDIS_PORT']
  REDIS_PORT = ENV['REDIS_PORT'] 
else
  REDIS_PORT = @conf_redis_port
end

if ENV['REDIS_DB']
  REDIS_DB = ENV['REDIS_DB'] 
else
  REDIS_DB = @conf_redis_db
end


if ENV['REDIS_PASS']
  REDIS_PASS = ENV['REDIS_PASS'] 
else
  REDIS_PASS = @conf_redis_password
end

require 'i18n'

# Load localization files
I18n.load_path << Dir["./config/locales/*.yml"]
I18n.default_locale = :en

  
# @default_media_server = 'http://localhost:8080'