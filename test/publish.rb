require 'redis'
require 'json'
require "hiredis"

redis = Redis.new(url: "redis://127.0.0.1:6379/15")



begin
  
  
  redis.publish('chula/sas/station-1', 'chula/sas/station-1')
  
   
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end