require 'socket'
require 'serialport'



serial = SerialPort.new("/dev/ttyUSB1", 115200, 8, 1, SerialPort::NONE)


while true
  
  
   raw = serial.readline("\r")
   
   puts raw.inspect 
   
   sleep(1000)
 end