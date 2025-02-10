
require_relative 'models/er_models'
require_relative 'models/health_models'
require_relative 'models/aoc_models'
require_relative 'models/ems_models'
require_relative 'models/emr_models'


module EsmMiotMonitor


require 'digest/sha1'
class User < GXTModel

  include Mongoid::Document

  belongs_to :role, :class_name=>'EsmMiotMonitor::Role'
  key :login, String
  key :name, String
  key :salt,  String
  key :passcode, String
  key :pattern, String
  key :mobile, String
  key :email , String
  key :hashed_password,  String
  key :last_accessed, DateTime
  key :picture_id, ObjectId
  key :role_id, ObjectId
  key :status, String
  key :verify_2fa, Boolean
  key :verify_2fa_at, DateTime
  
  key :password_updated_at, DateTime
  
  

  key :email, String
   include Mongoid::Timestamps
  timestamps!

  def self.authenticate(login, pass)
    u=  self.where(:login=>login).first()
    return nil if u.nil?
    if User.encrypt(pass, u.salt)==u.hashed_password
      u.last_accessed = Time.now
      u.save
      return u
    end
    nil
  end

  def password=(pass)
    @password=pass
    self.salt = User.random_string(10) if !self.salt?
    self.hashed_password = User.encrypt(@password, self.salt)
    self.password_updated_at = Time.now
  end

  def login_perform
    self.last_accessed = Time.now
    self.save
    UserLog.create :user_id=>self.id, :action=>"Login"
    self
  end

  def self.random_string(len)
    #generat a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(len) { |i| newpass << chars[rand(chars.size-1)] }
    return newpass
  end

  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass+salt)
  end

  def get_name

    name = self.login
    name = self.name if self.name and self.name.size>0

    return name
  end


end

class UserLog <  GXTModel
    include Mongoid::Document
  
    key :user_id, ObjectId
    key :log, String
    key :action, String
    key :note, String 
    key :link, String
    
    include Mongoid::Timestamps
    timestamps!
end


class Role < GXTModel
  include Mongoid::Document

  key :name, String
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'

  key :zone_id, ObjectId
  
  key :idle_time_limit, Integer
  key :password_expiration_days, Integer

  include Mongoid::Timestamps
  timestamps!
end

# class UserZone < GXTModel
#
#   include Mongoid::Document
#
#   key :name, String
#   key :default, Stri
#   key :user_id, ObjectId
#   key :zone_id, ObjectId
#
#
# end

class Provider < GXTModel
  include Mongoid::Document
  include Mongoid::Timestamps
  
  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId
  
   key :name, String
   key :first_name, String
   key :last_name, String
   key :prefix_name, String
   key :shot, String
   key :department, String
   key :phone, String
   key :email, String
   key :license, String
   key :user_id, ObjectId
   key :line_account_id, ObjectId
   key :code, String
   key :role, String
   key :zone_id, String
   key :short, String
   
 
   def get_name
     
     return self.name if self.name and self.name  !=""
     return "#{first_name} #{last_name}" 
     
     
   end


end




class Attachment < GXTModel
  include Mongoid::Document

    key :path, String
    key :filename, String
    key :content_type, String
    key :file_id, ObjectId
    key :ref_id, ObjectId
    key :type, String
    key :note, String

    def self.store solution_name, filename, file, content_type, type = nil



          name = solution_name

          content = file.read

          connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override

          grid = Mongo::Grid::FSBucket.new(connection.database)

          fid = grid.upload_from_stream(filename,content)



          type = content_type.split("/")[0] unless type


          att = create :filename=>filename, :content_type=>content_type, :file_id=>fid, :type=>type

          path = "/#{name}/Attachment/content?id=#{att.id}"

          att.update_attributes :path => path


          return att

    end



    include Mongoid::Timestamps
end


class Procedure < GXTModel
  include Mongoid::Document

   key :name, String
    include Mongoid::Timestamps
end

class Diagnosis < GXTModel
  include Mongoid::Document

   key :name, String
    include Mongoid::Timestamps
end


class Zone < GXTModel
  include Mongoid::Document

  has_many :admits, :class_name=>'EsmMiotMonitor::Admit'
  has_many :stations, :class_name=>'EsmMiotMonitor::Station'
  has_many :ambulances, :class_name=>'EsmMiotMonitor::Ambulance'
  has_many :rooms, :class_name=>'EsmMiotMonitor::Room'


  key :name, String
  key :mode, String
  key :default, Boolean


    include Mongoid::Timestamps
end

class Room < GXTModel
  include Mongoid::Document
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'
  has_many :beds, :class_name=>'EsmMiotMonitor::Bed'

  key :name, String
  key :zone_id, ObjectId

end

class Bed < GXTModel
  include Mongoid::Document

  belongs_to :room, :class_name=>'EsmMiotMonitor::Room'

  key :name, String
  key :room_id, ObjectId
end


class AddressBook < GXTModel
  include Mongoid::Document


  key :name, String
  key :contact_name, String
  key :address, String
  key :phone, String
  key :latlng, String

  include Mongoid::Timestamps


end


class Station < GXTModel
  include Mongoid::Document

  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'
  has_many :admits, :class_name=>'EsmMiotMonitor::Admit'

  key :name, String # bed name
  key :title, String
  key :serial_number, String
  key :type, String
  key :ip, String
  key :zone_id, ObjectId
  key :stream_url, ObjectId
  include Mongoid::Timestamps
  def to_s

    res = self.name.split("_")[1..-1].join("_")
    res = self.title if self.title and self.title!=""

    return res
  end
end


class Message < GXTModel

  include Mongoid::Document


  belongs_to :station, :class_name=>'EsmMiotMonitor::Station'
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'

  key :sender, String # bed name
  key :recipient, String
  key :recipient_type, String
  key :uuid, String
  key :ts, Integer
  key :type, String
  key :media_type, String
  key :content, String
  key :file_id, ObjectId
  key :sender_user_id, ObjectId

  key :channel_id, ObjectId
  key :export, String 

  include Mongoid::Timestamps
end


class Sense < GXTModel
  include Mongoid::Document


  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  belongs_to :station, :class_name=>'EsmMiotMonitor::Admit'

  key :admit_id, ObjectId
  key :station_id, ObjectId

  key :data,  String

  key :start_time, Time
  key :stop_time, Time

  key :bp, String
  key :bp_stamp, String
  key :bp_sys, Integer
  key :bp_dia, Integer
  key :bp_mean, Integer
  key :bp_pr, Integer

  key :pr, Integer
  key :hr, Integer
  key :spo2, Integer
  key :rr, Integer
  key :temp, Float
  key :co2, Integer

  key :lat, String
  key :lng, String

  key :dvr_sp, Float
  key :dvr_hx, Integer
  key :dvr_ol, Integer

  key :msg, String

  key :stamp, Time

  key :vs, String



  include Mongoid::Timestamps
end


class Admit < GXTModel
  include Mongoid::Document


  belongs_to :station, :class_name=>'EsmMiotMonitor::Station'
  belongs_to :patient, :class_name=>'EsmMiotMonitor::Patient'
  belongs_to :score, :class_name=>'EsmMiotMonitor::Score'
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone'

  has_many :records, :class_name=>'EsmMiotMonitor::DataRecord', order: "start_time"
  has_many :nurse_records, :class_name=>'EsmMiotMonitor::NurseRecord', order: "start_time"
  has_many :medication_records, :class_name=>'EsmMiotMonitor::MedicationRecord', order: "start_time"

  has_many :logs, :class_name=>'EsmMiotMonitor::AdmitLog', order: "sort_order"
  has_many :messages, :class_name=>'EsmMiotMonitor::Message', order: "ts"


  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  belongs_to :procedure, :class_name=>'EsmMiotMonitor::Procedure'
  belongs_to :diagnosis, :class_name=>'EsmMiotMonitor::Diagnosis'
  belongs_to :ambulance, :class_name=>'EsmMiotMonitor::Ambulance'

  has_one :case_report, :class_name=>'EsmMiotMonitor::CaseReport'


  belongs_to :bed, :class_name=>'EsmMiotMonitor::Bed'
  belongs_to :room, :class_name=>'EsmMiotMonitor::Bed'


  key :patient_id, ObjectId
  key :station_id, ObjectId
  key :score_id, ObjectId
  key :zone_id, ObjectId

  belongs_to :created_user, :class_name=>'EsmMiotMonitor::User'
  belongs_to :updated_user, :class_name=>'EsmMiotMonitor::User'
  
  
  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId

  key :created_user_id, ObjectId
  key :updated_user_id, ObjectId


  key :provider_id, ObjectId
  key :provider_2_id, ObjectId


  key :procedure_id, ObjectId
  key :diagnosis_id, ObjectId

  key :ambulance_id, ObjectId
  key :room_id, ObjectId
  key :bed_id, ObjectId

  key :period, Integer

  key :admit_stamp, Time
  key :discharge_stamp, Time

  key :weight, Float
  key :height, Float
  key :bmi, Float

  key :glucose, Integer

  key :status, String

  key :an, String

  key :current_score, Integer

  key :note, String
  key :case_no, String
  key :room_no, String
  key :bed_no, String

  key :export_status, String
  key :export_log, String

  key :video_status, String
  
  key :record_status, String


   include Mongoid::Timestamps
 timestamps!

  def duration to_time = Time.now



    to_time = self.discharge_stamp if self.discharge_stamp


		total = ((to_time - self.admit_stamp)/60).to_i

		mins = total%60
		hours = total/60
    days = hours/24



    text = "#{hours} Hr #{mins} Min"

    text = "#{mins} Min" if hours == 0

    text = "#{days} D #{hours} Hr" if days>0

    return ["#{hours} Hr #{mins} Min",hours,mins]

  end

  def discharge
    self.discharge_stamp = Time.now
    self.status='Discharged'
    self.save
  end
end

class AdmitLog  < GXTModel
  include Mongoid::Document


  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  belongs_to :addressbook, :class_name=>'EsmMiotMonitor::AddressBook'

  key :admit_id, ObjectId
  key :addressbook_id, ObjectId
  key :ems_command_id, ObjectId
  key :type, String
  key :name, String
  key :code, String 
  key :address, String
  key :status, String
  key :latlng, String
  key :note, String
  key :stamp, Time
  key :mile_meter, Integer
  key :sort_order, Float
  key :parent, Integer
  include Mongoid::Timestamps
  timestamps!
end


class NurseRecord  < GXTModel

  include Mongoid::Document

  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'

  key :name,  String

  key :description, String

  key :admit_id, ObjectId

  key :start_time, Time
  key :stop_time, Time

  key :status, String

  key :note, String

  key :note_2, String

  key :note_3, String

  key :note_4, String

  key :remark, String

  key :tag, String

  key :updated_user_id, ObjectId

  key :data_record_id, ObjectId

  key :sh_visit_id, ObjectId



  include Mongoid::Timestamps

end

class Medication  < GXTModel
  include Mongoid::Document
  belongs_to :medgroup, :class_name=>'EsmMiotMonitor::MedGroup'
  has_many :meddoses, :class_name=>'EsmMiotMonitor::MedDose'

  key :medgroup_id, ObjectId
  key :name,  String
  key :concentration, String

  key :volume, Float
  key :unit_type, String
  key :route, String

  include Mongoid::Timestamps


end

class MedGroup  < GXTModel
  include Mongoid::Document
  has_many :medications, :class_name=>'EsmMiotMonitor::Medication'

  key :name,  String
  include Mongoid::Timestamps


end

class MedDose  < GXTModel
  include Mongoid::Document
  belongs_to :medication, :class_name=>'EsmMiotMonitor::Medication'

  key :medication_id, ObjectId
  key :name,  String
  include Mongoid::Timestamps

end

class MedRoute  < GXTModel
  include Mongoid::Document

  key :name,  String
  include Mongoid::Timestamps

end

class MedUnit  < GXTModel
  include Mongoid::Document

  key :name,  String
  include Mongoid::Timestamps

end

class MedicationRecord  < GXTModel
  include Mongoid::Document

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

  key :unit_type, String
  key :route, String

  key :note, String

  key :tag, String
  include Mongoid::Timestamps



end

class Patient  < GXTModel
  include Mongoid::Document

  has_many :admits, :class_name=>'EsmMiotMonitor::Admit'

  key :hn, String
  key :name, String
  key :public_id, String
  key :prefix_name, String
  key :first_name, String
  key :middle_name, String
  key :last_name, String
  key :dob, Time
  key :age, String
  key :gender, String
  key :phone, String
  key :contact_name, String
  key :contact_phone, String

  key :hospital_id, ObjectId
  key :network_id, ObjectId
  key :zone_id, ObjectId

  key :picture, ObjectId

  key :blood, String
  key :status, String
  key :job, String
  key :race, String
  key :nation, String
  key :religion, String
  key :passport, String
  key :addr, String
  key :addr_present, String
  key :parent, String
  key :note, String
  key :underlying, String

  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId

  key :image_id, ObjectId



  include Mongoid::Timestamps
  def to_s
    "#{self.prefix_name}#{self.first_name} #{self.last_name}"
  end

  def to_age date = Time.now

    if self.dob

    out = ((date - self.dob)/31536000).to_i

    return out

    elsif self.age
      return self.age
    else

      return nil
    end

  end

  def to_age_text date = Time.now

    age = self.to_age date
    out = '-'
    out = "#{format("%0.1f",age)}" if age and age!=""

    return out

  end


end





class Score  < GXTModel
  include Mongoid::Document

  has_many :items, :class_name=>'EsmMiotMonitor::ScoreItem'

  key :name, String
  key :version, String
  key :description, String
  key :sort_order, Integer
  key :active, Boolean
  key :default, Boolean
  
  
  include Mongoid::Timestamps

  def to_s
      self.name
    end
end

class ScoreItem  < GXTModel
  include Mongoid::Document

  belongs_to :score, :class_name=>'EsmMiotMonitor::Score'
  has_many :conditions, :class_name=>'EsmMiotMonitor::ScoreCondition'


  key :name, String # key value
  key :title, String # key value
  key :source, String

  key :sort_order, Integer
  key :score_id, ObjectId
  # include Mongoid::Timestamps

end

class ScoreCondition < GXTModel
  include Mongoid::Document

  belongs_to :score_item, :class_name=>'EsmMiotMonitor::ScoreItem'

  key :sort_order, Integer

  key :score_item_id, ObjectId

  key :min, Float # key value
  key :max, Float # key value

  key :option, String # key value

  key :score, Integer # key value

  key :alert_msg, String
  key :alert_tag, String
  include Mongoid::Timestamps

end


class Treatment  < GXTModel
  include Mongoid::Document
  belongs_to :treatmentgroup, :class_name=>'EsmMiotMonitor::TreatmentGroup'

  key :treatmentgroup_id, ObjectId
  key :name,  String

  include Mongoid::Timestamps

end

class TreatmentGroup  < GXTModel
  include Mongoid::Document
  has_many :treatments, :class_name=>'EsmMiotMonitor::Treatment'

  key :name,  String
  include Mongoid::Timestamps

end



class Device  < GXTModel
  include Mongoid::Document
  belongs_to :station, :class_name=>'EsmMiotMonitor::Station'
  key :name, String
  key :ip, String
  key :serial_number, String
  key :type, String
  include Mongoid::Timestamps
  def to_s
    self.name
  end
end


class Ambulance  < GXTModel
  include Mongoid::Document
  
  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId
  
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
  key :last_speed, Float
  key :last_mile, Integer

  key :location_policy, String # any, app, dvr
  key :device_no, String # for dvr
  key :msg_channel, String
  
  key :image, ObjectId


  include Mongoid::Timestamps


end

class AmbulanceDriver  < GXTModel
  include Mongoid::Document
  key :name, String
  key :mobile, String
  key :phone, String
  key :address, String
  key :public_id, String
  key :user_id, ObjectId
  include Mongoid::Timestamps

end



class Setting  < GXTModel
  include Mongoid::Document
  key :name, String
  key :value, String
  include Mongoid::Timestamps


  def self.set name, value
    record = self.where(:name=>name).first
    unless record
      record = self.create :name=>name, :value=>value
    else
      record.update_attributes :value=>value
    end
  end

  def self.get name, default=nil
      record = self.where(:name=>name).first
      unless record
        record = self.create :name=>name, :value=>default if default != nil
      end
      value = record.value if record
      return value
  end
end


class CaseReport < GXTModel

  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'

  key :center_name, String
  key :date, Time
  key :center_address, String

  key :admit_id, ObjectId
  key :result, String



  include Mongoid::Timestamps

end




class DataRecord  < GXTModel
  include Mongoid::Document

  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'

  belongs_to :created_user, :class_name=>'EsmMiotMonitor::User'
  belongs_to :updated_user, :class_name=>'EsmMiotMonitor::User'

  key :created_user_id, ObjectId
  key :updated_user_id, ObjectId


  key :admit_id, ObjectId
  key :station_id, ObjectId

  key :staff_id, String
  
  key :station_name, String 

  key :data, String
  key :bp, String
  key :bp_sys, Integer
  key :bp_dia, Integer
  key :bp_mean, Integer
  key :bp_pr, Integer

  key :pr, Integer
  key :hr, Integer
  key :spo2, Integer
  key :rr, Integer
  key :temp, Float
  key :co2, Integer

  key :glucose, Integer
  key :weight, Float
  key :height, Float
  key :bmi, Float


  key :eye, String
  key :motor, String
  key :verbal, String
  key :pupil, String


  key :stamp, Time
  key :bp_stamp, String

  key :status, String

  key :score_name, String
  key :score, Integer
  
  key :patient_type, String

  key :note, String
  key :score_id, ObjectId

  key :send_status, Boolean
  key :send_msg, String

  key :sh_visit_id, ObjectId
  
  key :remote_id, String


  include Mongoid::Timestamps

  timestamps!


  def send_record url


    i = self


    begin

    data = {}




    data = JSON.parse i.data if i.data
    
    

    px = {:hn=>data['hn'], :weight=>'', :height=>'', :bmi=>'', :pr=>'', :rr=>'', :spo2=>'',:bp=>i.bp, :bp_sys=>i.bp_sys, :bp_dia=>i.bp_dia, :bp_mean=>i.bp_mean}

	  px[:weight] = format("%.2f",i[:weight].to_f) if i[:weight] and i[:weight]!="" and i[:weight]!="-"
	  px[:height] = format("%.2f",i[:height].to_f) if i[:height] and i[:height]!="" and i[:height]!="-"

    px[:patient_type] = i[:patient_type] if i[:patient_type] 
    px[:score_name] = data['score_name'] if data['score_name']
    # px[:score] = data['score'] if data['score']
    px[:score] = i.score
     
    px[:avpu] = data['avpu'] if data['avpu']




	if i[:weight] and i[:weight]!="" and i[:weight]!="-"

    	weight = i[:weight].to_f
    	height = i[:height].to_f

		  px.merge! :weight=>format("%.2f",weight),:height=>format("%.2f",height),:bmi=>format("%.2f",weight/height/height*10000)

	end

	px[:pr] = i[:pr] if i[:pr]!='' and i[:pr]!='-'
	px[:spo2] = i[:spo2] if i[:spo2]!='' and i[:spo2]!='-'
	px[:temp] = i[:temp] if i[:temp]!='' and i[:temp]!='-'
	px[:rr] = i[:rr] if i[:rr]!='' and i[:rr]!='-'

	px[:time] = Time.now.strftime("%H:%M:%S")
	px[:date] = Time.now.strftime("%Y-%m-%d")

	px[:serial_number] = i.station_name


  px[:serial_number] = i[:device_id] if i[:device_id]
  
  # px[:patient_type] = i[:patient_type]


	px[:record_id] = i.id
	px[:record_at] = i.created_at
	px[:staff_id] = data['staff_id']

 



      http = Net::HTTP.new(url.host, url.port)
      http.read_timeout = 2 # seconds


      request = Net::HTTP::Post.new("#{url.path}?#{url.query}", initheader = {'Content-Type' =>'application/json'})
      request.set_form_data(px)


      response = Net::HTTP.start(url.host, url.port,:open_timeout => 1, :read_timeout => 3) {|http| http.request(request)}
      result = JSON.parse response.body


	    puts 'RESULT '+result.to_json


      # i.update_attributes :send_status=>result['status']=='200 OK', :send_msg=>result.to_json
		  if result['status']=='200 OK'
        i.send_status = result['status']=='200 OK'
        i.send_msg = result.to_json
		  else
        i.send_status = false
        i.send_msg = result.to_json
      end
      i.save



      return result['status']=='200 OK'


    rescue Exception => e
      puts e.message
      puts  e.backtrace
      error = true
      err_msg = "Server Timeout!"
      puts err_msg
      return false
    end


  end


  def self.get_sense_list
    return %w{bp pr spo2 temp weight height rr glucose}.collect{|t| t.to_sym}
  end

  def self.get_sense_label
    return %w{ความดันโลหิต อัตราการเต้นหัวใจ ปริมาณออกซิเจน อุณหภูมิ น้ำหนัก ส่วนสูง อัตราการหายใจ ระดับน้ำตาล}
  end

  def self.get_sense_unit
    return %w{mmHg bpm % &#8451; kg cm bpm mmol/L}
  end


  def self.get_current_status admits


    now = Time.now

    from_time = (now-30*24*3600).beginning_of_day

    sense_list = get_sense_list
    sense_label = get_sense_label
    sense_unit = get_sense_unit

    maps = {}
    alerts = []

    for i in admits
    patient = i.patient



    	records = i.records.where(:stamp=>{'$gte'=>from_time, '$lte'=>now}).all

    	map = {}



    	for r in records
    		sense_list.each_with_index do |t,ti|
    			value = r[t]
    			if value and value!='-' and value.to_i>0
    				map[t] = {:value=>value, :stamp=>r.stamp.strftime("%d/%m/%y %H:%M"),
    					    :unit=>sense_unit[ti], :label=>sense_label[ti]}



              alert = SHAlert.vs_condition(t, value)





    				if alert
              alert = {:text=>alert[1], :class=>'warning'}
    					alerts << {:i=>i, :t=>t, :patient=>patient, :v=>map[t]}
    				end
    				map[t][:alert] = alert

    			end
    		end

    	end

    	maps[i.id] = map

    end


    return {:alerts=>alerts, :maps=>maps}

  end











end




class Post < GXTModel
  include Mongoid::Document

  key :title, String

  key :content, String

  include Mongoid::Timestamps

  timestamps!

end

class PostController < GXTDocument


end

class HomeController < GXT
  
  def acl
    # return {:login=>'*',:auto=>'*'}
    return {:index_unattend=>'*'}

  end
  

end


class UserController < GXTDocument

  def acl
    # return {:login=>'*',:auto=>'*'}
    return {:create=>'*', :xxx=>'*'}

  end
  

end



class UserLogController < GXTDocument



end

class AddressBookController < GXTDocument

end

class RoleController < GXTDocument

end

class AttachmentController < GXTDocument

  def acl

    return {:content=>'*'}

  end


  #  /Attachment/content?id=
  def content params

    attachment = model.find params[:id]

    # puts "ERR:#{Mongoid::Config.clients["default"]['hosts'].inspect}"

    connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override

    grid = Mongo::Grid::FSBucket.new(connection.database)

    ofile = grid.open_download_stream(attachment.file_id)

    info = ofile.file_info

    if info

    filename = info.filename

    if attachment.type == 'image'

    @context.content_type 'image/jpg'

    elsif attachment.type == 'voice'

    @context.content_type 'audio/3gpp'

  elsif attachment.type == 'application' and attachment.content_type == 'application/pdf'
    
     @context.content_type 'application/pdf'
    
  end 
    
    
    

    data =  ofile.read.force_encoding('utf-8')

    return data

   else
    return nil
   end

  end
end


class CaseReportController < GXTDocument

end


class ZoneController < GXTDocument

end

class RoomController < GXTDocument

end

class BedController < GXTDocument

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

class MessageController < GXTDocument

  def acl

    return {:content=>'*'}

  end

  def content params

    message = model.find params[:id]

    puts "ERR:#{Mongoid::Config.clients["default"]['hosts'].inspect}"

    connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override

    grid = Mongo::Grid::FSBucket.new(connection.database)

    ofile = grid.open_download_stream(message.file_id)

    info = ofile.file_info
    if info

    filename = info.filename


    if message.type == 'image'

    @context.content_type 'image/jpg'

   elsif message.type == 'voice'

    @context.content_type 'audio/3gpp'

    end

    data =  ofile.read.force_encoding('utf-8')

    return data

   else
    return nil
   end

  end
end




class ScoreController < GXTDocument

end

class ScoreItemController < GXTDocument

end


class NurseRecordController < GXTDocument

end

class MedicationController < GXTDocument

end

class MedGroupController < GXTDocument

end

class MedDoseController < GXTDocument

end

class MedRouteController < GXTDocument

end

class MedUnitController < GXTDocument

end

class MedicationRecordController < GXTDocument

end

class ScoreConditionController < GXTDocument

end

class TreatmentController < GXTDocument

end

class TreatmentGroupController < GXTDocument

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


  def acl
    # return {:login=>'*',:auto=>'*'}
    return {:partial=>'*', :pdf=>'*', :data_json=>'*', :data_commit=>'*'}

  end


  def submit_data params

       admit = model.find params[:id]

       if admit

          admit.update_attributes :current_score=>params[:data][:score]


        end


          data = {}

          for i in DataRecord.fields.keys
            data[i] = params[:data][i] if i.to_s!='_id'
          end




          record = admit.records.create data
          # params[:data][:admit_id] = admit.id
          # record = DataRecord.create params[:data]

          if params[:option]

          params[:option].each_pair do |k,v|

            params[:data]["#{k}_opt".to_sym] = v

          end

          record.update_attributes :data=>params[:data].to_json, :stamp=>Time.now

          if params[:score_id]
            score = Score.find params[:score_id]
          else
            score = admit.score
          end

          admit.nurse_records.create :start_time=> Time.now , :description=>"#{score.name} v.#{score.version} = #{params[:data][:score]} : #{score.description}"


path = "miot/#{@context.settings.name}/z/#{admit.zone.name}"
msg = 'NULL'
send_msg = <<MSG
#{'Zone.Message'} #{path}
#{msg.to_json}
MSG
@context.settings.redis.publish(path, send_msg)



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
