

file = "1651723180.log"

map = {}
map2 = {}

lines = File.open(file).read.split("\n")[0..50]

for i in lines
  
  # puts i
  
  
  s = eval(i).bytes
  
  
  
  # puts s.size
  
  s.size.times do |i| 
  
    map[i] = {} unless map[i]
    map2[i] = [] unless map2[i] 
    v = s[i].ord
    map[i][v] = true
    map2[i]<<v
  
  end


  
end

puts map.inspect

# s.size.times do |i|
#
#   puts "#{i}\t#{map[i].keys.join("\t")}"
#
#
# end


s.size.times do |i| 

  # puts "#{i}\t#{map[i].size}\t#{map2[i].join("\t")}"
  # puts "#{i}\t#{map2[i].size}\t#{}"


end

# %w{7 11 15 10 12 13 14}.each do|y|
#
# y = y.to_i
#
# 15.times do |x|
#
#   puts "#{x}\t#{map2[4+x*16+y].join("\t")}"
#
# end
#
# end

def convert_to_signed_binary(binary)
  # binary_int = binary.to_i(2)
  binary_int = binary
  if binary_int >= 2**15
    return binary_int - 2**16
  else
    return binary_int
  end
end


lines.size.times do |t|
  

  15.times do |x|
  
    print "#{t*15+x}\t"
  
  %w{7 11 15 14}.each do|y|
    if y == '11' or y == '15'
      v = map2[4+x*16+(y.to_i-1)][t]*256 + map2[4+x*16+y.to_i][t]
      
      print "#{convert_to_signed_binary(v)}\t"
  
    else
      
      print "#{map2[4+x*16+y.to_i][t]}\t"
    end 
    
  end
  
  print "\n"
  
  end
  
  
  
  
end













puts
puts lines.size