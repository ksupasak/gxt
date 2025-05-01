require 'rdkafka'
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


module GXTKafka

def self.producer

    kafka = Rdkafka::Config.new(KAFKA_CONFIG)
    producer = kafka.producer

    return producer
end



end
