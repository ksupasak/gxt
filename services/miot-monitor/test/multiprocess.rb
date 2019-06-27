range1 = 0...5_000_000
range2 = 5_000_000...10_000_000
number = 8_888_888
puts "Parent #{Process.pid}"

10.times do |i|

fork { 
  
  1000000.times do |j|
    
    puts "Child#{i} #{Process.pid}: #{j}" if j%1000==0 
  
  
  end
  
  
}



end
Process.wait


