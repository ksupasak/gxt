require 'websocket-client-simple'
require 'eventmachine'
require "active_support"
require "active_support/core_ext/date/calculations"
require 'json'
require 'base64'

module GXTWS

def self.connect solution, host
  connect_url = "wss://#{host}/ws/#{solution}/Home/index"
  puts connect_url
  WebSocket::Client::Simple.connect connect_url
end


def self.bind_event ws

ws.on :message do |msg|
  puts msg.data
  lines = msg.data.split("\n")
  if lines[0]=='print'
    open("| lpr", "w") { |f| f.puts lines[1..-1] }
  end

end

ws.on :open do
  ws.send 'hello!!!'
end

ws.on :close do |e|
  p e
  exit 1
end

ws.on :error do |e|d
  p "ERROR #{e}"
   puts 'will retry connect ..'
   sleep 1
   puts 'retry connect ..'
   ws = connect()
   bind_event ws
   puts 'retry connect ..'
end

end

def self.send_image ws, v, file_path
  
  file = File.open(file_path).read
  enc = Base64.encode64(file)
  
  sdata = {}
  
  sdata["note"] =  "TwelveLeads";
  sdata["ts"] = Time.now.to_i/1000;
  sdata["type"] = "image";
  sdata["file_name"] =  file_path;
  sdata["image"] =  enc ;
  stamp = Time.now
  ref = "-"
  name = v['TempusSerialNumber']
  
  msg = <<MSG
IMG.Send sender_id=corsim receiver_id=#{name}
#{{'station'=>name, 'receiver'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>sdata}.to_json}
MSG
                   puts msg
                   # puts "send #{Time.now} #{msg}"
        ws.send(msg)
  
  
end



def self.send ws, v, data, mark_dup
  
       
  puts data.to_json
  
          if data['VitalDetailsInfo'].size > 0 
            
           
            name = v['TempusSerialNumber']
            # ref = v['PatientId'].split(' ').join("-")
            ref = "-"

            sdata = {}
            
            mdata = {}
            
            
             for line in data['VitalDetailsInfo']
               
               now =  line['DataCaptureTimeUtc']
               
               rid = "#{name}_#{now.to_s}"
               
               mark_dup[name] = {} unless mark_dup[name]
               
               unless mark_dup[name][rid]
                 
               mark_dup[name][rid] = now   
               
               stamp = now#.to_json
               
               for l in line['Vitals']
               
                 mdata[l['Name']] = l
               
               end
               
               # %w{pr:HR hr:HR spo2:SpO2 rr:Resp temp:T1 temp2:T2 pi:PI pvi:PVI co2:ETCO2 bp_sys:Sys bp_dia:Dia bp_mean:Mean bp_sys:SysNIBP bp_dia:DiaNIBP bp_mean:MeanNIBP  }
               
               for x in   %w{pr:HR hr:HR spo2:SpO2 rr:Resp temp:T1 temp2:T2 pi:PI pvi:PVI co2:ETCO2 bp_sys:Sys bp_dia:Dia bp_mean:Mean bp_sys:SysNIBP bp_dia:DiaNIBP bp_mean:MeanNIBP  }
           
                 t = x.split(":")
                
                 sk = t[0].to_sym
                 mk = t[1]
                
                 if y = mdata[mk] and !(y['Value'].index('Out'))
                  
                   sdata[sk] = y['Value']
                  
                 end
                
               end  

               if sdata[:bp_sys]
              
                   sdata[:bp] = "#{sdata[:bp_sys]}/#{sdata[:bp_dia]}" 
                   data[:bp_stamp] = Time.now.strftime("%H%M%S")
              
                end
            
                puts sdata.inspect 
            
               msg = <<MSG
Data.Sensing device_id=#{name}
#{{'station'=>name, 'receiver'=>name, 'stamp' => stamp, 'ref' => ref, 'data'=>sdata}.to_json}
MSG
                   # puts msg
                   # puts "send #{Time.now} #{msg}"
                ws.send(msg)
  
                puts msg
               
               
              end
               
     
             end
             
              



             end

end



end