module BLE



def self.start ws


# Selecter adapter
$a = BLE::Adapter.new('hci0')
puts "Info: #{$a.iface} #{$a.address} #{$a.name}"

# Run discovery

puts "BLE : "+ BLE::ok?.to_s

$a.start_discovery

 
#o_bluez = BLUEZ.object('/org/bluez')
#o_bluez.introspect
#@o_adapter = BLUEZ.object("/org/bluez/#{@iface}")
#@o_adapter.introspect
        

#puts  @o_adapter.methods.sort 

address = []
address += ['C0:26:DA:01:DA:F0']
address += ['C0:26:DA:10:C1:92']
address += [ENV['TEMP_ADDRESS']] if ENV['TEMP_ADDRESS']
puts "TEMP #{address}"

while true


# .introspect # Force refresh
#puts 'BLE : start scan'
sleep(1)
#puts $a.devices.inspect 

puts "BLE : #{BLE::Adapter.list.size}"


#address = ['C0:26:DA:01:DA:F0']
#address = [ENV['TEMP_ADDRESS']] if ENV['TEMP_ADDRESS']
#puts "TEMP #{address}"
devices = {}



for i in $a.devices


begin

    d = $a[i]

 #     puts "#{i} #{d.alias}" #if d.alias.index "TAIDOC"  
  if address.index(i)
       
	
    
    d = $a[i]

      if  (d.alias=='TAIDOC TD1261' or d.alias=='TAIDOC TD1107' )

             puts "Found #{d.alias} #{i}"
              
             lines = []

             lines << "STATUS:T1|T1:0.0"

                msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM

#                puts msg

#                puts  ws.send(msg)

              

              d.on_signal do |intf,props|

              puts "BLE : #{intf} #{props.inspect}"

              
              end
            
            
            
            #puts 'connect '+devices.inspect
            d.connect
	    d.refresh

	    count = 10 


	    while count>0

              		count -=1
                        puts '.'
                        d = $a[i]
                        #d.refresh
                        #puts d.services.size

                        if d.services.size>0


                    	   service_uuid = '00001809-0000-1000-8000-00805f9b34fb'
                           char_uuid = '00002a1c-0000-1000-8000-00805f9b34fb'

                             d.services.each do |s|


                            if s == service_uuid
                                
				    d.subscribe_indicate(service_uuid,char_uuid) do |raw|
                                    puts '***********indicate'
				    puts raw.bytes.inspect 
				    puts raw.unpack("H*")
                                    #raw =  raw.unpack("H*")[0]
					
					#puts " #{raw.bytes[2]*16+raw.bytes[3]}"

				     	temp = format('%0.1f',(raw.bytes[1]+256*raw.bytes[2])/10.0)

                			lines = []

                			lines << "STATUS:T1|T1:#{temp}"

                msg = <<EOM
Monitor.Update zone_id=*
#{lines.join("\n")}
EOM

                puts msg

                puts  ws.send(msg)


                         
                            end  # end sub
                           
                            end  # end uuid

             	       end  # end services
			break
             	end
			sleep(0.2)
            end    


	    d.disconnect
	    d.remove

     
      

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
