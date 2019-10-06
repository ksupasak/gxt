require 'redis'
require 'json'
require "hiredis"

redis = Redis.new(url: "redis://127.0.0.1:6379/15",:driver => :hiredis)


redis.set 'name', [1,2,3].to_json


puts redis.get('name')


begin
  redis.psubscribe('chula.sas.*' ) do |on|
    on.psubscribe do |channel, subscriptions|
      puts "Subscribed to ##{channel} (#{subscriptions} subscriptions)"
    end

    on.pmessage do |channel, tag, message|
      puts "##{channel}: #{tag}: #{message}"
      redis.punsubscribe if message == "exit"
    end

    on.punsubscribe do |channel, subscriptions|
      puts "Unsubscribed from ##{channel} (#{subscriptions} subscriptions)"
    end
  end
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end