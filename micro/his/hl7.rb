

require 'simple_hl7'
require 'socket'
# hl7_str = "RCP|I|100^RDQuery|Q0016|@PID.3.1^9538359|HOSPITAL|20190713093310.707+0700||QBP^Q22^QBP_Q21|1970242928-00000016|P|2.5"
# 
# # hl7_str = "MSH|^~\\&|||||||ADT^A04|12345678|D|2.5\rPID|||454545||Doe^John"
# msg = SimpleHL7::Message.parse(hl7_str)
# puts msg.inspect
# 
# puts msg.pid[3]



msg = SimpleHL7::Message.new
msg.msh[9][1] = "ADT"
msg.msh[9][2] = "A04"
msg.msh[10] = "12345678"
msg.msh[11] = "D"
msg.msh[12] = "2.5"

msg.pid[3] = "454545"
msg.pid[5][1] = "Doe"
msg.pid[5][2] = "John"

msg.pv1[2] = "O"

puts msg.to_hl7
puts msg.to_llp
# socket = TCPSocket.open('192.168.1.11' , 6661)
socket = TCPSocket.open('172.20.10.121' , 6661)

socket.write msg.to_llp
socket.close

