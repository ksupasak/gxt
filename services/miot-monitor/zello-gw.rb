require 'net/http'
require 'digest'
require 'json'


host = "https://pcmlife.zellowork.com";
apikey =  "SM7YHIE5KV17RJH0W6Q0539J0U3R4HCM";
username = "admin"
password = "Kamsk_1792"

path = "/user/gettoken"
uri = URI("#{host}#{path}")


response = Net::HTTP.get(uri)

puts response

data = JSON.parse(response)
status = data['status']
code = data['code']
token = data['token']
sid = data['sid']
puts token

path = "/user/login?sid=#{sid}"
uri = URI("#{host}#{path}")


res = Net::HTTP.post_form(uri,  'token'=>token, 'username' => username, 'password' => Digest::MD5.hexdigest(Digest::MD5.hexdigest(password)+token+apikey))

puts res.body

t = Time.now.to_i


meta_path = "/history/getmetadata?sid=#{sid}"
meta_uri = URI("#{host}#{meta_path}")
res = Net::HTTP.post_form(meta_uri,'max'=>1)
puts res.body
data = JSON.parse(res.body)
last = 0 
last = data['messages'][0]['id']+1 if data['total']>0

while true

  cur = Time.now.to_i

  # res = Net::HTTP.post_form(uri,'start_ts'=>cur, 'end_ts'=>t)
  res = Net::HTTP.post_form(meta_uri,'start_id'=>last)
  
  t = cur

  puts res.body

  
  data = JSON.parse(res.body)
  
  if data['returned'] > 0 
    puts  data.inspect 
    threads = []
  
    for i in data['messages']
      
     
      if i['media_key']
        
      
        
        threads << Thread.new { 
        
        istatus = 'Waiting'
        
        while istatus=='Waiting'
            
        key = i['media_key']
        media_path = "/history/getmedia/key/#{key}?sid=#{sid}"
        media_uri = URI("#{host}#{media_path}")
        response = Net::HTTP.get(media_uri)
        puts response
        media_data = JSON.parse(response)
        puts "Media : #{media_data['status']} #{media_data['url']}"
        if media_data['status'] == 'OK'
          
          system("open #{media_data['url']}")
        
        istatus = media_data['status']
        end
        sleep 1
        
        end
        
        
        }
        
        
        
        
      end
      
      
      
      
    end
    
    threads.each { |thr| thr.join }
    
    
    
    last = data['messages'][0]['id']+1 if data['total']>0
    
  end
  
  sleep 1 
  
  
end




# Net::HTTP.start(uri.host, uri.port) do |http|
#   puts uri.inspect
#   request = Net::HTTP::Get.new uri
#
#   response = http.request request # Net::HTTPResponse object
#
#   puts response.inspect
# end