require "base64"
require "uri"
require "net/http"
require_relative "../lib/push"
require_relative "msg_models"


module EsmMiotMonitor


class EMSUnit < GXTModel
  include Mongoid::Document
  key :name, String
  key :code, String
  key :name, String
  key :latlng, String
  key :address, String
  key :phone, String
  key :status, String
  key :type, String
  
  key :image, ObjectId

  def self.current current_user

    provider = Provider.where(:user_id=>current_user.id).first

    if provider and provider.unit_id
     
     current_unit = EMSUnit.find provider.unit_id

     return current_unit
      
    end

    return nil

  end


end

class EMSHospital < GXTModel
  include Mongoid::Document
  key :name, String
  key :district, String
  key :code, String
  key :name, String
  key :latlng, String
  key :address, String
  key :phone, String
  key :status, String
  key :type, String
  key :level, String
  key :ct_scan, String
  key :mri, String
  key :rt_pa, String
  key :ct_scan, String
  key :thrombectomy, String



end




class EMSCase < GXTModel



  include Mongoid::Document
  
  
  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId
  
  
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'

  belongs_to :init_code, :class_name=>'EsmMiotMonitor::EMSCode', foreign_key: 'init_cbd_code'
  has_many :commands, :class_name=>'EsmMiotMonitor::EMSCommand', order: "created_at", foreign_key: 'case_id'
  belongs_to :channel, :class_name=>'EsmMiotMonitor::EMSChannel', foreign_key: 'channel_id'

  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone', foreign_key: 'zone_id'
  belongs_to :ambulance, :class_name=>'EsmMiotMonitor::Ambulance', foreign_key: 'ambulance_id'

  belongs_to :user, :class_name=>'EsmMiotMonitor::User', foreign_key: 'user_id'


  key :user_id, ObjectId
  key :dispatch_unit_id, ObjectId
  key :dispatch_unit_at, DateTime

  key :start_at, DateTime
  key :request_at, DateTime
  
  
  key :schedule_from, DateTime
  key :schedule_to, DateTime
  
  key :meeting_key, String


  key :dispatch_note, String
  key :team_id, String

  key :ambulance_id, ObjectId

  key :admit_id, ObjectId

  key :station_id, ObjectId

  key :zone_id, ObjectId

  key :status, String

  key :date, DateTime
  
  key :shift, String


  # SENT for when send sms to patient
  # ACCESSED when active
  # CALLING when  video calling actived by case code
  key :tracking_status, String
  key :video_status, String



  # request ============================================================================

  key :case_no, String
  key :ext_case_no, String
  

  key :chief_complain, String

  key :emd_event_note, String


  # key :request_cbd_code, ObjectId

  key :init_cbd_code, ObjectId

  key :init_cbd_color, String
  key :dispatch_cbd_color, String
  key :scene_cbd_color, String
  key :screen_cbd_color, String
  key :triage_note, String

  key :case_type, String # EMS / Refer
  key :patient_type, String # Trauma


  # key :final_cbd_code, ObjectId

  key :contact_name, String

  key :contact_phone, String

  key :patient_id, ObjectId
  key :patient_name, String
  key :patient_info, String
  key :patient_gender, String
  key :patient_age, String
  key :patient_birth_date, DateTime
  key :patient_nationality, String


  key :patient_cid, String
  key :patient_hn, String
  key :patient_phone, String

  key :patient_underlying, String

  key :ems_type, String
  key :ems_trauma, String
  key :scene_triage, String

  key :code_155, String

  key :patient_weight, Float

  key :patient_height, Float

  key :patient_bmi, Float

  # Command

  key :channel_id, ObjectId
  key :location, String
  key :address, String
  key :latlng, String
  key :note, String
  key :dispatch_at, DateTime
  
  key :gps_duration, Float
  key :gps_distance, Float


  key :patient_location, String
  # key :patient_images, Array


  key :route_type, String
  key :transfer_status, String
  key :transfer_hospital, String
  key :transfer_hospital_id, ObjectId
  key :transfer_hn, String



  key :bls_request, String
  key :bls_onscene, String
  key :bls_operation, String
  key :special_request, String
  key :special_type, String
  key :bls_cpr, String




  # paramedic


  key :paramedic_status , String
  key :paramedic_start_at , DateTime
  key :paramedic_stop_at , DateTime
  key :completed_at, DateTime


  key :init_sbp, Integer
  key :init_dbp, Integer
  key :init_hr, Integer
  key :init_rr, Integer
  key :init_spo2, Integer
  key :init_gcs, Integer   #E4V5M6
  key :init_temp, Integer
  key :init_dtx, Integer

  key :cpr_status, String
  key :cpr_start_at, DateTime



  # discharge

  key :discharge_stamp, DateTime
  key :operation_note, String

  key :operation_result, String
  key :operation_result_detail, String

  key :operation_hospital, String
  key :operation_cancel, String
  key :operation_cancel_reason, String
  key :operation_cancel_at, DateTime
  key :patient_reimbursement, String

  key :er_triage, String
  key :diagnosis, String

  key :init_vs_stamp, DateTime
  key :init_sbp, Integer
  key :init_dbp, Integer
  key :init_hr, Integer
  key :init_rr, Integer
  key :init_spo2, Integer
  key :init_gcs, String
  key :init_temp, Float
  key :init_dtx, Integer

  key :repeat_vs_stamp, DateTime
  key :repeat_sbp, Integer
  key :repeat_dbp, Integer
  key :repeat_hr, Integer
  key :repeat_rr, Integer
  key :repeat_spo2, Integer
  key :repeat_gcs, String
  key :repeat_temp, Float
  key :repeat_dtx, Integer

  key :screen_vs_stamp, DateTime
  key :screen_sbp, Integer
  key :screen_dbp, Integer
  key :screen_hr, Integer
  key :screen_rr, Integer
  key :screen_spo2, Integer
  key :screen_gcs, String
  key :screen_temp, Float
  key :screen_dtx, Integer

  key :dispatch_time, Integer
  key :activation_time, Integer
  key :response_time, Integer
  key :onscene_time, Integer
  key :transfer_time, Integer
  key :total_time, Integer

  key :distance_from_dispatch, Integer
  key :distance_from_hospital, Integer



  key :over_activate_time_reason, String
  key :over_response_time_reason, String

  key :over_time_managment, String


  key :summary, String
  key :sync_status, String
  key :sync_at, DateTime
  key :sync_ref, String
  
  
  key :export, String # AwaitExport, Exported
  key :export_log, String
  
  key :export_data, String
  key :export_data_log, String

 
  def get_meeting_key solution='miot'
    
    key = nil
    
      unless self.meeting_key
        
        key = "#{solution}-#{self.case_no}"
     
        self.update_attributes :meeting_key=>key
                
      else
        
        key = self.meeting_key
        
      end
    
      return key
    
  end

  def relocation_target latlng

      ambu = self.ambulance
      if ambu

        ambu.last_location = Setting.get('aoc_center') unless ambu.last_location or ambu.last_location == ""

        key = Setting.get(:google_api_key)
        direction = google_direction(ambu.last_location, latlng, key)

        if direction[:status]=='200 OK'
            self.update_attributes :gps_distance=>direction[:total_distance][:value], :gps_duration=>direction[:total_duration][:value]
        end

        admit_log_list = AdmitLog.where(:admit_id=>self.admit_id, :sort_order=>{'$in'=>[3,4]}).all
        puts 'Relocat '+self.admit_id.to_s
        for i in admit_log_list

            i.update_attributes :latlng=>latlng

            if i.sort_order==3
                aoc_case_routes = AocCaseRoute.where(:arrival_log_id=>i.id).all
                for aoc_case_route in aoc_case_routes
                if aoc_case_route
                    aoc_case_route.update_attributes :stop_latlng=>latlng, :est_distance=>nil, :est_duration=>nil, :response=> nil, :note=>'Relocation', :last_location=>nil, :last_cal=>nil
                end
              end
            end

        end

    end

  end

  def noti_message

    ems_case = self
    channel = EMSChannel.find ems_case.channel_id
    ambulance = Ambulance.find ems_case.ambulance_id
    patient_gender = ""
    patient_age = ""
    location = ""
    dispatch_note = ""
    if ems_case.patient_gender == "M"
      patient_gender = "ชาย"
    elsif ems_case.patient_gender == "F"
      patient_gender = "หญิง"
    else
      patient_gender = "ไม่ทราบเพศ"
    end
    if ems_case.patient_age == nil || ems_case.patient_age == ""
      patient_age = "ไม่ทราบอายุ"
    else
      patient_age = ems_case.patient_age
    end
    if ems_case.location == nil || ems_case.location == ""
      location = "ยังไม่เเน่ชัด รอสั่งการเพิ่มเติม"
    else
      location = ems_case.location
    end  
    if ems_case.dispatch_note == nil || ems_case.dispatch_note == ""
      dispatch_note = "ไม่มีคำสั่งเพิ่มเติม"
    else
      dispatch_note = ems_case.dispatch_note 
    end 
    
    if ems_case.init_code
      message = 
"
#{ems_case.case_no}\n 
รหัส : #{ems_case.init_code.code}\n 
ผู้ป่วย : #{patient_gender} #{patient_age} ปี\n 
อาการ : #{ems_case.chief_complain}\n
ติดต่อ : #{ems_case.contact_phone}\n 
สถานที่ : #{location}\n
คำสั่ง : #{ems_case.dispatch_note}\n 
ทีม : #{channel.name if channel}\n 
รถ : #{ambulance.name if ambulance}\n
"
      return message
    else
      return nil
    end
      
  end


  def  update_message context, msg, notify='Zone.Refresh'


    puts "UpdateMessage"

path = "miot/#{context.settings.name}/z/#{self.zone.name}"

msg = "{\"msg\":\"#{msg}\"}"

send_msg = <<MSG
#{notify} #{path}
#{msg}
MSG

    context.settings.redis.publish(path, send_msg)

  end


  def send_push_noti title, body, cmd, cmd_value
     
    commands = self.commands
    if commands.size>0 
    
    command = commands[0]
    
    vid = command.ambulance.name
    
    devices = EMSDevice.where(:vehicle_id=>vid, :fcm_token=>{'$ne'=>nil}).all
    
    for i in devices


      send_firebase_notification 'smart-ems-6dbe1', i.fcm_token, title, body, cmd, cmd_value
    

    end
    
  end
    
  end


  def self.estimate start_latlng , stop_latlng, mode = 'driving'

    base_url = "https://maps.googleapis.com/maps/api/directions/json"
    params = {
      origin: start_latlng,
      destination: stop_latlng,
      mode: mode,
      key: Setting.get("google_api_key")
    }
  
    uri = URI(base_url)
    uri.query = URI.encode_www_form(params)
  
    response = Net::HTTP.get_response(uri)
    result = JSON.parse(response.body)
  
    if result["status"] == "OK"
      duration = result["routes"][0]["legs"][0]["duration"]["text"]
      puts "Estimated travel time: #{duration}"
      return result
    else
      puts "Error: #{result["status"]}"
      return result
    end

  end


  include Mongoid::Timestamps


end

class EMSProgressNote < GXTModel
    include Mongoid::Document
    key :case_id, ObjectId
    key :name, String
    key :type, String
    key :time, DateTime
    key :ref_id, ObjectId
    key :item_id, ObjectId
    key :text, String
    key :hidden, String
end


class EMSCode < GXTModel

  include Mongoid::Document
  belongs_to :group, :class_name=>'EsmMiotMonitor::EMSCodeGroup', foreign_key: 'group_id'

  key :code, String

  key :name, String

  key :color, String

  key :cls, String

  key :description, String

  key :group_id, ObjectId

  def  get_color

    c = self.code



    i = c.to_i

    j = c[-1..-1].to_i
    j = c[-2..-1].to_i if c[-2..-1].to_i > j

    il = i.to_s.length
    jl = j.to_s.length

    th_color = "#{c[il..-(jl+1)]}"


  end

  def get_class

    color = self.get_color

    cls = 'info'

    case color
    when "แดง"
      cls = "danger"
    when "เหลือง"
      cls = "warning"
    when "เขียว"
      cls = "success"
    when "ขาว"
      cls = "primary"
    else
    end

    return cls
  end


end




class EMSCodeGroup < GXTModel

  include Mongoid::Document

  key :code, String

  key :name, String

  key :description, String


end

class EMSCaseCounter < GXTModel

  include Mongoid::Document

  key :key, String

  key :count, Integer

end

class EMSKWorkflow < GXTModel

  include Mongoid::Document

  key :name, String
  key :code, String
  key :type, String
  key :visible, String
  key :color, String
  key :order, Integer
  key :group, Integer
  key :template, String # workflow_code

end

class EMSKProcess < GXTModel

  include Mongoid::Document

  key :name, String
  key :name_en, String
  key :order, Integer
  key :tag, String

  key :kworkflow_id, ObjectId

end

class EMSKAction < GXTModel

  include Mongoid::Document

  key :name, String

  key :type, String

  key :message, String

  key :linkto, Float
  key :linkto_process_id, ObjectId
  key :linkto_workflow_id, ObjectId

  key :kprocess_id, ObjectId

  key :kworkflow_id, ObjectId

end

class EMSKBackup < GXTModel

  include Mongoid::Document

  key :name, String
  key :code, String
  include Mongoid::Timestamps

end

class EMSCaseWorkflow < GXTModel

  include Mongoid::Document

  key :case_id, ObjectId
  key :kworkflow_id, ObjectId

end

class EMSCaseProcess < GXTModel

  include Mongoid::Document

  key :case_id, ObjectId
  key :case_workflow_id, ObjectId
  key :kprocess_id, ObjectId
  key :action, String
  key :note, String


end

class EMSCaseAction < GXTModel

  include Mongoid::Document

  key :case_id, ObjectId
  key :case_process_id, ObjectId
  key :kaction_id, ObjectId
  key :name, String


end


class EMSCommand < GXTModel

  include Mongoid::Document

  belongs_to :ambulance, :class_name=>'EsmMiotMonitor::Ambulance',  foreign_key: 'ambulance_id'
  has_many :providers, :class_name=>'EsmMiotMonitor::EMSCommandProvider', foreign_key: 'command_id'


  key :case_id, ObjectId
  key :init_command, String
  key :ambulance_id, ObjectId


  key :transfer_hospital, String
  key :transfer_hospital_id, ObjectId
  key :emd_code, String
  key :driver_name, String
  key :emt_driver_code, String
  key :emt_partner_code, String
   
  key :note, String
  key :channel_id, String

  key :est_fuel, String
  key :oxygen_1, String
  key :oxygen_2, String
  key :check_result, String
  key :check_time, DateTime
  key :check_note, String


  include Mongoid::Timestamps






end





class EMSCommandProvider < GXTModel

  include Mongoid::Document
  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  key :command_id, ObjectId
  key :provider_id, ObjectId
  key :position, String
  key :name, String
  key :note, String
  key :sort_order, Integer

end

class EMSTrackingDevice < GXTModel
  
  include Mongoid::Document

  key :name, String
  key :title, String
  key :device_no, String
  
  
end


class EMSTrackingRecord < GXTModel
  
  include Mongoid::Document

  key :device_id, ObjectId
  key :data, String
  key :stamp, Integer
  
  
end

class EMSDVR < GXTModel

  include Mongoid::Document

  key :name, String
  key :device_id, String
  key :connection, String
  key :note, String
  key :latlng, String
  key :channels, Integer
  key :type, String

end


class EMSChannel < GXTModel
   include Mongoid::Document
  key :name, String
  key :zone_id, ObjectId

end






class EMSAssessment < GXTModel

  include Mongoid::Document

  key :code, String

  key :name, String

  key :description, String

  key :group, String

  key :data, String

  key :type, String

  key :sort_order, Integer

  key :zone_id, ObjectId

  key :position, String

end


class EMSCasePatientStatus < GXTModel

  include Mongoid::Document

  key :name, String
  key :title, String
  key :description, String
  key :patient_type, String
  key :case_id, ObjectId
  key :patient_status_id, ObjectId


  include Mongoid::Timestamps


end


class EMSPatientStatus < GXTModel

  include Mongoid::Document

  key :name, String
  key :title, String
  key :description, String
  key :patient_type, String
  key :color, String

  key :img_1, ObjectId
  key :img_2, ObjectId
  key :img_3, ObjectId




end


class EMSPatientStatusItem < GXTModel

  include Mongoid::Document

  key :name, String
  key :description, String
  key :position, String
  key :patient_status_id, ObjectId
  key :assessment_id, ObjectId
  key :sort_order, Integer
  key :data, String



end


class EMSProtocol < GXTModel
  
  include Mongoid::Document

  key :name, String
  key :description, String
  key :group, String
  
  key :sort_order, Integer
  key :file_id, ObjectId
  
   
end


class EMSDevice < GXTModel
  
  include Mongoid::Document

  key :name, String # device number
  key :type, String
  key :title, String
  key :vehicle_id, String
  key :fcm_token, String
  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId
  
  
  
end

class EMSDeviceLog < GXTModel
  
  include Mongoid::Document

  key :device_id, ObjectId
  key :data, Object 
   
   
end



class EMSGXT < GXT
  
  def acl
       return {'*'=>'admin'}
  end
  
  # def nav params
  #   return '.'
  # end
  
  def default_layout
    return :rocker_layout
  end
end

class EMSGXTDocument < GXTDocument
  

  
  def default_layout
    return :rocker_layout
  end
end

class EMSMeeting < GXTModel

  include Mongoid::Document

  
  belongs_to :unit, :class_name=>'EsmMiotMonitor::EMSUnit', foreign_key: 'unit_id'
  key :unit_id, ObjectId
  
  
  key :creator, String
  
  key :name, String
  key :case_id, ObjectId
  key :status, String
  
  key :partial_hn, String
  key :partial_patient_name, String
  key :partial_detail, String 
  key :partial_address, String
  key :location, String
  key :eta, String
  key :remark, String 
  key :schedule_at, DateTime
  key :zone_id, ObjectId
  
  key :type, String
  include Mongoid::Timestamps

end


class EMSMeetingController < GXTDocument

  
  
  def default_layout
    return :rocker_layout
  end
  
  
end

class EMSNotiController < GXT


end


class EMSController < GXT



  def acl

    return {:request_ems=>'*',:image_upload=>'*', :provider_registration=>'*', :video=>'*', :pdf=>'*', :request_map=>'*'}

  end

  def image_upload params

    begin


    switch @context.settings.name



    ems_case = EMSCase.find params[:id]

    # content = params[:capture]['tempfile'].read
#
#     filename = params[:capture]['filename']
#
    if params[:mode] == nil


    filename= "img.jpg"
    index = params[:capture].index(',')+1
    content = Base64.decode64(params[:capture][index..-1])

    elsif params[:mode] == 'file'
    
      puts params[:capture].inspect 
      
    content = params[:capture]['tempfile'].read

    filename = params[:capture]['filename']
    
    end


    connection =  Mongo::Client.new Mongoid::Config.clients["default"]['hosts'], :database=>Mongoid::Threaded.database_override

    grid = Mongo::Grid::FSBucket.new(connection.database)

    fid = grid.upload_from_stream(filename,content)


    meta = {}
    meta['sender'] = 'NA'
    meta['recipient'] = 'NA'
    meta['recipient_type'] = 'NA'
    meta['filename'] = filename
    meta['ts'] = Time.now.to_i
    meta['type'] = 'image'
    meta['media_type'] = 'image'

    station_id = nil

    i = meta


    msg = Message.create :admit_id=> ems_case.admit_id, :sender=> i['sender'], :recipient=> i['recipient'], :recipient_type=> i['recipient_type'], :content=> i['filename'], :ts=> i['ts'], :type=>i['type'], :media_type=>i['type'], :file_id=>fid, :station_id=>station_id


    admit = Admit.find ems_case.admit_id

path = "miot/#{@context.settings.name}/z/#{admit.zone.name}"

msg = 'NULL'
send_msg = <<MSG
#{'Zone.Message'} #{path}
#{msg.to_json}
MSG


    @context.settings.redis.publish(path, send_msg)



  rescue =>error
   puts  error.backtrace
  end


    return 'ok'

  end


    



  def send_sms params

    ems_case = EMSCase.find params[:id]
      
    body = {"message"=>Setting.get("sms_msg","EMS Tracking Service กรุณากด : <TRACKING-URL>"), "sender"=>Setting.get("sms_sender","Demo-SMS"), "phone" => ems_case.contact_phone , "url"=> "#{Setting.get("host_url","https://pcm-life.com:1792")}/EMS/request_ems?id=#{ems_case.id}" }

    require 'uri'
    require 'net/http'
    require 'openssl'

    url = URI("https://portal-otp.smsmkt.com/api/send-message")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["api_key"] = Setting.get("sms_api_key")
    request["secret_key"] = Setting.get("sms_secret_key")

    request.body = body.to_json
    puts  body.to_json
    response = http.request(request)
    ems_case.update_attributes :tracking_status=>'SENT'
    url = "show?id=#{ems_case.id}"


  	ems_case.update_message @context, "request send sms"


    return   '<center>Send Message</center><META HTTP-EQUIV="Refresh" CONTENT="3;URL='+url+'"><br/>'+response.read_body 

  end


  def send_otp params
    

    url = URI("https://portal-otp.smsmkt.com/api/otp-send")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Post.new(url)
    request["Accept"] = 'application/json'
    request["Content-Type"] = 'application/json'
    request["api_key"] = Setting.get("sms_api_key")
    request["secret_key"] = Setting.get("sms_secret_key")
    project_key = "e66c042574"
    phone = params[:phone]
    ref = params[:ref] || "#{format("%06d",rand(999999))}"
    request.body = "{\"project_key\":\"#{project_key}\",\"phone\":\"#{phone}\",\"ref_code\":\"#{ref}\"}"

    response = http.request(request)
    
    url = params[:return] || "../EMSUser/profile"
    
    res = JSON.parse(response.body)
    ref_code = ""
    if res['code'] == "000"
      ref_code = res['result']['ref_code']
      token =  res['result']['token']
      query = "ref=#{ref_code}&token=#{token}"
    end

  
    return  '<center>Send OTP </center><META HTTP-EQUIV="Refresh" CONTENT="3;URL='+url.to_s+'?'+query+'"><br/>'+response.read_body 
    
    
  end




  def default_layout
    return :rocker_layout
  end

end

class EMSAssessmentController < EMSGXTDocument

end

class EMSProgressNoteController  < EMSGXTDocument
end


class EmsReportController < EMSGXT

end


class EMSDVRController < EMSGXTDocument

end

class EMSHospitalController < EMSGXTDocument

end

class EMSUnitController < EMSGXTDocument

end


class EMSChannelController < EMSGXTDocument

end

class EMSCaseController < EMSGXTDocument
  
  

end

class EMSCaseCounterController < EMSGXTDocument

end

class EMSCodeController < EMSGXTDocument

end


class EMSCodeGroupController < EMSGXTDocument

end

class EMSParamedicController < EMSGXTDocument

  def acl

    return {:message_partial=>'*',:image_upload=>'*', :register_remote=>'*', :provider=>'*'}

  end
end


class EMSCaseWorkflowController < EMSGXTDocument

end

class EMSCaseProcessController < EMSGXTDocument

end

class EMSCaseActionController < EMSGXTDocument

end

class EMSProtocolController < EMSGXTDocument

end

class EMSKWorkflowController < EMSGXTDocument

end

class EMSKProcessController < EMSGXTDocument

end

class EMSKActionController < EMSGXTDocument

end

class EMSKBackupController < EMSGXTDocument

end

class EMSCommandController < EMSGXTDocument
end

class EMSCommandProviderController < EMSGXTDocument
end

class EMSCasePatientStatusController < EMSGXTDocument
end

class EMSPatientStatusController < EMSGXTDocument
end

class EMSPatientStatusItemController < EMSGXTDocument
end

class EMSDeviceController < EMSGXTDocument

end

class EMSDeviceLogController < EMSGXTDocument

end


class EMSApiController < GXT
   def acl 
    return {'*'=>'*'}
   end



   
end

class EMSEmtController < GXT

  def acl

    return '*'

  end


    def default_layout
      return :'ems_emt/layout'
    end


end


class EMSConnectController < GXT

end

class EMSConnect


  def self.line_noti params


    line_group_id = Setting.get('line_group_id')

    if line_group_id

   
      line_group = LineGroup.where(:group_id=>line_group_id).first

      if line_group

        line_group.send_message params[:message], :type=>'text'

      end


    # url = URI("https://notify-api.line.me/api/notify")

    # https = Net::HTTP.new(url.host, url.port)
    # https.use_ssl = true

    # line_access_code = Setting.get('line_access_code')
    # if line_access_code
    # message = params[:message]

    # request = Net::HTTP::Post.new(url)
    # request["Authorization"] = "Bearer #{line_access_code}"
    # request["Content-Type"] = "application/x-www-form-urlencoded"
    # request.body = "message=#{ERB::Util.url_encode(message)}"

    # response = https.request(request)
    # puts response.read_body

    # return response.read_body

    # else

    # return "NA"

     end

  end


end


class EMSAdminController < EMSGXT

end

class EMSUserController < EMSGXT

end




class EmsRequestController < GXT

  def default_layout
    return :rocker_layout
  end

end


class EmsPrearrivalController < GXT

  def default_layout
    return :rocker_layout
  end

end



class EmsCommandController < GXT

  def default_layout
    return :rocker_layout
  end

end


class EmsOperationController < GXT

  def default_layout
    return :rocker_layout
  end

end



class EmsParamedicController < GXT

  def default_layout
    return :rocker_layout
  end

end



class EmsDischargeController < GXT

  def default_layout
    return :rocker_layout
  end

end

class EmsKMController < GXT

  def default_layout
    return :rocker_layout
  end

end




end
