require 'active_support/all'
require 'active_record'
require 'net/http'

url = URI("https://sherry.emr-life.com/www/Api/lineoa")


       http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true #if uri.instance_of? URI::HTTPS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10 # seconds

       request = Net::HTTP::Post.new(url, {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json','User-Agent'=>"Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0"})
      
      # request['x-api-key'] = 'DCTIoTCovid19'
      request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
      # {"hn"=>"", "weight"=>"90.00", "height"=>"180.00", "bmi"=>"27.78", "pr"=>"80", "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "time"=>"23:44:41", "date"=>"2021-05-12", "serial_number"=>"00000"}
 

      obj = {"type"=>"message", "message"=>{"type"=>"text", "id"=>"15229438606003", "text"=>"f"}, "timestamp"=>1639211885245, "source"=>{"type"=>"user", "userId"=>"U7921527448ec9cbf2021991d997ab1de"}, "replyToken"=>"6108188eb56143ac95f22e2e57c9ab9a", "mode"=>"active"}     

 
  #    request.set_form_data(obj)
      request.body = obj.to_json

      
      response = http.request(request)


      puts response.inspect 
