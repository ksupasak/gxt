module BLE

class CharDesc

def flag?(flag_name)
  
  flags.include?(flag_name) or flags.include?('indicate')

end

end

def self.start ws

if true

# Selecter adapter
$a = BLE::Adapter.new('hci0')
puts "Info: #{$a.iface} #{$a.address} #{$a.name}"

# Run discovery

puts BLE::ok?

$a.start_discovery

 
o_bluez = BLUEZ.object('/org/bluez')
o_bluez.introspect


@o_adapter = BLUEZ.object("/org/bluez/#{@iface}")
@o_adapter.introspect
        

#puts  @o_adapter.methods.sort 


address = ['C0:26:DA:01:DA:F0']
address = ['C0:26:DA:10:C1:92']
address = [ENV['TEMP_ADDRESS']] if ENV['TEMP_ADDRESS']
puts "TEMP #{address}"

while true


# .introspect # Force refresh
#puts 'start scan'
sleep(0.1)
#puts $a.devices.inspect 

#puts BLE::Adapter.list


#address = ['C0:26:DA:01:DA:F0']
#address = [ENV['TEMP_ADDRESS']] if ENV['TEMP_ADDRESS']
#puts "TEMP #{address}"
devices = {}

begin

for i in $a.devices
#    d = $a[i]

 #    puts "#{i} #{d.alias}" if d.alias.index "TAIDOC"  
  if address.index(i)
    
    d = $a[i]

      if  (d.alias=='TAIDOC TD1261' or d.alias=='TAIDOC TD1107' )

         #     puts "Found #{d.alias} #{i}"
             if false

              d.on_signal do |intf,props|

              puts "#{intf} #{props.inspect}"

              case intf
              when BLE::I_DEVICE


                      if  props['ServicesResolved']
                              devices.delete d.address
                      end


              end 
              
            end
            
            end
            
            #puts 'connect '+devices.inspect
            d.connect

	    o = d.refresh!
		
	  

            if devices[i] == nil

                           service_uuid = '00001809-0000-1000-8000-00805f9b34fb'
                           char_uuid = '00002a1c-0000-1000-8000-00805f9b34fb'
			
                           #00002a1c-0000-1000-8000-00805f9b34fb
 			  # puts d.characteristics(service_uuid).join("\n")
				
		            
                             d.services.each do |s|

			
                            if s==service_uuid
				   
				  
					


                                    d.subscribe(service_uuid,char_uuid) do |raw|
                                    puts '***********indicate'
				    puts raw.bytes.inspect 
				    puts raw.unpack("H*")
                                    #raw =  raw.unpack("H*")[0]
					
					#puts " #{raw.bytes[2]*16+raw.bytes[3]}"

				     	temp = format('%0.1f',(raw.bytes[1])/10.0+25.6)

                			lines = []

                			lines << "STATUS:T1|T1:#{temp}"

                msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM

                puts msg

                puts  ws.send(msg)


                         
                                    end
                                    devices[i] = true
                            end
                            #devices[i]
                            end


            end         
      

     end          
          
    
 end

  end
  
  if false
  
	d = $a[i]
	#puts "#{i} #{d.alias}"
	if d.alias=='AOJ-20A'
	
	  puts 'found device'
	  d.connect
	  

	  d.services.each do |s|
	  #puts s
	  
          if s=='0000ffe0-0000-1000-8000-00805f9b34fb'

	  puts 'found service'

	  d.characteristics(s).each do |uuid|

	   info  = BLE::Characteristic[uuid]
           name  = info.nil? ? uuid : info[:name]
         #  puts "%-30s: " % [ name ]
		
          if uuid=='0000ffe1-0000-1000-8000-00805f9b34fb'
	
	  puts 'found endpoint'	
		 
	     d.subscribe(s,uuid) do |raw|
		puts 'notify'
		puts raw.inspect
		
		puts raw.size

		puts raw.bytes.inspect 
		
		temp = format('%0.1f',(raw.bytes[4]*255+raw.bytes[5])/100.0+0.14)

		lines = []

      		lines << "STATUS:T1|T1:#{temp}"

    		msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM

                puts msg

                puts  ws.send(msg)


 
             end

          end

        end

	  end

	  end

 end

	end

end

end

end

rescue Exception=>e
	puts e.inspect 
puts e.backtrace
end


end





#BLE::start()
