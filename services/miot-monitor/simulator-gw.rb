
require 'net/http'
require 'json'


name = 'bed2' 
name = ARGV[0] if ARGV[0]

host = 'localhost'
host = ARGV[2] if ARGV[2]
port = 1792

ref = '-'
ref = ARGV[1] if ARGV[1]

puts "Start"
count = 0
ls = 10

bp = '90/120'
bp_stamp = Time.now
while true do 
  
  begin
  
  uri = URI("http://#{host}:#{port}/miot/Sense/sense")
  now = Time.now
  stamp = now.to_json
  
  
  data = {}
  
  
  data[:bp] = bp
  data[:pr] = 60 + rand(60)
  data[:hr] = data[:pr]
  data[:rr] = 18 + rand(4)
  data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
  
  res = Net::HTTP.post_form(uri, 'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)
  count += 1
  
  puts res

  if count%ls==0
    bp_stamp = Time.now
    
    bp = "#{70+rand(20)}/#{100+rand(20)}"
    ls = 20+rand(10)
    puts "Data sent #{count} times + BP : #{bp}"
  
  end
  
  
  rescue Exception=>e
    puts 'Connect Error'+e.inspect 
  end
  
  sleep 1
end
