require 'redis'
require 'json'
require "hiredis"

redis = Redis.new(url: "redis://127.0.0.1:6379/15",:driver => :hiredis)


# redis.set 'name', [1,2,3].to_json
#
# redis.set 'value', [1,2,3]
#
# # redis.set 'hash', {:name=>'soup', :age=>36}
# redis.hmset 'user:99', :name, 'Antonio', :data, 12323
#
# puts redis.get('name')
# puts redis.get('value')[2]
# puts redis.hgetall('user:99')['data']


begin
  redis.psubscribe('miot/*' ) do |on|
    on.psubscribe do |channel, subscriptions|
      puts "Subscribed to #{channel} (#{subscriptions} subscriptions)"
    end

    on.pmessage do |channel, tag, message|
      puts
      puts "#{channel}: #{tag}: \n#{message.size} #{Time.now.to_f}"
      # puts message
      redis.punsubscribe if message == "exit"
    end

    on.punsubscribe do |channel, subscriptions|
      puts "Unsubscribed from #{channel} (#{subscriptions} subscriptions)"
    end
  end
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end