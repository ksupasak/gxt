require 'socket'


def callx l
  
  puts "ua "+l.size.to_s
   #puts '========================================'

   n = 30
   r = l.size/n+1

   print "-\t"

   n.times do |i|

     print "#{i}\t"

   end
   puts
   r.times do |j|

     print "#{j*n}\t"

     n.times do |i|

       # print ".#{l[j*n+i].chr}\t"

       print "#{l[j*n+i]}\t"


     end

     puts


   end
  
end


server = TCPServer.new 5001
loop do
  Thread.start(server.accept) do |client|
    puts 'connect '
    while content = client.read(128)
    

      # callx content.each_byte.to_a.collect{|i| i.to_i}
      
      puts content
      
    end
    
    client.close
  end
end