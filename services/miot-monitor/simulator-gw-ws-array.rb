
puts ARGV.inspect
n = 1
n = ARGV[0].to_i if ARGV[0]

host = 'localhost'
host = ARGV[1] if ARGV[1]

solutio = 'miot'
solution = ARGV[2]

ount = 0
arr = []

n.times do |i|
   arr[i] = Thread.new {
     puts i
   
     `ruby simulator-gw-ws.rb Bed#{i+1}`
   }
end


puts 'ok'
arr.each {|t| t.join; }
