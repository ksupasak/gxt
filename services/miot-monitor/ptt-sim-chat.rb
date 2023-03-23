
require 'base64'
require_relative 'gateway'

ws = MIOT::connect

# while(true)
#
# puts 'Send '+Time.now.to_s
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
#   sleep(1)
#
#
#
# end



loop do
  text =  STDIN.gets.strip

  msg = <<MSG
PTT.Send channel=0
#{{:sender=>'Soup', :channel=>'0',:type=>'audio', :message=>text, :file=>""}.to_json}
MSG
  ws.send(msg)

end
