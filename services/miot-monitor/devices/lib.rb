require 'json'
require 'time'
require 'net/http'
def send_to_gateway data
          
          if @config[:gw] == true
          begin
          host = @config[:host]
          port = @config[:port]

            
          uri = GW_URI
          # URI("http://#{host}:#{port}/monitor/Sense/sense")
  
           
           sense = {}
           
           sense[:hr] = data[:hr]
           sense[:rr] = data[:rr]
           sense[:so2] = data[:so2]
           sense[:pr] = data[:pr]
           sense[:bp] = data[:bp]
           sense[:bp_stamp] = data[:bp_stamp]
           
           
      
           ref = data[:ref]
           name = data[:name]  # bed name
           stamp = Time.now.to_json
           
           stamp = Time.parse("#{data[:hour]}:#{data[:min]}", Time.now).to_json if data[:hour]
           puts "#{stamp}\t#{name}\t#{sense.inspect}"
           res = Net::HTTP.post_form(uri,'ip'=>data[:ip], 'station'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>sense.to_json)
          
          rescue Exception=>e 
              puts e.inspect 
          end
          
         end
           
  
end


def get_vital_sign tip, station_name="-"
  hn = "-"
  puts @config.inspect 
  t = Thread.new do

  u2 = UDPSocket.new

  puts "start 1"

  last = nil

  a = true
  begin

  while true 

    # CIC
    # B288A
  if  last ==nil or (Time.now - last)>29  
    puts '1'
  msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\xCA\x00)\x00\x06\x00\x00\x00\x00\x00\x00ICU|B288A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  u2.send msg_c, 0, tip,2000  
      puts '1.2'
  data = nil
  status = Timeout::timeout(2) {
    data = u2.recvfrom(1000)
  }
  msg = data[0]
  last_name,first_name = msg[92..107].strip.split(",")
  hn = msg[108..118].strip
    
    puts '2'
    
  last = Time.now 
  msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\x00\x00\"\x00\x00\x00\x00\x00\x00\x00\x00ICU|B288A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF"
  puts 'send'
  # send token
  u2.send msg_c, 0, tip,2000

  end  
  
  puts '3'
  data = nil
  status = Timeout::timeout(10) {
    data = u2.recvfrom(1000)
  }
  msg = data[0]


  msg.size.times do |i|
    puts "#{i}\t#{msg[i].inspect}\t#{msg[i]}\t#{msg[i].ord}"
  end

puts '4'
  ########### Vital Sign
  so2 = msg[207].ord
  pr = msg[209].ord
  sys = msg[141].ord
  dia = msg[143].ord
  hour = msg[150].ord
  min = msg[149].ord
  
  
  sense = {}
  
  sense[:ip]  = tip
  sense[:so2] = so2
  sense[:pr] = pr
  sense[:hr] = pr
  sense[:ref] = hn
  sense[:name] = station_name
  sense[:bp] = "#{sys}/#{dia}"
  sense[:hour] = hour
  sense[:min] = min
  sec = Time.now.sec
  sense[:bp_stamp]  = format("%02d%02d%02d",hour,min,0)
  #  
  # 
  # 
  # 
  send_to_gateway sense
  # 
  

  # puts "#{Time.now - last} #{msg.size}. SO2 : #{so2}, PR : #{pr}, BP : #{sys}/#{dia}, Time : #{hour}:#{min}"


  end


  puts (Time.now - last)
  
  
  
 rescue Timeout::Error
  puts "Timed out!"

  end
  
   puts "Finished"
 end
  return t
end

def get_wave_form tip
  
  t = Thread.new do

  u2 = UDPSocket.new

  puts "start 2"

  last = nil

  a = true
  
  begin 
    
  while true 

  
  if  last ==nil or (Time.now - last)>29  
  last = Time.now 
  msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\x00\x00!\x00\x00\x00\x00\x00\x00\x00\x00ICU|CIC\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\b\x00"
  puts 'send'
  # send token
  u2.send msg_c, 0, tip,2000

  end  
  
  
  data = nil
  status = Timeout::timeout(10) {
    data = u2.recvfrom(1000)
  }
  
  msg = data[0]

  # msg.size.times do |i|
  #   puts "#{i}\t#{msg[i].inspect}\t#{msg[i]}\t#{msg[i].ord}"
  # end

  ########### Vital Sign
  l = []
  14.times do |i|

    a = msg[46+44*i].ord
    b = msg[47+44*i].ord
    v = a*256+b

    l << v  
  end

  # out = File.open('out.txt','w') unless out
  # out.puts l

  puts "#{Time.now - last} #{msg.size}. #{l.join("\t")}"


  end


  puts (Time.now - last)

  
  rescue Timeout::Error
    puts "Timed out!"
  end
  
  
  end

  return t
  
end