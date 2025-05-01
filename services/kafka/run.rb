require 'sinatra'
require 'rdkafka'
require 'eventmachine'

# Kafka consumer config
KAFKA_CONFIG = {
  :"bootstrap.servers" => "localhost:9092",
  :"group.id" => "sinatra-consumer",
  :"auto.offset.reset" => "latest"
}

TOPIC = "test-topic"

# Start Kafka consumer in existing EM loop (used by Thin)
configure do
  Thread.new do
    sleep 1 # let Thin/EM boot completely
    EM.next_tick do
      kafka = Rdkafka::Config.new(KAFKA_CONFIG)
      consumer = kafka.consumer
      consumer.subscribe(TOPIC)

      EM.defer do
        begin
          consumer.each do |message|
            puts "[Kafka] Received: #{message.payload} (offset #{message.offset})"
          end
        rescue => e
          puts "Kafka error: #{e.message}"
        end
      end
    end
  end
end

# Sinatra route
get '/' do
  "Kafka consumer running inside EM loop. Sinatra is responding!"
end