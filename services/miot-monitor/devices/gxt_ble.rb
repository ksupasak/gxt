module BLE



def self.start ws


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

while true


# .introspect # Force refresh
#puts 'start scan'
sleep(2)
#puts $a.devices.inspect 

#puts BLE::Adapter.list

begin

for i in $a.devices

	d = $a[i]
	#puts "#{i} #{d.alias}"
	if d.alias=='AOJ-20A'
	
	  puts 'found device'
	  d.connect
	  

	  d.services.each do |s|
	  #puts s
	  
          if s=='0000ffe0-0000-1000-8000-00805f9b34fb'

	  puts 'found service'

	  d.characteristics(s).each {|uuid|

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

          }

	  end

	  end



	end

end

end

end

rescue Exception=>e
	puts e.inspect 
end


end





#BLE::start()
