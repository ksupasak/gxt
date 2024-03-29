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
  puts 'xxxx' + station_name
  ws = MIOT::connect
    
    
  t = Thread.new do

  u2 = UDPSocket.new

  # puts "start 1"

  last = nil

  a = true
  
  
  mapx = {}
  
  
  begin

  while true 

    # CIC
    # B288A
  if  last ==nil or (Time.now - last)>29  
    # puts '1'
  msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\xCA\x00)\x00\x06\x00\x00\x00\x00\x00\x00ICU|B288A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  
  # msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\xCA\x00)\x00\x06\x00\x00\x00\x00\x00\x00EDOT|BED3\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
  # \x01\x04\x00\x00\xC0\xA8\x01\nb\n@{OT|BED3\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\b\x00\x01\a\xD0\x00\x1F\x05\x00\x00\x11\x02\"\x00\x13\a\xD0\x00\f\a\xD0\x00\r\a\xD0\x00\x1C\a\xD0\x00\x0E\a\xD0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00
 
  # puts "B450 "
  # puts msg_c.bytes.inspect

  tx = msg_c.bytes
  ips = HOST_IP.split(".").collect{|i| i.to_i}
  tx[6] = ips[0]
  tx[7] = ips[1]
  tx[8] = ips[2]
  tx[9] = ips[3]
  # puts HOST_IP
  tx = tx.collect{|i| i.chr}.join
  # puts tx.bytes.inspect
  #
  # puts 'send acc'
  u2.send tx, 0, tip, 2000  
  
  # puts '1.2'
  data = nil
  # status = Timeout::timeout(2) {
#     data = u2.recvfrom(1000)
#   }
  # msg = data[0]
  # last_name,first_name = msg[92..107].strip.split(",")
  # hn = msg[108..118].strip
    
  # puts '2'
    
  last = Time.now 
  msg_c = "\x00\x00\x00\x00\x00\x00~\x01\x8A\xC1\x00\x00\x00\x00\x00\"\x00\x00\x00\x00\x00\x00\x00\x00ICU|B288A\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xFF"
  
  # puts "B450 2"
  # puts msg_c.bytes.inspect
  # puts 'send'
  
  
  tx = msg_c.bytes
  
  tx[6] = ips[0]
  tx[7] = ips[1]
  tx[8] = ips[2]
  tx[9] = ips[3]
  
  tx = tx.collect{|i| i.chr}.join
  
  # puts tx.bytes.inspect 
  # send token
  u2.send tx, 0, tip,2000


  # puts 'send acc 2'

  end  
  
  # puts '3'
  data = nil
  status = Timeout::timeout(10) {
    data = u2.recvfrom(1000)
  }
  
  # puts 'send acc 3'
  
  # puts data.inspect
  msg = data[0]

  #
  msg.size.times do |i|
    # puts "#{i}\t#{msg[i].inspect}\t#{msg[i]}\t#{msg[i].ord}"
    # puts "#{i}\t#{msg[i].ord}"
    
    
    mapx[i] = [] unless mapx[i]
    
    unless mapx[i].index(msg[i].ord)
      
      
      mapx[i] << msg[i].ord
    
      
    end
    

  end

  msg.size.times do |i| 
    
    if mapx[i].size > 0
      puts "#{i}\t#{mapx[i].join("\t")}"
    end
    
  end
   
  

# puts '4'
# puts msg.size
# puts msg.bytes.inspect
  ########### Vital Sign
  if msg.size >200
  so2 = msg[207].ord
  pr = msg[209].ord
  sys = msg[141].ord
  dia = msg[143].ord
  hour = msg[150].ord
  min = msg[149].ord
  
  
  
  sense = {}
  
  sense[:ip]  = tip
  sense[:spo2] = so2
  sense[:pr] = pr
  sense[:hr] = pr
  sense[:ref] = hn
  sense[:name] = station_name
  sense[:bp] = "#{sys}/#{dia}"
  sense[:hour] = hour
  sense[:min] = min
  sec = Time.now.sec
  sense[:bp_stamp]  = format("%02d%02d%02d",hour,min,0)
  stamp = sense[:bp_stamp]
  #  
  # 
ref = "-"
          # data[:bp] = '120/90'
          # data[:pr] = 60 + rand(60)
          # data[:hr] = data[:pr]
          # data[:rr] = 18 + rand(4)
          # data[:temp] = 36 + rand(4)
          # data[:spo2] = 90+rand(10)
          # data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
          #
          data = sense
          
          puts data.inspect 
          
          puts 'xxvvvxx' + station_name
          
          
          msg = <<MSG
Data.Sensing device_id=#station_name
#{{'station'=>station_name, 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
          # puts msg

          puts 'Start Sent Data '+msg
        
          ws.send(msg)


  # 
  # send_to_gateway sense
  # 
end

  # puts "#{Time.now - last} #{msg.size}. SO2 : #{so2}, PR : #{pr}, BP : #{sys}/#{dia}, Time : #{hour}:#{min}"


  end


  puts (Time.now - last)
  
  
  
 rescue Exception=>e
   
  puts e.inspect

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