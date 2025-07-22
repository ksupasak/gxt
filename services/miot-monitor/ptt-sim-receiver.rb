
require 'base64'
require_relative 'gateway'

ws = MIOT::connect




 ws.on :open do
puts 'open'
   msg = <<MSG
WS.Select name=PTT
["PTT PTT/miot/z/0"]
MSG
 ws.send(msg)


 end

  ws.on :message do |msg|

    # js =  msg.data.split("\n")

    puts "#{Time.now} #{msg.data.size}" 


  end


  loop do
    ws.send STDIN.gets.strip
  end


#
# while(true)
#
# puts 'Send'
#
# path = File.join("test", "ptt-sample.mp3")
# content = File.open(path).read
# encoded = Base64.encode64(content)
#
#   msg = <<MSG
# PTT.Send channel=0
# #{{:sender=>'Soup', :channel=>'0',:type=>'audio', :message=>'Hello world', :file=>encoded}.to_json}
# MSG
#
#    ws.send(msg)
#
#   sleep(2)
#
#
#
# end
