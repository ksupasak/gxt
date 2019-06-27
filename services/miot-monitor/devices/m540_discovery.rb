require 'socket'
require 'net/http'
require 'json'
require "ipaddr"


 puts 'Start Sent Data'
 
 M540_MULTICAST_ADDR = "224.0.1.11"  # to receive data

 M540_BIND_ADDR_LOCAL = "10.50.0.5"
 

 M540_PORT = 2050

socket = UDPSocket.new

membership = IPAddr.new(M540_MULTICAST_ADDR).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton


 M540_DIS_MULTICAST_ADDR = "224.127.1.254"
 M540_DIS_PORT = 2000

 membership = IPAddr.new(M540_DIS_MULTICAST_ADDR).hton + IPAddr.new(M540_BIND_ADDR_LOCAL).hton


puts 'Start Sent Data'
socket.setsockopt(:IPPROTO_IP, :IP_ADD_MEMBERSHIP, membership)


# open port
socket.bind('0.0.0.0', M540_DIS_PORT)


# host = GW_IP
# port = GW_PORT
# uri = GW_URI


puts 'Start Receive Data'

tmp = []
stmp = {}
sk = {}

lbuff = {}

vs =  {}

response = true


while true do

  begin

    message, info = socket.recvfrom(4096)
    l = message.each_byte.to_a.collect{|i| i.to_i}  
    puts info.inspect
    

  rescue
    
  end
  
end