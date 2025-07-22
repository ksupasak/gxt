# app.rb
require 'sinatra'
require 'line/bot'
require 'base64'


set :bind, '0.0.0.0'

require 'sinatra/base'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'net/http'
require 'active_support/all'
require 'active_record'

CERT_PATH = '/home/esmroot/apps/cert'

webrick_options = {
	:BindAddress        => '0.0.0.0',
        :Port               => 4567,
        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        :DocumentRoot       => "",
        :SSLEnable          => false,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "certificate.crt")).read),
        :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "private.key")).read),
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
}


class MyServer < Sinatra::Base
 
set :clients, {}

  get '/' do
    'SSL FTW!'
  end


def client channel='praram9'
   
  clients = settings.clients
  
  c = clients[channel][:client] if clients[channel] 
   puts "ch #{channel}"
  puts clients.inspect

  unless c

	
  conf = JSON.parse(File.open(File.join("conf","#{channel}.json")).read())
  puts conf.inspect 	  
  c = Line::Bot::Client.new { |config|
    config.channel_id = conf['channel_id']
    config.channel_secret = conf['channel_secret']
    config.channel_token = conf['channel_token']
  }


  clients[channel] = {:client=>c, :conf=>conf, :url=>conf['delegate_url']}

  end

 return c

end
	
  post '/send' do 
	
	  
	user_id = params[:user_id]

	message = {
          type: 'text',
          text: params[:text]
        }
	
	puts params[:msg]

	message = JSON::parse params[:msg] if params[:msg]
	
	channel = 'praram9'
	channel = params[:channel] if params[:channel]
	
	puts "Channel = #{channel}"

	result = client(channel).push_message user_id, message
	puts result.inspect
	puts result.body


  end

post '/' do
  body = request.body.read
  
  channel = 'praram9'

  channel = params[:channel] if params[:channel]

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client(channel).validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client(channel).parse_events_from(body)
clients = settings.clients
  
    url = URI("https://praram9.emr-life.com/www/Api/lineoa")
    url = URI(clients[channel][:url])

    puts "Delegate to #{url}"

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true #if uri.instance_of? URI::HTTPS
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.read_timeout = 10 # seconds

      request = Net::HTTP::Post.new(url, {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json'})


  events.each do |event|
   
    puts event.inspect 

    puts 

    	puts event.to_hash

    case event
    when Line::Bot::Event::Message

	


    #  url = URI("https://sherry.emr-life.com/www/Api/lineoa")


     # http = Net::HTTP.new(url.host, url.port)
     # http.use_ssl = true #if uri.instance_of? URI::HTTPS
     # http.verify_mode = OpenSSL::SSL::VERIFY_NONE
     # http.read_timeout = 10 # seconds

     # request = Net::HTTP::Post.new(url, {'x-api-key'=>'DCTIoTCovid19','Content-Type' =>'application/json'})
      
      # request['x-api-key'] = 'DCTIoTCovid19'
    #  request.each_header {|key,value| puts "#{key} = #{value.inspect}" }
      # {"hn"=>"", "weight"=>"90.00", "height"=>"180.00", "bmi"=>"27.78", "pr"=>"80", "rr"=>nil, "spo2"=>"99", "temp"=>"35.4", "time"=>"23:44:41", "date"=>"2021-05-12", "serial_number"=>"00000"}
 

#      obj = {"type"=>"message", "message"=>{"type"=>"text", "id"=>"15229438606003", "text"=>"f"}, "timestamp"=>1639211885245, "source"=>{"type"=>"user", "userId"=>"U7921527448ec9cbf2021991d997ab1de"}, "replyToken"=>"6108188eb56143ac95f22e2e57c9ab9a", "mode"=>"active"}     

 
  #    request.set_form_data(obj)

      hash = event.to_hash

      if event.type == Line::Bot::Event::MessageType::Image

      content = client.get_message_content(event.message['id'])
      tf = Tempfile.open('content')
      tf.write(content.body)
	
      hash['message']['content'] = Base64.encode64(content.body)
      hash['message']['content_raw'] = content.to_json
      
      end

      request.body = hash.to_json

      puts 
      puts hash.to_json      
      
      response = http.request(request)





      case event.type
      when Line::Bot::Event::MessageType::Text
	puts 'Echo'
        message = {
          type: 'text',
          text: 'echo : ' + event.message['text']
        }
        #client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
	puts 'Got content '
        puts event.to_hash.to_json
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  end

  # Don't forget to return a successful response
  "OK"
end


end



Rack::Handler::WEBrick.run MyServer, **webrick_options
