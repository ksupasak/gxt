require 'socket'
require 'net/http'
require 'json'
require "ipaddr"
require 'openssl'
require "digest"
require 'base64'


require_relative 'config/m540_cfg'
require_relative 'nihon_defib_lib'



module Device


  def self.defib_nihon  ws


    buffers = {}

  
  thread =  Thread.new {
    
    

    while(true)
      
          bp_stamp = Time.now
          
          stamp_i = Time.now.to_i
          
          
          buffers.each_pair do |device_id, device|
       
            
            puts device[:vs].size
            
          if device[:vs].size>0 and device[:vs][0][:stamp_i] == stamp_i
            
            
            ref = '0000'
            head_data = device[:vs].shift
            puts device[:vs].size
            
            
            data = head_data
            stamp = data[:stamp]
            

            msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>data[:name], 'stamp' => stamp, 'ref' => ref, 'data'=>data}.to_json}
MSG
            # puts msg

            puts 'Start Sent Data '+msg

            ws.send(msg)
#
            
          end
          
          while device[:vs].size > 0 and device[:vs][0][:stamp_i]<stamp_i
            head_data = device[:vs].shift
          end
          
            
          
          puts "#{device[:vs].collect{|i| i[:stamp_i] }.join(", ")}"
            
          end
          
          
          puts "waiting .. #{stamp_i} "
          sleep(1)
          
    end
    
  }
  
  

  # {:meas_type=>0, :date_time=>"2021-02-01T15:24:07", :data_pos=>429, :hrate=>75, :pulse_rate=>73, :resp_rate=>16, :spo2=>98, :pressure_unit=>0, :etco2=>40, :sys_bp=>nil, :dia_bp=>nil, :mean_bp=>nil, :mea_bp=>"32768-128-128T128:128:128", :sys_ibp1=>124, :dia_ibp1=>88, :mean_ibp1=>100, :sys_ibp2=>nil, :dia_ibp2=>nil, :mean_ibp2=>nil, :temperature_unit=>0, :temp1=>365, :label_temp1=>5, :temp2=>365, :label_temp2=>6, :st_1=>nil, :st_2=>nil, :st_3=>nil, :vpc=>nil, :cpr_depth=>nil, :cpr_rate=>nil, :length_unit=>0, :pr_press1=>75, :pr_press2=>nil, :ecg1_lLead=>128, :ecg1_sense=>0, :ecg2_lLead=>254, :ecg2_sense=>0, :ecg3_lLead=>254, :ecg3_sense=>0, :label_press1=>1, :label_press2=>128, :hum_filter_sts=>3, :filter=>1, :anotation_ch=>1, :exec_mode=>4, :spo2_gain=>4, :escco_disp_param=>0, :param_escco1=>0, :escco1=>nil, :param_escco2=>0, :escco2=>nil, :param_escco3=>0, :escco3=>nil, :param_escco4=>0, :escco4=>nil, :param_escco5=>0, :escco5=>nil, :param_escco6=>0, :escco6=>nil, :param_escco7=>0, :escco7=>nil, :amsa1x10_1=>2180, :amsa1x10_2=>2171, :amsa1x10_3=>2189, :amsa1x10_4=>2194, :amsa1x10_5=>2180, :amsa1x10_6=>2171, :amsa1x10_7=>2189, :amsa1x10_8=>2194, :amsa1x10_9=>2180, :amsa1x10_10=>2171, :amsa2x10_1=>1856, :amsa2x10_2=>1849, :amsa2x10_3=>1866, :amsa2x10_4=>1873, :amsa2x10_5=>1856, :amsa2x10_6=>1849, :amsa2x10_7=>1866, :amsa2x10_8=>1873, :amsa2x10_9=>1856, :amsa2x10_10=>1849, :etco2_unit=>0, :etco2_value=>nil}
  
  
  device_thread =  Thread.new {
    
    n = 30
    sam = 3
    


    while(true)
      
      device_id = '0000'
      
      (sam).times do |t|
     
          data = {}
          bp_stamp = Time.now - n + t*(n/sam)
          stamp = bp_stamp
          ref = '0000'
          
          data[:name] = device_id
          data[:bp] = '120/90'
          data[:pr] = 60 + rand(60)
          data[:hr] = data[:pr]
          data[:rr] = 18 + rand(4)
          data[:temp] = 36 + rand(4)
          data[:spo2] = 90+rand(10)
          data[:bp_stamp] = bp_stamp.strftime("%H%M%S")
          data[:stamp] = stamp
          data[:stamp_i] = stamp.to_i + n + 3
          
    
          buffers[device_id] = {:vs=>[]} unless buffers[device_id]
          buffers[device_id][:vs] << data
          
    
     end
         
    sleep(n)
          
    # puts  buffers[device_id][:vs].size
          
          
    end
    
  }
  
  device_thread.join
  thread.join
      
    
  end

end

