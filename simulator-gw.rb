
require 'net/http'
require 'json'


name = 'bed2' 
name = ARGV[0] if ARGV[0]

host = 'localhost'
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
  
  uri = URI("http://#{host}:#{port}/a/monitor/sense")
  stamp = Time.now.to_json
  
  data = {}
  
  
  data[:bp] = bp
  data[:pr] = 80 + rand(10)
  data[:rr] = 18 + rand(4)
  
  
  res = Net::HTTP.post_form(uri, 'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>data.to_json)
  count += 1

  if count%ls==0
    
    bp = "#{70+rand(20)}/#{100+rand(20)}"
    ls = 10+rand(5)
    bp_stamp = Time.now
    
    puts "Data sent #{count} times + BP : #{bp}"
  
  end
  
  
  rescue Exception=>e
    puts 'Connect Error'+e.inspect 
  end
  
  sleep 1
end
