require 'net/http'
require "openssl"
require 'digest/sha2'
require 'base64'
require 'json'


module Tempus
  
  def self.decode64 encode
      return encode.unpack('m')[0]
  end
  
  class Gateway
    
    attr :url
    attr :username
    attr :password
    attr :key
    attr :iv
    attr :decode_cipher
    
    
    
    attr :token
    attr :refresh_token
    
    attr :expired_in
    
    attr :organization_id
    attr :organization_name
    
    
    def initialize settings
      
      puts 'init'
      
      if settings[:key]
        
      set_decription(settings[:key], settings[:iv])   
      @url = settings[:url]
      @username = decode(settings[:username])
      @password = decode(settings[:password])
      @token = nil
      
      else
      
      @url = settings[:url]
      @username = settings[:username]
      @password = settings[:password]
      @token = nil
      
      end
      
      
      puts "Init #{@url} #{@username} #{@password}"
      
      
      token = get_token
      
    end
    
    
    
    
    def decode encrypt64
        
       
       if  encrypt64 
        
         encrypt = Tempus::decode64(encrypt64)       
         plain = @decode_cipher.update(encrypt)
         plain << @decode_cipher.final
         @decode_cipher.reset
         return plain.split("\u0000").join    
       
       else 
       
         return nil
       
       end
       
    end
    
    def set_decription key, iv
      
      @key = Tempus::decode64(key)
      @iv = Tempus::decode64(iv)
      alg = "AES-256-CBC"
      @decode_cipher = OpenSSL::Cipher::Cipher.new(alg)
      @decode_cipher.decrypt
      @decode_cipher.key = @key
      @decode_cipher.iv = @iv
     
    end
    
    def set_token result
      
      # puts "set_token #{result.inspect }"
      @token = result['Access_token']
      @refresh_token = result['Refresh_token']
      @expired_in = Time.at(Time.now.to_i + result['Expires_in']) if result['Expires_in']
      set_decription(result['K'], result['V']) if result['K'] and result['V']
      
    end
    
    def get_token
      
      
      begin 
      
      
      unless @token
        
       
        uri = URI("#{@url}/Account/APILogin")
        
        req = Net::HTTP::Post.new(uri, {'Accept'=>'application/json','Content-Type' =>'application/json'})
        p = {}
        p['Username'] = @username
        p['Password'] = @password
        p['DEM'] = "AES"
        p['Key'] = ""
       
        
        req.body = p.to_json
   
        res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl=>true) {|http|
          http.request(req)
        }

        puts res.body

        result = JSON.parse(res.body)['Data']
        
        set_token result
        
      end
      
      return @token
      
      
      rescue Exception=>e
          
          
          
      end
      
      
    end

    def logout

        @token = nil
      
    end
    
    def refresh_token
      puts "refresh_token"
      token = get_token
      
      
      uri = URI("#{@url}/Account/APIRefreshToken")
      
      req = Net::HTTP::Post.new(uri, {'Accept'=>'application/json','Content-Type' =>'application/json','Authorization'=>"bearer #{token}"})
      p = {}
      p['refreshToken'] = @refresh_token 
      
      req.body = p.to_json
 
      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl=>true) {|http|
        http.request(req)
      }

      puts res.body

      if JSON.parse(res.body)['IsSuccessful'] == false

        logout
        

      else

        result = JSON.parse(res.body)['Data']


        if result

          data = JSON.parse(decode(result))
            
          puts data
            
          set_token data
        
        end

    end
      

      
    end
    
    
    
    def get_live_incidents
      
      
      data = get_data "/Api/Clinical/LiveIncidents?organizationId=#{@organization_id}", nil
      
      unless data
          
        data = get_data "/Api/Clinical/LiveIncidents?organizationId=#{@organization_id}", nil
        
      end
      
      return data
      
      
    end
    
    def get_incidents params
      
      fromDate=Time.now.to_date.at_beginning_of_day
      toDate=Time.now
      
      device_id = nil 
      device_id = params[:device_id]
      
      puts "Device Id : #{device_id}"
      
      fromDate=params[:from_date] if params[:from_date]
      toDate=params[:to_date] if params[:to_date]
      
      fromDate = fromDate.strftime("%Y-%m-%dT%H:%M:%S")
      toDate = toDate.strftime("%Y-%m-%dT%H:%M:%S")
      
      uri = "/Api/Clinical/Incidents?organizationId=#{@organization_id}&fromDate=#{fromDate}&toDate=#{toDate}"
      uri << "&tempusSerialNumber=#{device_id}" if device_id
      
   
      data = get_data uri, nil
      
      return data
      
      
    end
    
    
    def get_organization 
      
      data = get_data "/Api/Organizations", nil
     
      first_org = data[0]
      if first_org
        @organization_id =   first_org['OrganizationId']
        @organization_name = first_org['Name']
      
      
        return @organization_id
      else
        return nil
      end
      
      
      
    end
    
    def get_trended_vitals incident_id, datetime=nil

      unless datetime
        return get_data "/Api/Clinical/Incidents/#{incident_id}/TrendedVitals", nil
      else
        puts 'LiveTrendedVitals '+ datetime.to_s
        return get_data "/Api/Clinical/Incidents/#{incident_id}/LiveTrendedVitals?toDate=#{datetime}", nil
      end
        # return data
      
    end


    def get_events incident_id, datetime=nil

      unless datetime
        return get_data "/Api/Clinical/Incidents/#{incident_id}/Events", nil
      else
        return get_data "/Api/Clinical/Incidents/#{incident_id}/LiveEvents?toDate=#{datetime}", nil
      end
        # return data
      
    end
    
    def download_twelve_leads incident_id, twelve_leads_id, filename, format='JPEG'
# TWELVE_LEADS
        data = get_data "/Api/Clinical/Incidents/#{incident_id}/Events/TwelveLead/#{twelve_leads_id}?Format=#{format}", nil
        puts data.size
        if data['TwelveLeadData']
        
          out = File.open(filename, 'w')
          out.write data['TwelveLeadData'].unpack('m')[0]
          out.flush
          out.close
        
        end

    end


    
    def download_pdf incident_id, filename
# TWELVE_LEADS
        data = get_data "/Api/Clinical/Incidents/#{incident_id}/PDF", nil
        # puts data.to_json
        if data['Data']
        
          out = File.open(filename, 'w')
          out.write data['Data'].unpack('m')[0]
          out.flush
          out.close
          
        
        end
        
        
      
    end

    
    
    def get_data uri, raw
      
      
      begin
      
      token = get_token
      
      puts uri
 
      
      uri = URI("#{@url}#{uri}")
      
      

      req = Net::HTTP::Get.new(uri, {'Accept'=>'application/json','Content-Type'=>'application/json','Authorization'=>"bearer #{token}"})

      res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl=>true) {|http|
        http.request(req)
      }
      
     # puts res.body #if raw
      # puts res.body.size
      
      data = JSON.parse(res.body)
      if data['IsSuccessful'] 
        
        if raw==nil
          data = JSON.parse(decode(data['Data']))
        else
          data = decode(data['Data'])
        end
        
        return data
        
      else
        return {'IsSuccessful'=>false, 'Reconnect'=>false}
        
      end
      
    rescue Exception=>e
      
      # raise 'Error  '
      puts "GW Error : " +e.message
      refresh_token
      # data = {'IsSuccessful'=>false, 'Reconnect'=>true, 'Error'=>e.message}
      
   #    return data
      
    end
      
      
        
    end
    
    
    
  end
  
  
end