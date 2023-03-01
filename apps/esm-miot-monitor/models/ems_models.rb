require "base64"
require "uri"
require "net/http"

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
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'

  belongs_to :init_code, :class_name=>'EsmMiotMonitor::EMSCode', foreign_key: 'init_cbd_code'
  has_many :commands, :class_name=>'EsmMiotMonitor::EMSCommand', order: "created_at ASC", foreign_key: 'case_id'
  belongs_to :channel, :class_name=>'EsmMiotMonitor::EMSChannel', foreign_key: 'channel_id'

  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone', foreign_key: 'zone_id'

  key :dispatch_note, String
  key :team_id, String

  key :ambulance_id, ObjectId

  key :admit_id, ObjectId

  key :station_id, ObjectId

  key :zone_id, ObjectId

  key :status, String

  key :tracking_status, String




  # request ============================================================================

  key :case_no, String

  key :chief_complain, String


  # key :request_cbd_code, ObjectId

  key :init_cbd_code, ObjectId

  key :init_cbd_color, String
  key :dispatch_cbd_color, String
  key :scene_cbd_color, String
  key :screen_cbd_color, String

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




  # Command

  key :channel_id, ObjectId
  key :location, String
  key :address, String
  key :latlng, String
  key :note, String
  key :dispatch_at, DateTime


  key :patient_location, String
  key :patient_images, Array


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

  key :distance_from_dispatch, Integer
  key :distance_from_hospital, Integer



  key :over_activate_time_reason, String
  key :over_response_time_reason, String

  key :over_time_managment, String


  def relocation_target latlng

      admit_log_list = AdmitLog.where(:admit_id=>self.admit_id, :sort_order=>{'$in'=>[3,4]}).all
      puts 'Relocat '+self.admit_id.to_s
      for i in admit_log_list

          i.update_attributes :latlng=>latlng

          if i.sort_order==3
              aoc_case_routes = AocCaseRoute.where(:arrival_log_id=>i.id).all
              for aoc_case_route in aoc_case_routes
              if aoc_case_route
                  aoc_case_route.update_attributes :stop_latlng=>latlng, :est_distance=>nil, :est_duration=>nil, :response=> nil, :note=>'Relocation'
              end
            end
          end

      end



  end

  def noti_message

    ems_case = self
    channel = EMSChannel.find ems_case.channel_id
    ambulance = Ambulance.find ems_case.ambulance_id
    message = "#{ems_case.case_no} รหัส: #{ems_case.init_code.code} ผู้ป่วย: #{ems_case.patient_gender} #{ems_case.patient_age}ปี อาการ: #{ems_case.chief_complain}\nติดต่อ: #{ems_case.contact_phone} สถานที่: #{ems_case.location}\nคำสั่ง: #{ems_case.dispatch_note} ทีม: #{channel.name if channel} รถ: #{ambulance.name if ambulance}"

      return message

  end




  include Mongoid::Timestamps


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
  key :dispatch_emd_id, ObjectId
  key :driver_emt_id, ObjectId

  key :note, String
  key :channel_id, String

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


class LineAccount < GXTModel

  include Mongoid::Document

  has_many :messages, :class_name=>'EsmMiotMonitor::LineMessage', foreign_key: 'account_id'

  key :name, String

  key :user_id, String

  key :type, String


  def send_message text, option={:type=>'text'}


    url = 'http://103.20.120.53:4567/send?channel=ems'

    url = Setting.get 'outgoing_webhook', url

    if self.user_id
     uri = URI(url)
     if option[:type] == 'text'

          res = Net::HTTP.post_form(uri, 'user_id' => self.user_id, 'text' => text)

      elsif option[:type] == 'raw'
        puts 'type=raw'+text+' user_id:'+self.user_id
          res = Net::HTTP.post_form(uri, 'user_id' => self.user_id, 'msg' => text)

      end
      puts res.body
      return res.body
  #   puts res.body

    end

  end


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


class LineMessage < GXTModel

  include Mongoid::Document

  belongs_to :account, :class_name=>'EsmMiotMonitor::LineAccount',  foreign_key: 'account_id'

  key :account_id, ObjectId

  key :message_id, String
  key :user_id, String

  key :type, String
  key :message_type, String
  key :text, String
  key :source_type, String

  key :content, String

    include Mongoid::Timestamps


end





class EMSController < GXT



  def acl

    return {:request_ems=>'*',:image_upload=>'*', :provider_registration=>'*'}

  end

  def image_upload params

    begin


    switch @context.settings.name



    ems_case = EMSCase.find params[:id]

    # content = params[:capture]['tempfile'].read
#
#     filename = params[:capture]['filename']
#

    filename= "img.jpg"
    index = params[:capture].index(',')+1
    content = Base64.decode64(params[:capture][index..-1])

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

    body = {"message"=>Setting.get("tracking_sms","EMS Tracking Service กรุณากด : <TRACKING-URL>"), "sender"=>Setting.get("sms_sender","Demo-SMS"), "phone" => ems_case.contact_phone , "url"=> "#{Setting.get("host_url","https://pcm-life.com:1792")}/#{@context.settings.name}/EMS/request_ems?id=#{ems_case.id}" }

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
    return  response.read_body + '<META HTTP-EQUIV="Refresh" CONTENT="0;URL='+url+'">'

  end





  def default_layout
    return :rocker_layout
  end

end

class EMSAssessmentController < GXTDocument

end

class EmsReportController < GXT

end


class EMSDVRController < GXTDocument

end

class EMSHospitalController < GXTDocument

end

class EMSUnitController < GXTDocument

end

class LineAccountController < GXTDocument

end

class LineMessageController < GXTDocument

end

class EMSChannelController < GXTDocument

end

class EMSCaseController < GXTDocument

end

class EMSCodeController < GXTDocument

end


class EMSCodeGroupController < GXTDocument

end

class EMSParamedicController < GXTDocument

end



class EMSCaseWorkflowController < GXTDocument

end

class EMSCaseProcessController < GXTDocument

end

class EMSCaseActionController < GXTDocument

end

class EMSKWorkflowController < GXTDocument

end

class EMSKProcessController < GXTDocument

end

class EMSKActionController < GXTDocument

end

class EMSKBackupController < GXTDocument

end

class EMSCommandController < GXTDocument
end

class EMSCommandProviderController < GXTDocument
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


    url = URI("https://notify-api.line.me/api/notify")

    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    line_access_code = Setting.get('line_access_code')
    if line_access_code
    message = params[:message]

    request = Net::HTTP::Post.new(url)
    request["Authorization"] = "Bearer #{line_access_code}"
    request["Content-Type"] = "application/x-www-form-urlencoded"
    request.body = "message=#{ERB::Util.url_encode(message)}"

    response = https.request(request)
    puts response.read_body

    return response.read_body

    else

    return "NA"

    end

  end


end



end
