
require 'net/http'
require 'digest'
require 'json'


module Zello
  
  class Connector
    
    def initialize connect_str
     
      self.connect connect_str
  
       
      
    end
    
    def connect connect_str
      
      t = connect_str.split(":")
      
      @username, @host_path = t[0].split("@")
      @api_key = t[1]
      @hash_password = t[2]
      @host = "https://#{@host_path}"
      @app_name = @host_path.split(".")[0]
      
      puts "Zello host : #{@host}"
      puts "Zello api_key : #{@api_key}"
      puts "Zello username : #{@username}"
      puts "Zello password : #{@hash_password}"
      
      
      path = "/user/gettoken"
      uri = URI("#{@host}#{path}")

      response = Net::HTTP.get(uri)

      puts response

      data = JSON.parse(response)
      status = data['status']
      code = data['code']
      token = data['token']
      @sid = data['sid']
      puts token
      
      
      path = "/user/login?sid=#{@sid}"
      uri = URI("#{@host}#{path}")


      res = Net::HTTP.post_form(uri,  'token'=>token, 'username' => @username, 'password' => Digest::MD5.hexdigest(@hash_password+token+@api_key))

      
      data = JSON.parse(res.body)
      status = data['status']
      code = data['code']
    
      puts "Result #{status}"
      
      @connected = status=='OK'
      @last = get_last_id
      return @connected
      
    end
    
    def get_last_id

      meta_path = "/history/getmetadata?sid=#{@sid}"
      @meta_uri = URI("#{@host}#{meta_path}")

      res = Net::HTTP.post_form(@meta_uri,'max'=>1)
        
      data = JSON.parse(res.body)
      puts res.body
      
      @last = 0
      @last = data['messages'][0]['id']+ 1 if  data['total'] and data['total']>0
      @last = -1 unless data['total']
      return @last
    
    end
    
    def ready
      return @last >= 0 
    end
    
    def retrieve key
      
      
                 istatus = 'Waiting'

                 while istatus=='Waiting'

              
                 media_path = "/history/getmedia/key/#{key}?sid=#{@sid}"
                 media_uri = URI("#{@host}#{media_path}")
                 response = Net::HTTP.get(media_uri)
                 puts response
                 media_data = JSON.parse(response)
                 puts "Media : #{media_data['status']} #{media_data['url']}"
                 if media_data['status'] == 'OK'

                 return media_data
                   
                 end
                 sleep 1

                 end
                 
                 
    end
    
    def getSID
      return @sid
    end
   
    def feed 
      
      results = nil
      meta_path = "/history/getmetadata?sid=#{@sid}"
      @meta_uri = URI("#{@host}#{meta_path}")
      # puts " " +@last.to_s
      
      res = Net::HTTP.post_form(@meta_uri,'start_id'=>@last)
      
      puts res.body
  
      data = JSON.parse(res.body)
      
      if data['returned'] > 0 
        # puts  data.inspect 
        
        results = []
  
       
        threads = []
  
        for i in data['messages']
      
          
          # if i['media_key']
 #
 #
 #
 #            threads << Thread.new {
 #
 #            istatus = 'Waiting'
 #
 #            while istatus=='Waiting'
 #
 #            key = i['media_key']
 #            media_path = "/history/getmedia/key/#{key}?sid=#{@sid}"
 #            media_uri = URI("#{@host}#{media_path}")
 #            response = Net::HTTP.get(media_uri)
 #            puts response
 #            media_data = JSON.parse(response)
 #            puts "Media : #{media_data['status']} #{media_data['url']}"
 #            if media_data['status'] == 'OK'
 #
 #            # system("open #{media_data['url']}")
 #
 #
 #            data['media'] = media_data
 #
 #            istatus = media_data['status']
 #
 #
 #            end
 #            sleep 1
 #
 #            end
 #
 #
 #            }
 #
 #
 #
 #
 #          end
      
      
          results << i
      
        end
    
        threads.each { |thr| thr.join }
        
        
        
    
        @last = data['messages'][0]['id']+1 if data['total']>0
      
      
    end
    
    
    return results
    
    
  end
    
  end

  
end



#
# zello = Zello::Connector.new "admin@pcmlife.zellowork.com:SM7YHIE5KV17RJH0W6Q0539J0U3R4HCM:90cd45bcf0aa7904e2a20f2a6c53e406"
#
#
# while true
#   msgs = zello.feed
#
#   puts '.'
#   if msgs
#     for i in msgs
#       if i['media_key']
#         media = zello.retrieve i['media_key']
#         puts "Sender #{i['sender']} To #{i['recipient']}  Type #{i['type']} Path #{media['url']}"
#
#         uri = URI("#{media['url']}?sid=#{zello.getSID}")
#         response = Net::HTTP.get(uri)
#         filename = media['url'].split("/")[-1]
#         f = File.new "#{filename}", "w"
#
#         f.write response
#         f.flush
#
#         f.close
#
#
#       elsif i['type'] == 'text_message'
#         puts "Sender #{i['sender']} To #{i['recipient']} Text #{i['text']}  "
#       end
#     end
#
#   end
#
#
#   sleep 1
# end



