require 'redis'
require 'json'
require "hiredis"




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

threads = []

channel = 1
clients = 20
concurrent_send = 10

n = 1000
m = 50000

start = Time.now

clients.times do |i|

threads << Thread.new { 
  
  redis = Redis.new(url: "redis://127.0.0.1:6379/15",:driver => :hiredis)
  sum = 0
  count = 0 
  
begin
  redis.psubscribe('test/ch/*' ) do |on|
    on.psubscribe do |channel, subscriptions|
      # puts "Subscribed to #{channel} (#{subscriptions} subscriptions)"
    end

    on.pmessage do |channel, tag, message|
      # puts "#{channel}: #{tag}: #{message} #{Time.now.to_f}"
        
      if message == "exit"     
        redis.punsubscribe
        puts "AVG #{sum/count}"
      else
      
        t = message.split(" ")[0].to_f
        l = Time.now.to_f - t
        # puts "#{t} #{l}"
        sum += l
        count +=1
      end
    
      
      
    end

    on.punsubscribe do |channel, subscriptions|
      # puts "Unsubscribed from #{channel} (#{subscriptions} subscriptions)"
    end
  end
rescue Redis::BaseConnectionError => error
  puts "#{error}, retrying in 1s"
  sleep 1
  retry
end

}

end


concurrent_send.times do |i|

redis = Redis.new(url: "redis://127.0.0.1:6379/15",:driver => :hiredis)

threads << Thread.new { 
  n.times do |t| 
    t = Time.now.to_f.to_s
    # puts "pub #{t}"
    redis.publish("test/ch/#{i}", "#{t} #{'X'*m}")
  end
    redis.publish("test/ch/#{i}", "exit" )
  
}

end

puts 'start ' + threads.size.to_s

threads.each { |thr| thr.join }

puts "Sent #{concurrent_send*n*m/1000000}M" 
puts "Receive #{clients*n*m/1000000*concurrent_send}M" 
