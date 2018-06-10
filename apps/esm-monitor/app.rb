
require 'net/http'
require_relative '../../services/monitor/conf'


register_app 'monitor', 'esm-monitor'

module EsmMonitor

class User
  include MongoMapper::Document
  
  key :login, String
  key :salt,  String
  key :hashed_password,  String
  key :last_login, DateTime
  key :role, ObjectId
  key :email, String
  timestamps!
  
end

class Zone
  include MongoMapper::Document
  key :name, String
end

class Station
  include MongoMapper::Document
  belongs_to :zone, :class_name=>'EsmMonitor::Zone'
  key :name, String
  key :ip, String
  key :serial_number, String
  key :type, String
  key :zone_id, ObjectId
  
  def to_s
    self.name
    
  end
end

class Sense
  include MongoMapper::Document
  key :stamp, Time
  key :name, String
  key :station_id, ObjectId
  key :ip, String
  key :ref, String
  key :data,  String
end

class Patient
  include MongoMapper::Document
  key :hn, String 
  key :name, String 
  
  def to_s
    self.name
  end
end


class Admit
  include MongoMapper::Document
  belongs_to :station, :class_name=>'EsmMonitor::Station'
  belongs_to :patient, :class_name=>'EsmMonitor::Patient'
  has_many :records, :class_name=>'EsmMonitor::DataRecord'
  key :patient_id, ObjectId
  key :admit_stamp, Time
  key :discharge_stamp, Time
  key :status, String
  key :score, Integer
  key :note, String
  key :bed_no, String
  key :station_id, ObjectId
  
end
 
class DataRecord
  include MongoMapper::Document
  
  key :admit_id, ObjectId
  
  key :data, String
  
  key :bp_sys, Integer
  key :bp_dia, Integer
  key :pr, Integer
  key :so2, Integer
  key :rr, Integer
  key :temp, Float
  
  key :question_1, String
  key :question_2, String
  key :question_3, String
  key :question_4, String
  key :question_5, String
  key :question_5, String
  key :question_6, String
  key :stamp, Time
  
  key :status, String
  
  key :score, Integer
  
end








class HomeController < GXT

end
class ZoneController < GXTDocument
  
end

class StationController < GXTDocument
  
end


class PatientController < GXTDocument
  
end


class AdmitController < GXTDocument
  def data params
      admit=model.find params[:id]
header = ['date']

records = admit.records

header << "BPSYS(#{records[-1].bp_sys})"
header << "BPDIA(#{records[-1].bp_dia})"
header << "PR(#{records[-1].pr})"
header << "SO2(#{records[-1].so2})"
header << "Score"

      
# result = [%w{date BPSYS BPDIA PR SO2 Score}.join("\t")]      
result = [header.join("\t")]      

    
      
      records.each do |i|
      
      score = 0 
      
      6.times.each do |j|
          score += i["question_#{j+1}"].to_i if i["question_#{j+1}"]
      end
      
        
          result << [i.stamp.strftime("%H%M"), i.bp_sys, i.bp_dia, i.pr, i.so2, score].join("\t") if i.stamp
          
      end

      # 
      # result = <<DATA
      # date  BPSYS#{"\t"}BPDIA#{"\t"}PR
      # 0830  63.4  62.7  72.2
      # 0833  58.0  159.9 167.7
      # 0839  53.3  159.1 69.4
      # 0930  55.7  158.8 68.0
      # DATA
  
    return result.join("\n")

  end
end


class DataRecordController < GXTDocument

end

class SenseController < GXTDocument

  def sense params
    
      # user = User.create :name=>'Soup'

      # key :stamp, DateTime
      #   key :station_id, ObjectId
      #   key :ip, String
      #   key :ref, String
      #   key :data,  String
      # puts params

      stamp = Time.now
      stamp = params['stamp'] if params['stamp']

      ip = @context.request.ip
      ip = params['ip'] if params['ip']


      # station_name
      # 1. monitor ip
      # 2. bed index

      station_name = ip
      station_name = params['station'] if params['station'] 
      # puts "Name = #{params.inspect }"
      ref = "-"
      ref = params['ref'] if params['ref']

      data = "{}"
      data = params['data'] if params['data']
      
      
      puts data
      
      station_id = nil

      station = nil

      unless station = @context.settings.stations[station_name]

        station = Station.where(:name=>station_name).first

        unless station

        station = Station.create(:name=>station_name,:ip=>ip)

        end

        @context.settings.stations[station_name] = station

      end


      if station
          station_id = station['_id']
      end  

      data = JSON.parse(data)
      data['ref'] = ref
       # @context.settings.senses[station_name] = data

        old = @context.settings.senses[station_name]
        @context.settings.senses[station_name] = data
        @context.settings.live[station_name] = 10
        
       # send to gw his
                  if false and data['bp']!= "-/-"
                  
                       bp_stamp = data['bp_stamp']
                       old_bp_stamp = old['bp_stamp'] 
                        # puts "$$$$$ #{data['bp_stamp']}  #{old['bp_stamp']}  "
                       if bp_stamp!=old_bp_stamp
                        his_host = GW_HIS_IP
                        his_port = GW_HIS_PORT
                  
                         urix = URI("http://#{his_host}:#{his_port}/his/test_send_anpacurec")
                         
                         # 4546/56 ok
                         # 03444456 ok
                         # 344456
                         
                         # 56003444
                         hn = data['ref']
                         
                         prefix = hn[0..5].to_i
                         
                         if hn.index('/')
                           
                           hn = "#{hn[-2..-1]}#{format("%06d",hn[0..hn.index('/')-1])}"
                           
                         elsif hn.size==8 and prefix < 300000
                           
                           hn = "#{hn[6..-1]}#{format("%06d",prefix)}"
                           
                         elsif hn.size<8 
                           
                           hn = "#{hn[-2..-1]}#{format("%06d",hn[0..-3].to_i)}"
                         end
                         
                        data['ref'] = hn 
                         
                  
                        begin
                         res = Net::HTTP.post_form(urix, :hn=>data['ref'], :bp=>data['bp'],:hr=>data['hr'], :bp_stamp=>data['bp_stamp'])
                        rescue Exception => e
                          
                          puts e.message
                          
                        end
                  
                       end
                  
                       end
         

       admit = Admit.where(:status=>'Admitted',:station_id=>station.id).first     
       if admit
         # {"hr":60,"rr":20,"so2":99,"pr":60,"bp":"122/71","bp_stamp":"215613"}
         bp = data['bp'].split("/")
         last = admit.records.last
          t = Time.strptime(data['bp_stamp'],"%H%M%S")
         
         if last and last.stamp
        
           time =  t.utc.strftime("%H%M%S")
           
           last_time = last.stamp.strftime("%H%M%S")
           
           puts "compare #{time} #{last_time}"
           
           if time!=last_time 
             
             DataRecord.create :admit_id=>admit.id, :bp_sys=>bp[0],  :bp_dia=>bp[1], :pr=>data['pr'],  :rr=>data['rr'], :so2=>data['so2'], :stamp =>t
             
           end
           
           
         else
           DataRecord.create :admit_id=>admit.id, :bp_sys=>bp[0],  :bp_dia=>bp[1], :pr=>data['pr'],  :rr=>data['rr'], :so2=>data['so2'], :stamp =>t
         end
       end     

      # records = Sense.collection.insert([{:station_id=>station_id, :name=>station_name,:stamp=>stamp,:ip=>ip,:ref=>ref,:data=>data}])
      
      
      # puts station_name
      #  puts app.settings.stations.inspect 
      #  puts Station.count



       "200 OK\nSense " + Sense.collection.count.to_s + "\nId "
    
    
  end

end

end

module Sinatra
 
  module SenseMonitor
    
  include EsmMonitor
    
def self.registered(app)
  
  
  # 
  #   
  # app.get '/monitor' do
  #   # user = User.create :name=>'Soup'
  #   # user = User.collection.insert([{:name=>'Soup'}])
  #   # erb 'Can you handle a <a href="/secure/place">secret</a>? '+User.collection.count.to_s
  #   
  #   
  #   if !request.websocket?
  #      # erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  # 
  #      erb :monitor
  #      
  #    else
  #       request.websocket do |ws|
  #         ws.onopen do
  #           # ws.send("Hello World!")
  #           app.settings.sockets << ws
  #         end
  #         ws.onmessage do |msg|
  #           puts msg
  #           # 10.times do |i|
  #           EM.next_tick { app.settings.sockets.each{|s| s.send(msg) } }
  #           # sleep(1)
  #           # end
  #         end
  #         ws.onclose do
  #           warn("websocket closed")
  #           app.settings.sockets.delete(ws)
  #         end
  #       end
  #     end
  #   
  # end
  
# before do
#   
#   if request.path =="/sense"
#     puts 'sidofjd'
#     switch 'monitor'
#       
#   end
#   
#   
# end





app.post "/sense" do 
    # user = User.create :name=>'Soup'
  
    # key :stamp, DateTime
    #   key :station_id, ObjectId
    #   key :ip, String
    #   key :ref, String
    #   key :data,  String
    # puts params

    stamp = Time.now
    stamp = params['stamp'] if params['stamp']

    ip = request.ip
    ip = params['ip'] if params['ip']


    # station_name
    # 1. monitor ip
    # 2. bed index

    station_name = ip
    station_name = params['station'] if params['station'] 
    # puts "Name = #{params.inspect }"
    ref = "-"
    ref = params['ref'] if params['ref']

    data = "{}"
    data = params['data'] if params['data']
    puts data.inspect 
    station_id = nil

    station = nil

    unless station = app.settings.stations[station_name]

      station = Station.where(:name=>station_name).first

      unless station

      station = Station.create(:name=>station_name)

      end

      app.settings.stations[station_name] = station

    end


    if station
        station_id = station['_id']
    end  

    data = JSON.parse(data)
    data['ref'] = ref
    old = app.settings.senses[station_name]
    app.settings.senses[station_name] = data
    
    
     "$$$$$ #{data['bp_stamp']}"
    if data['bp_stamp']
  
    bp_stamp = data['bp_stamp']
    old_bp_stamp = old['bp_stamp'] 
  
    if bp_stamp!=old_bp_stamp
      
      
      uri = URI("http://#{his_host}:#{his_port}/his/test_send_anpacurec")
      
      res = Net::HTTP.post_form(uri, :hn=>data['ref'], :bp=>data['bp'],:hr=>data['hr'], :bp_stamp=>data['bp_stamp'])
      
      
    end
    
    end



    records = Sense.collection.insert([{:station_id=>station_id, :name=>station_name,:stamp=>stamp,:ip=>ip,:ref=>ref,:data=>data}])
    # puts station_name
    #  puts app.settings.stations.inspect 
    #  puts Station.count
    
    

     "200 OK\nSense " + Sense.collection.count.to_s + "\nId "+records[0].inspect

  
end

$sum = 0

Thread.new do # trivial example work thread
  while true do
     sleep 1
    
     if Sense.count > 500
       
       Sense.sort(:created_at).limit(400).destroy_all
       
     end
     EM.next_tick { 
        # puts   app.settings.live.inspect 
         app.settings.live.keys.each do |k|
            app.settings.live[k] -=1
            if app.settings.live[k]<0
              
              app.settings.live.delete k
              app.settings.stations.delete k
              app.settings.senses.delete k
            end
         end
       
     begin
       if  app.settings.apps_ws[app.settings.name]
       app.settings.apps_ws[app.settings.name].each{|s|  s.send({:time=>Time.now, :list=>app.settings.stations.keys.sort,:data=>app.settings.senses}.to_json) } 
      end
       # app.settings.sockets.each{|s| s.send({:time=>Time.now, :list=>app.settings.stations.keys.sort,:data=>app.settings.senses}.to_json) } 
    rescue Exception=>e
      
      puts e.inspect 
      
      end   
       
       }
  end
end

end


end


  
  register SenseMonitor
end



