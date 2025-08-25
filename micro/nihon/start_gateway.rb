require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
# require 'em-http-server'


def connect solution, host, port
  connect_url = "wss://#{host}:#{port}/ws/#{solution}/Home/index"
  connect_url = "wss://#{host}/ws/#{solution}/Home/index"
  
  puts connect_url
  WebSocket::Client::Simple.connect connect_url
end




name = 'Bed01'
name = ARGV[0] if ARGV[0]


ref = '-'
ref = ARGV[1] if ARGV[1]

host = 'miot.esm.local'
host = ARGV[2] if ARGV[2]
port = 1792


solution = host.split(".")[0]
solution = ARGV[3] if ARGV[3]

gps = true

gps = false if ARGV[4] == 'gps_dvr'



def bind_event ws

ws.on :message do |msg|
  puts msg.data
  lines = msg.data.split("\n")
  if lines[0]=='print'
    open("| lpr", "w") { |f| f.puts lines[1..-1] }
  end

end

ws.on :open do
  ws.send 'hello!!!'
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws = connect()
   bind_event ws
   puts 'retry connect ..'
end

end



lead_idx = 0
leads = Array.new(32){|i| []}

ws = connect solution, host, port


puts "Start"
count = 0
ls = 20

bp = '119/80'
bp_stamp = Time.now


bind_event ws

period = 0

EventMachine.run {


map = {}

leads = Array.new(32){|i| []}

devices = {}


keys = {}
key_count = 0

 t =  Thread.new do



# สร้าง UDP socket ที่ bind กับทุก interface บน port 5000
server = UDPSocket.new
server.bind('0.0.0.0', 4038)

# เปิดไฟล์สำหรับบันทึกข้อมูล JSON แบบต่อเนื่อง
json_file = File.open("udp_data.json", "a")

puts "UDP Server กำลังรันบน port 5000..."
puts "รอรับข้อมูลจากทุก interface..."
puts "ข้อมูลจะถูกบันทึกลงไฟล์ udp_data.json แบบต่อเนื่อง"
puts "กด Ctrl+C เพื่อหยุด"





begin
  loop do
    # รอรับข้อมูล
    data, sender = server.recvfrom(2048)
    client_ip = sender[3]
    client_port = sender[1]
    timestamp = Time.now
    
    # แปลงข้อมูลเป็น hex string
    hex_data = data.bytes.map { |byte| "%02x" % byte }.join
    
    # สร้าง JSON object
    json_data = {
      timestamp: timestamp,
      client_ip: client_ip,
      client_port: client_port,
      data_size: data.size,
      hex_data: hex_data,
      raw_data: data.bytes
    }
    print "data: #{data.size}"

    if data.size > 1000
        data.bytes.each do |byte|
            if byte < 127
                print byte.chr
            end
        end
        puts ""
     end
 
   
   bed_name = ''
   bed_id = ''
   vs = {}





   if data[0]=="{"

        json = JSON.parse(data)

        puts json.inspect

        if json['VS'] and json['information']


            bed_name = json['information']['deviceId']
            bed_id = json['information']['deviceId']
            stamp = json['information']['timeStamp']

            json['VS'].each do |v|
                vs[v['name']] = v['value']
            end


            
            devices[bed_name] = {} unless devices[bed_name]
            devices[bed_name]['stamp'] = stamp.to_i
            devices[bed_name]['vs'] = vs


    

        end



   else

        bed_name = data[0..11]

        puts "bed_name: #{bed_name}"
        
        # two byte to integer
        page_no = data[12..13].unpack1('S')
        
        total_pack = data[14..15].unpack1('S')  
        #total_pack = 3
        num_wave = data[16..17].unpack1('S')
        bed_id = data[44..44+11]


        puts data[0..24].bytes.map { |byte| "%02x" % byte }.join
        puts "page_no: #{page_no}"
        puts "total_pack: #{total_pack}  #{data[12].to_i} #{data[13].to_i}"
        puts "num_wave: #{num_wave}"
        puts "bed_id: #{bed_id}"

        start = 56

        puts data[56..56+40].bytes.map { |byte| "%02x" % byte }.join(",")
        puts data[56..56+40].bytes.map { |byte| byte.chr}.join(",")

        devices[bed_name] = {} unless devices[bed_name]
        devices[bed_name]['wlabel'] = {} unless devices[bed_name]['wlabel']
        devices[bed_name]['leads'] = Array.new(32){|i| []} unless devices[bed_name]['leads']

        leads = devices[bed_name]['leads']
        wlabel = devices[bed_name]['wlabel']

        # TelemetryServer
        total_pack.times do |i|
          wave_id =  data[start..start+3].bytes.map { |byte| (byte & 0x7F).chr  }.compact.join

        #   unless keys[wave_id]
        #     keys[wave_id] = key_count
        #     key_count += 1
        #   end

 
          print "ID : #{wave_id} ="
          value1 = (data[start+2..start+2].bytes[0] & 0b10000000) >> 7
          value2 = (data[start+3..start+3].bytes[0]& 0b10000000) >> 7
          cw = wlabel.size 
          wlabel[wave_id] = cw


          # f1 = (value & 0b10000000) >> 7
          # value = data[start+4].to_i
          # f2 = (value & 0b01000000) >> 7
          # tag = "#{f1}#{f2}"
          tag = "#{value1}#{value2}"
         print " "
           puts tag
          if tag == '00'
            size = 32
          elsif tag == '01'
            size = 64
          elsif tag == '10'
            size = 16
          elsif tag == '11'
            size = 128
          end
          puts " #{size}"
          # start += size*2 + 4
          # bytes.each_slice(2).map { |hi, lo| (hi << 8) | lo }
          puts "wave_id: #{wave_id} #{wlabel[wave_id]}"

          if wlabel[wave_id]
            leads[wlabel[wave_id]] += data[start+4..start+4+size*2-1].bytes.each_slice(2).map { |hi, lo| 
            bytes = [hi, lo].pack("C*")  # => "\xFF\xEC"
            value = bytes.unpack("s>").first  # 's>' = signed 16-bit big-endian
            }
          end
          
          
          start += size*2 + 4

        #   puts leads.inspect


        end

      #   bed_name = bed_name.split(",")
      #   bed_name.each do |byte|
      #       if byte < 127
      #           print byte.chr
      #       end
      # end
    end
    
    # บันทึกลงไฟล์ JSON แบบต่อเนื่อง (แต่ละบรรทัดเป็น JSON object)
    json_file.puts json_data.to_json
    json_file.flush  # บังคับให้เขียนไฟล์ทันที
    
    # # แสดงผลบนหน้าจอ
    # puts "[#{timestamp.strftime('%Y-%m-%d %H:%M:%S.%L')}] ได้รับข้อมูลจาก #{client_ip}:#{client_port} (#{data.size} bytes)"
    # puts "  Hex: #{hex_data}"
    # puts "  บันทึกลงไฟล์: udp_data.json"
    # puts ""
    
    # ส่งข้อมูลกลับไปยัง client (optional)
    response = "ได้รับข้อมูลแล้ว: #{data.size} bytes"
    server.send(response, 0, client_ip, client_port)
  end
rescue Interrupt
  puts "\nกำลังปิด server..."
ensure
  ##server.close
  ##json_file.close
  ##puts "Server ปิดแล้ว"
end



end



# #   # timer method
  EM.add_periodic_timer(1) do


     now = Time.now
     stamp = now.to_json


     data = {}


    #  data[:pr] = 80 + (20 * Math.sin(Time.now.to_i*5*Math::PI/180)).to_i
    #  data[:hr] = data[:pr]
    #  data[:rr] = 18 + rand(4)
    #  data[:temp] = 36 + rand(4)

    #  data[:co2] = 30 + rand(20)

    #  data[:spo2] = 90+rand(10)

    #  if gps

    #  data[:lat] = 13.6908282+0.005*Math.cos((Time.now.to_i*2+sp)*Math::PI/180)+sx
    #  data[:lng] = 100.6987491+0.005*Math.sin((Time.now.to_i*2+sp)*Math::PI/180)+sy
    #  # puts Time.now.to_i%360+90
    #  data[:dvr_sp] = 3
    #  data[:dvr_hx] = Time.now.to_i*2%360
    #  data[:dvr_ol] = 1

    #  end

    devices.each_pair do |bed_name, device_data|
        
        puts bed_name

        data = device_data['vs'].clone

        data['pr'] = data['SpO2/PR'] if data['SpO2/PR']

        m = {}
        device_data['leads'].each_with_index do |lead, idx|
            m[idx] = lead
        end
        data[:leads] = m
        data[:wlabel] = device_data['wlabel']
        data[:msg] = "MSG:#{Time.now.strftime("%H:%M:%S")}"

        device_data['leads'] = Array.new(32){|i| []}
        stamp = Time.now.to_i if device_data['stamp'].nil?
        stamp = device_data['stamp'] if device_data['stamp']

        msg = <<MSG
Data.Sensing device_id=#{bed_name}
#{{'station'=>bed_name, 'stamp' => stamp, 'ref' => '-', 'data'=>data}.to_json}
MSG
            # puts msg
        ws.send(msg)
        
    end





  end




# rescue Exception=>e
#   puts "Try to connect in 5 seconds due to : #{e}"
#   puts "Backtrace:\n\t#{e.backtrace.join("\n\t")}"

#   sleep(5)
# end


# end

}
