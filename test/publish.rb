require 'redis'
require 'json'
require "hiredis"

redis = Redis.new(url: "redis://127.0.0.1:6379/15",:driver => :hiredis)



begin
  
  puts "#{Time.now.to_f}"
  redis.publish('miot/cu/z/er', 'Zone Data ER')
  sleep(1)
  
  puts "#{Time.now.to_f}"
  redis.publish('miot/cu/z/aoc', 'Zone Data AOC')
  sleep(1)
  
  puts "#{Time.now.to_f}"
  redis.publish('miot/cu/s/Bed01', 'Station Data Bed01')
  
   
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end