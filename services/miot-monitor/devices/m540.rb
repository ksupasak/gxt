require "socket"
require "ipaddr"

# MULTICAST_ADDR = "224.127.1.255"  # to discovery all monitor
MULTICAST_ADDR = "224.0.1.173"  # to receive data
MULTICAST_ADDR = "224.0.1.4"  # to receive data

BIND_ADDR = "0.0.0.0"
BIND_ADDR_2 = "203.156.124.171"
BIND_ADDR_2 = "191.1.1.5"

# M540 data on this port
PORT = 2050


socket = UDPSocket.new
membership = IPAddr.new(MULTICAST_ADDR).hton + IPAddr.new(BIND_ADDR_2).hton



socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)
# socket.setsockopt(:SOL_SOCKET, :SO_REUSEPORT, 1)

socket.bind(BIND_ADDR, PORT)

def tabular data, cols = 20
  
  data.each_with_index do |i,index|
    
    print "#{index}.\t" if index % cols == 0
    
    print "#{i}\t"
    
    puts if index % cols == cols -1
    
  end
  
end

def variant_detection tmp, data
  
  
  # tmp = stmp[k]
  
  result = []
  
  
  
  data.each_with_index do |i,index|
     
     count = 0 
     list = []
     
     for j in tmp
        if j[index]!=data[index]
          count +=1
          
        end
        list << j[index]
     end
     
     if count > 1
       list << data[index]
       u = list.uniq
        puts "variant\t#{index}\t#{u.size}\t#{u.join(",")}#{}\t"
     end

   end
  
   tmp << data
  
   # tmp.delete_at(0) if tmp.size==20
   # puts
end


puts 'start'
tmp = []
stmp = {}
sk = {}

n = 1000

loop do
  message, info = socket.recvfrom(1024)
  # puts "#{info.inspect}\t msg = #{message.size}"
  l = message.each_byte.to_a.collect{|i| i.to_i.to_s}  
  
  
  if n>0
    # puts
    # tabular l
    
    # puts "#{message.size}\t#{l[33]}"
    
    # 33=14, 35=242
    # 33=14, 35!=242, 19=174
    # 33=14, 35!=242, 19!=174
    
    # if l[33].to_i == 14 and l[35].to_i != 242 and l[19].to_i != 174
   #     tabular l
   #     variant_detection tmp, l
   #   end

    
    
    # if l[33].to_i == 10 # and l[35].to_i != 242 and l[19].to_i != 174
   #     tabular l
   #     puts
   #     variant_detection tmp, l
   #   end
    
   # if l[33].to_i == 15 # and l[35].to_i != 242 and l[19].to_i != 174
  #     tabular l
  #     puts
  #     variant_detection tmp, l
  #   end
    
   # puts
   if  l[33].to_i ==  12 #and l[49].to_i != 110# and l[19].to_i != 174
     
     
     40.times do |i|
       print "#{i}\t"
       6.times do |j|
         
         v = 58+(j*94)+i*2
         v -= 6 if j>1
         
         a = l[v].to_i
         b = l[v+1].to_ik
         
         # puts a
         x = a*256+b
         x = -(256-b) if a==255
         
         print "#{x}\t"
         
         
       end
       puts
       
       
     end
     # puts
     
     
     # k = '-'
     # # k = "#{l[19]}-#{l[48]}-#{l[49]}-#{l[58]}"
     # k = "#{l[58]}"
     # puts k
     #  # tabular l
     #  stmp[k] = [] unless stmp[k]
     #  t = stmp[k]
     #  # puts
     #  sk[k] = true
     #  # puts sk.keys.sort.collect{|i| "#{i}(#{stmp[i].size})"}.join(", ")
     #  # puts "\t#{l[58]} #{message.size}"
     #  tabular l # if l[58]!='255'
     #
     #  # variant_detection stmp, l, k
      
    end
    
    
    # puts
    # puts
    n -=1 
  else
    exit
  end 
  
  
   
   
   
  # if message.size==602    # data with So2 package
  #
  #
  #
  #
  # variant_detection tmp, l
  #
  # puts
  #
  # puts "PR #{l[273]}"
  # puts "SO2 #{l[237]}"
  #
  #
  #
  #
  # end
 
 
end