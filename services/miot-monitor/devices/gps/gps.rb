require_relative 'config'
require 'json'

module Device



def self.gps_cms_server ws
    
    # 1000.times do |i|
    #   lat = 15.8700+0.01*Math.cos(Time.now.to_i*Math::PI/180)
    #   lng = 100.9925+0.01*Math.sin(Time.now.to_i*Math::PI/180)
    #   $global_position = "#{lat},#{lng}"
    #   sleep 1
    # end

    while true 
      
      uri = URI("#{CMS_DVR_HOST}/StandardApiAction_getDeviceStatus.action?devIdno=#{CMS_DVR_DEVICE_ID}&toMap=1&driver=0&geoaddress=1")
      data = Net::HTTP.get(uri)
      
      json =  JSON.parse(data)
      
      
      lat = "15"
      lng = "100"
      speed = ''
      
      
      if json['result']==0 and json['status']
        
        item = json['status'][0]
      
        lat = item['mlat']
        lng = item['mlng']
        speed = item['sp']  
          
      end
      
      $global_position = "#{lat},#{lng}"
      
      $global_speed = "#{speed}"
      
      sleep 1
      
      
      
    end
    
end

def self.gps_sim_server ws
    
  10000.times do |i|
    lat = 15.8700+0.01*Math.cos(Time.now.to_i*Math::PI/180)
    lng = 100.9925+0.01*Math.sin(Time.now.to_i*Math::PI/180)
    $global_position = "#{lat},#{lng}"
    sleep 1
  end
    
end

def self.gps_test_server ws
    
  while true
   puts "GPS : #{$global_position}"
   sleep 1
  end
    
end


end