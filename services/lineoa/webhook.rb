require 'sinatra'
require 'line/bot'
require 'base64'
require 'rack'
require 'webrick'
require 'openssl'
require 'net/http'
require 'active_support/all'
require 'active_record'

# Allow requests from any host (only safe for development)
set :protection, except: :http_origin
disable :protection

set :bind, '0.0.0.0'
require_relative 'lib/kafka'



CERT_PATH = '../../'

webrick_options = {
	:BindAddress        => '0.0.0.0',
        :Port               => 4567,
        :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
        :DocumentRoot       => "",
        :SSLEnable          => false,
        :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
        :SSLCertificate     => OpenSSL::X509::Certificate.new(  File.open(File.join(CERT_PATH, "server.crt")).read),
        :SSLPrivateKey      => OpenSSL::PKey::RSA.new(          File.open(File.join(CERT_PATH, "private.key")).read),
        :SSLCertName        => [ [ "CN",WEBrick::Utils::getservername ] ]
}




#class LineOA < Sinatra::Base

before do
  puts "== Incoming Request =="
  puts "Host: #{request.env['HTTP_HOST']}"
  puts "Method: #{request.request_method}"
  puts "Path: #{request.path}"
  puts "Params: #{params.inspect}"
  puts "Headers: #{request.env.select { |k, _| k.start_with?('HTTP_') }}"
end

 
set :clients, {}

  get '/' do
    'LINEOA Webhook!'
  end

producer = GXTKafka.producer

producer.produce(topic: LOG_TOPIC, payload: "Start LINEOA", key: "lineoa").wait


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


  clients[channel] = {:client=>c, :conf=>conf, :url=>conf['delegate_url'], :media=>conf['media']}

  end

 return c

end
	

  post '/send' do 
	
	  
    user_id = params[:user_id]
    user_id = params[:group_id] if params[:group_id]

    message = {
            type: 'text',
            text: params[:text]
          }
    puts params.inspect
    puts '--------------------------------' 
    puts params[:msg]

    message = JSON::parse params[:msg] if params[:msg]
    
    channel = params[:channel] if params[:channel]
    
    client(channel)

    clients = settings.clients
    puts "Channel = #{channel} #{message.inspect}"
    c = clients[channel][:client]
    result = c.push_message user_id, message
    puts result.inspect
    puts result.body


  end

post '/' do
  body = request.body.read
  #puts "Body: #{body}"
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

  request = Net::HTTP::Post.new(url, {'x-api-key'=>'','Content-Type' =>'application/json'})


  events.each do |event|
   
   # puts event.inspect 

    puts 

    
    puts event.to_hash

    c = clients[channel][:client]


    case event
    when Line::Bot::Event::Message

	

      hash = event.to_hash

      if event.type == Line::Bot::Event::MessageType::Image

      content = c.get_message_content(event.message['id'])
      tf = Tempfile.open('content')
      tf.write(content.body)
	
      hash['message']['content'] = Base64.encode64(content.body)
      hash['message']['content_raw'] = content.to_json
      
      end
      puts "XXXXXX"
      puts clients[channel].inspect
      if clients[channel][:media]=='kafka'
        kafka_message = {
          "url"=>url,
          "channel"=>channel,
          "method"=>"POST",
          "body"=>hash
        }
        producer.produce(topic: INBOUND_TOPIC, payload: kafka_message.to_json, key: "lineoa").wait

      else

        request.body = hash.to_json
 
        response = http.request(request)


      end





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
        response = c.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  end

  # Don't forget to return a successful response
  "OK"
end


    
# end

puts 'Ready'

# Rack::Handler::WEBrick.run LineOA, **webrick_options
