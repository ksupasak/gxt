
module EsmMiotMonitor

class User
  include MongoMapper::Document
  belongs_to :role, :class_name=>'EsmMiotMonitor::Role'
  
  key :login, String
  key :salt,  String
  key :hashed_password,  String
  key :last_login, DateTime
  key :role_id, ObjectId
  key :email, String
  timestamps!
end

class Role
  include MongoMapper::Document
  key :name, String
 
  timestamps!
end
class Provider
  include MongoMapper::Document
   key :name, String
  
end

class Procedure
  include MongoMapper::Document
   key :name, String
  
end

class Diagnosis
  include MongoMapper::Document
   key :name, String
  
end


class Zone
  include MongoMapper::Document
  has_many :admits, :class_name=>'EsmMiotMonitor::Admit'
  has_many :stations, :class_name=>'EsmMiotMonitor::Station'
  has_many :ambulances, :class_name=>'EsmMiotMonitor::Ambulance'
  
  key :name, String 
  key :mode, String 
  
end



class Station
  include MongoMapper::Document
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'
  has_many :admits, :class_name=>'EsmMiotMonitor::Admit'
  
  key :name, String # bed name
  key :title, String
  key :serial_number, String
  key :type, String
  key :ip, String
  key :zone_id, ObjectId  
  def to_s
    self.name
  end
end


class Sense
  include MongoMapper::Document
  
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  belongs_to :station, :class_name=>'EsmMiotMonitor::Admit'
  
  key :admit_id, ObjectId
  key :station_id, ObjectId
  key :data,  String
  
  key :start_time, Time
  key :stop_time, Time
    
  key :tag, String
  
  key :note, String
  
end


class Admit
  include MongoMapper::Document
  
  belongs_to :station, :class_name=>'EsmMiotMonitor::Station'
  belongs_to :patient, :class_name=>'EsmMiotMonitor::Patient'
  belongs_to :score, :class_name=>'EsmMiotMonitor::Score'
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'
  
  has_many :records, :class_name=>'EsmMiotMonitor::DataRecord'
  
  has_many :nurse_records, :class_name=>'EsmMiotMonitor::NurseRecord'
  has_many :medication_records, :class_name=>'EsmMiotMonitor::MedicationRecord'
  
  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  belongs_to :procedure, :class_name=>'EsmMiotMonitor::Procedure'
  belongs_to :diagnosis, :class_name=>'EsmMiotMonitor::Diagnosis'
  
  belongs_to :ambulance, :class_name=>'EsmMiotMonitor::Ambulance'
  
  
  key :patient_id, ObjectId
  key :station_id, ObjectId
  key :score_id, ObjectId
  key :zone_id, ObjectId
  
  key :provider_id, ObjectId
  key :procedure_id, ObjectId
  key :diagnosis_id, ObjectId
  
  key :ambulance_id, ObjectId
  
  key :admit_stamp, Time
  key :discharge_stamp, Time
  
  key :status, String
  
  
  key :current_score, Integer
  
  key :note, String
  
  key :bed_no, String
 timestamps!
  
  def discharge
    self.discharge_stamp = Time.now
    self.status='Discharged'
    self.save
  end
end

class AdmitLog
  include MongoMapper::Document
  
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  key :admit_id, ObjectId
  key :name, String
  key :status, String
  key :latlng, String
  key :note, String
  key :stamp, Time
  key :sort_order, Integer
  key :parent, Integer
  timestamps!
end


class NurseRecord
  
  include MongoMapper::Document
  
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  key :name,  String
  
  key :description, String
  
  key :admit_id, ObjectId
  
  key :start_time, Time
  key :stop_time, Time
  
  key :status, String
  
  key :note, String
  
  key :tag, String
  
end

class Medication
  include MongoMapper::Document
  
  key :name,  String
  key :concentration, String
  
    
end

class MedicationRecord
  include MongoMapper::Document
  
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  belongs_to :medication, :class_name=>'EsmMiotMonitor::Medication'
  
  key :name,  String
  
  key :admit_id, ObjectId
  key :medication_id, ObjectId
  
  key :start_time, Time
  key :stop_time, Time
  
  key :status, String
  
  key :rate, Float
  key :concentration, String # second
  key :volume, Float
  
  key :est_intake, Float
  key :actual_intake, Float
  
  key :note, String
  
  key :tag, String
  
  
  
end

class Patient
  include MongoMapper::Document
  has_many :admits, :class_name=>'EsmMiotMonitor::Admit'
  
  key :hn, String 
  key :name, String 
  key :public_id, String
  key :prefix_name, String 
  key :first_name, String 
  key :last_name, String 
  key :dob, Time 
  key :age, String
  key :gender, String
  key :contact_name, String 
  key :contact_phone, String
  def to_s
    "#{self.prefix_name}#{self.first_name} #{self.last_name}"
  end
end





class Score
  include MongoMapper::Document
  
  has_many :items, :class_name=>'EsmMiotMonitor::ScoreItem'
  
  key :name, String
  key :version, String
  key :description, String
  def to_s
      self.name
    end
end

class ScoreItem
  include MongoMapper::Document
  
  belongs_to :score, :class_name=>'EsmMiotMonitor::Score'
  has_many :conditions, :class_name=>'EsmMiotMonitor::ScoreCondition'
  
  
  key :name, String # key value
  key :title, String # key value
  
  key :sort_order, Integer
  key :score_id, ObjectId
  
end

class ScoreCondition
  include MongoMapper::Document
  
  belongs_to :score_item, :class_name=>'EsmMiotMonitor::ScoreItem'
  
  key :sort_order, Integer
  
  key :score_item_id, ObjectId
  
  key :min, Float # key value
  key :max, Float # key value
  
  key :option, String # key value
  
  key :score, Integer # key value
  
  key :alert_msg, String
  key :alert_tag, String
  
end






class Device
  include MongoMapper::Document
  belongs_to :station, :class_name=>'EsmMiotMonitor::Station'
  key :name, String
  key :ip, String
  key :serial_number, String
  key :type, String
  def to_s
    self.name
  end
end


class Ambulance
  include MongoMapper::Document
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'
  has_one :driver, :class_name=>'EsmMiotMonitor::AmbulanceDriver'
  has_one :admit, :class_name=>'EsmMiotMonitor::Admit'
  belongs_to :station, :class_name=>'EsmMiotMonitor::Station'
  
  
  key :status, String
  key :name, String
  key :plate_license, String
  key :phone, String
  key :station_id, ObjectId
  key :driver_id, ObjectId
  key :zone_id, ObjectId
  key :last_location, String
  key :last_address, String
  key :device_no, String

  
end

class AmbulanceDriver
  include MongoMapper::Document
  key :name, String
  key :mobile, String
  key :phone, String
  key :address, String
  key :public_id, String
  key :user_id, ObjectId
end



class Setting
  include MongoMapper::Document
  key :name, String
  key :value, String
  
  def self.get name, default=nil
      record = self.where(:name=>name).first
      unless record
        record = self.create :name=>name, :value=>default
      end
      return record.value
  end
end




class DataRecord
  include MongoMapper::Document
  
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  key :admit_id, ObjectId
  
  key :data, String
  key :bp, String
  key :bp_sys, Integer
  key :bp_dia, Integer
  key :pr, Integer
  key :hr, Integer
  key :spo2, Integer
  key :rr, Integer
  key :temp, Float
  
  key :stamp, Time
  
  key :status, String
  
  key :score, Integer
  timestamps!
end








class HomeController < GXT

end


class UserController < GXTDocument

end


class RoleController < GXTDocument

end


class ZoneController < GXTDocument
  
end

class ProviderController < GXTDocument
  
end

class DiagnosisController < GXTDocument
  
end

class ProcedureController < GXTDocument
  
end


class MedicationController < GXTDocument
  
end

class StationController < GXTDocument
  
end

class ScoreController < GXTDocument
  
end

class ScoreItemController < GXTDocument
  
end


class NurseRecordController < GXTDocument
  
end

class MedicationController < GXTDocument
  
end


class MedicationRecordController < GXTDocument
  
end

class ScoreConditionController < GXTDocument
  
end

class DeviceController < GXTDocument
  
end

class PatientController < GXTDocument
  
end


class AmbulanceController < GXTDocument
  
end

class AmbulanceDriverController < GXTDocument
  
end

class SettingController < GXTDocument
  
end

class AdmitLogController < GXTDocument
end

  
class AdmitController < GXTDocument
  
  def submit_data params
    
       admit = model.find params[:id]
      
       if admit
         
          admit.update_attributes :current_score=>params[:data][:score]
          
          if params[:option]
          
          params[:option].each_pair do |k,v|
            
            params[:data]["#{k}_opt".to_sym] = v
            
          end
        end
         
          record = admit.records.create params[:data]
          
          record.update_attributes :data=>params[:data].to_json, :stamp=>Time.now
          
          if params[:score_id]
            score = Score.find params[:score_id]
          else
            score = admit.score
          end
          
          admit.nurse_records.create :start_time=> Time.now , :description=>"#{score.name} v.#{score.version} = #{params[:data][:score]} : #{score.description}"
          
         
       end
       
    
     @context.redirect  "#{settings.name}/Admit/show?id=#{admit.id}"
  end
  
  
  def data params
      admit=model.find params[:id]
      
header = ['date']

records = admit.records
# 
header << "BPSYS(#{records[-1].bp_sys})"
header << "BPDIA(#{records[-1].bp_dia})"
header << "PR(#{records[-1].pr})"
header << "SPO2(#{records[-1].spo2})"
header << "Score"

      
# result = [%w{date BPSYS BPDIA PR SO2 Score}.join("\t")]      
result = [header.join("\t")]      

    
      
      records.each do |i|
      
      score = 0 
      
      6.times.each do |j|
          score += i["question_#{j+1}"].to_i if i["question_#{j+1}"]
      end
      
        
          result << [i.stamp.strftime("%H%M"), i.bp_sys, i.bp_dia, i.pr, i.spo2, score].join("\t") if i.stamp
          
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
             
             DataRecord.create :admit_id=>admit.id, :bp_sys=>bp[0],  :bp_dia=>bp[1], :pr=>data['pr'],  :rr=>data['rr'], :spo2=>data['spo2'], :stamp =>t
             
           end
           
           
         else
           DataRecord.create :admit_id=>admit.id, :bp_sys=>bp[0],  :bp_dia=>bp[1], :pr=>data['pr'],  :rr=>data['rr'], :spo2=>data['spo2'], :stamp =>t
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