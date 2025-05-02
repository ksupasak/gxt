require 'sinatra'
require 'rdkafka'
require 'eventmachine'

# Kafka consumer config
KAFKA_CONFIG = {
  :"bootstrap.servers" => "localhost:9092",
  :"group.id" => "lineoa-broker",
  :"auto.offset.reset" => "latest"
}
LOG_TOPIC = "sys.logs"
INBOUND_TOPIC = "line.message.inbound"
OUTBOUND_TOPIC = "line.message.outbound"
FORWARD_TOPIC = "line.message.forward"


# Start Kafka consumer in existing EM loop (used by Thin)
configure do
  Thread.new do
    sleep 1 # let Thin/EM boot completely
    puts 'start'
    EM.next_tick do
      kafka = Rdkafka::Config.new(KAFKA_CONFIG)

      inbound_consumer = kafka.consumer
      inbound_consumer.subscribe(INBOUND_TOPIC)

      EM.defer do
        begin
          inbound_consumer.each do |message|

            puts "[Kafka] Received: #{message.payload} (offset #{message.offset})"

            # Parse the message payload as JSON
            payload = JSON.parse(message.payload)


            url = URI(payload['url'])

            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true #if uri.instance_of? URI::HTTPS
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            http.read_timeout = 10 # seconds
          
            request = Net::HTTP::Post.new(url, {'x-api-key'=>'','Content-Type' =>'application/json'})

            request.body = payload['body'].to_json
 
            response = http.request(request)

            puts "Response: #{response.body}"


          end
        rescue => e
          puts "Kafka error: #{e.message}"
        end
      end

      outbound_consumer = kafka.consumer
      outbound_consumer.subscribe(OUTBOUND_TOPIC)

      EM.defer do
        begin
          outbound_consumer.each do |message|
            puts "[Kafka] Received: #{message.payload} (offset #{message.offset})"
          end
        rescue => e
          puts "Kafka error: #{e.message}"
        end
      end

      forward_consumer = kafka.consumer
      forward_consumer.subscribe(FORWARD_TOPIC)

      EM.defer do
        begin
            forward_consumer.each do |message|
            puts "[Kafka] Received: #{message.payload} (offset #{message.offset})"
          end
        rescue => e
          puts "Kafka error: #{e.message}"
        end
      end

      log_consumer = kafka.consumer
      log_consumer.subscribe(LOG_TOPIC)
      puts LOG_TOPIC

      EM.defer do
        begin
            log_consumer.each do |message|
            puts "[Kafka] Received: #{message.payload} (offset #{message.offset})"
          end
        rescue => e
          puts "Kafka error: #{e.message}"
        end
      end

    end
  end
end

set :port, 4556

# Sinatra route
get '/' do
  "Kafka consumer running inside EM loop. Sinatra is responding!"
end
