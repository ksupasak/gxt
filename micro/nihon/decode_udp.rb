#!/usr/bin/env ruby

require 'json'

def hex_to_binary(hex_string)
  # แปลง hex string เป็น binary data
  [hex_string].pack('H*')
end

def decode_packet_data(binary_data)
  puts "=== Decoding Packet Data ==="
  puts "Data size: #{binary_data.size} bytes"
  
  if binary_data.size > 700
    # แสดงข้อมูลเป็น text
    puts "Text content:"
    binary_data.bytes.each do |byte|
      if byte < 127 && byte >= 32
        print byte.chr
      end
    end
    puts "\n"
  else
    # Decode binary packet structure
    bed_name = binary_data[0..11]
    puts "Bed name: #{bed_name}"
    
    # แปลง 2 bytes เป็น integer
    page_no = binary_data[12..13].unpack1('S')
    total_pack = binary_data[14..15].unpack1('S')
    num_wave = binary_data[16..17].unpack1('S')
    bed_id = binary_data[44..44+11]
    
    puts "Header hex: #{binary_data[0..24].bytes.map { |byte| "%02x" % byte }.join}"
    puts "Page number: #{page_no}"
    puts "Total packets: #{total_pack} (#{binary_data[12].to_i} #{binary_data[13].to_i})"
    puts "Number of waves: #{num_wave}"
    puts "Bed ID: #{bed_id}"
    
    start = 56
    puts "Wave data hex: #{binary_data[56..56+40].bytes.map { |byte| "%02x" % byte }.join(',')}"
    puts "Wave data chars: #{binary_data[56..56+40].bytes.map { |byte| byte.chr }.join(',')}"
    
    # Process each wave packet
    total_pack.times do |i|
      wave_id = binary_data[start..start+3].bytes.map { |byte| (byte & 0x7F).chr }.compact.join
      print "Wave ID: #{wave_id} = "
      
      value1 = (binary_data[start+2..start+2].bytes[0] & 0b10000000) >> 7
      value2 = (binary_data[start+3..start+3].bytes[0] & 0b10000000) >> 7
      tag = "#{value1}#{value2}"
      puts tag
      
      # กำหนดขนาดตาม tag
      size = case tag
             when '00' then 32
             when '01' then 64
             when '10' then 16
             when '11' then 128
             else 32
             end
      
      puts "  Size: #{size}"
      start += size * 2 + 4
    end
  end
  puts "=" * 50
end

# อ่านไฟล์ udp_data.json
puts "กำลังอ่านไฟล์ udp_data.json..."
puts "=" * 50

begin
  File.open("udp_data.json", "r") do |file|
    line_number = 0
    file.each_line do |line|
      line_number += 1
      line = line.strip
      next if line.empty?
      
      begin
        # Parse JSON
        json_data = JSON.parse(line)
        
        # แสดงข้อมูลพื้นฐาน
        timestamp = json_data['timestamp']
        client_ip = json_data['client_ip']
        client_port = json_data['client_port']
        data_size = json_data['data_size']
        hex_data = json_data['hex_data']
        
        puts "\n[Line #{line_number}] #{timestamp}"
        puts "Client: #{client_ip}:#{client_port}"
        puts "Data size: #{data_size} bytes"
        puts "Hex data: #{hex_data[0..50]}#{hex_data.length > 50 ? '...' : ''}"
        
        # แปลง hex เป็น binary
        binary_data = hex_to_binary(hex_data)
        
        # Decode binary data
        decode_packet_data(binary_data)
        
      rescue JSON::ParserError => e
        puts "Error parsing JSON at line #{line_number}: #{e.message}"
        puts "Line content: #{line[0..100]}..."
      rescue => e
        puts "Error processing line #{line_number}: #{e.message}"
      end
    end
  end
  
  puts "\nเสร็จสิ้นการประมวลผลไฟล์"
  
rescue Errno::ENOENT
  puts "ไม่พบไฟล์ udp_data.json"
rescue => e
  puts "เกิดข้อผิดพลาด: #{e.message}"
end
