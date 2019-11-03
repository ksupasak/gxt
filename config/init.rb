require_relative 'server_config'
require_relative 'mongo_config'
require_relative 'redis_config'
require_relative 'config'

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
  


# @default_media_server = 'http://localhost:8080'