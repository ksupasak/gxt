require_relative 'config'

if ENV['DEFAULT_APP']
  DEFAULT_APP =  ENV['DEFAULT_APP'] 
else
  DEFAULT_APP = DEFAULT_APP_CONIFG
end


if ENV['MONGO_HOST']
  MONGO_HOST = ENV['MONGO_HOST'] 
else
  MONGO_HOST = MONGO_HOST_CONFIG
end
  


@default_media_server = 'http://localhost:8080'