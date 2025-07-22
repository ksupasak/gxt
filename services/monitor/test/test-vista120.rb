data = File.open('msg.txt').read
data = data.split("\t")

cols = 10
row = 0 
print "0\t"

data.each_with_index do |i,index|
  
  
  
  
  print "#{i}\t"
 if index%cols == cols-1 and index!=0
   puts 
   row = index+1
   print "#{row}\t"
 end
  
  
  
end
puts data[40..41+10]
# l = data
#   puts data[-6]
#   sys = l[1130..1139].join(".")
#   dia = l[1140..1149].join(".")
#   bp = "#{sys}/#{dia}"
#   
#   data = {}
#   
#   data[:hr] = l[646]
#   
#   data[:rr] = l[648]
#   data[:so2] = l[-6]
#   data[:pr] = l[646]
#   data[:bp] = bp
#   stamp = Time.now
#    
#   
# puts "#{stamp}\t#{data.inspect}"