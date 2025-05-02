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

def start_inbound_consumer
  Thread.new do
    kafka = Rdkafka::Config.new(KAFKA_CONFIG)
    consumer = kafka.consumer
    consumer.subscribe(INBOUND_TOPIC)

    begin
      consumer.each do |message|
        puts "[Kafka] Received INBOUND: #{message.payload} (offset #{message.offset})"
        
        # Parse the message payload as JSON
        payload = JSON.parse(message.payload)
        
        url = URI(payload['url'])
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 10
        
        request = Net::HTTP::Post.new(url, {'x-api-key'=>'','Content-Type' =>'application/json'})
        request.body = payload['body'].to_json
        response = http.request(request)
        
        puts "Response: #{response.body}"
      end
    rescue => e
      puts "Kafka INBOUND error: #{e.message}"
      retry
    end
  end
end

def start_outbound_consumer
  Thread.new do
    kafka = Rdkafka::Config.new(KAFKA_CONFIG)
    consumer = kafka.consumer
    consumer.subscribe(OUTBOUND_TOPIC)

    begin
      consumer.each do |message|
        puts "[Kafka] Received OUTBOUND: #{message.payload} (offset #{message.offset})"
      end
    rescue => e
      puts "Kafka OUTBOUND error: #{e.message}"
      retry
    end
  end
end

def start_forward_consumer
  Thread.new do
    kafka = Rdkafka::Config.new(KAFKA_CONFIG)
    consumer = kafka.consumer
    consumer.subscribe(FORWARD_TOPIC)

    begin
      consumer.each do |message|
        puts "[Kafka] Received FORWARD: #{message.payload} (offset #{message.offset})"
      end
    rescue => e
      puts "Kafka FORWARD error: #{e.message}"
      retry
    end
  end
end

def start_log_consumer
  Thread.new do
    kafka = Rdkafka::Config.new(KAFKA_CONFIG)
    consumer = kafka.consumer
    consumer.subscribe(LOG_TOPIC)

    begin
      consumer.each do |message|
        puts "[Kafka] Received LOG: #{message.payload} (offset #{message.offset})"
      end
    rescue => e
      puts "Kafka LOG error: #{e.message}"
      retry
    end
  end
end

# Start Kafka consumers
configure do
  Thread.new do
    sleep 1 # let Thin/EM boot completely
    EM.next_tick do
      # Start all consumers in separate threads
      start_inbound_consumer
      start_outbound_consumer
      start_forward_consumer
      start_log_consumer
    end
  end
end

set :port, 4556

# Sinatra route
get '/' do
  "Kafka consumers running in separate threads. Sinatra is responding!"
end
