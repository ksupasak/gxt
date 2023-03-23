require 'net/http'
require 'json'
require 'websocket-client-simple'
require 'eventmachine'
# require 'em-http-server'





require_relative 'lib'
require_relative 'conf'




unless HOST_IP
HOST_IP = IPSocket.getaddress(Socket.gethostname)
end

t = HOST_IP.split('.')
HOST_NETWORK = t[0..2].join(".")+".1"

unless ARGV[3]
HOST_NETWORK_BOARDCAST = t[0..2].join(".")+".255"
else
HOST_NETWORK_BOARDCAST = ARGV[3]
end

select_monitor = ARGV[2]


CMS_URI = URI("https://#{CMS_IP}:#{CMS_PORT}/#{CMS_PATH}")
MIOT::post_config

$global_position = ""

threads = []
puts ARGV.inspect 
