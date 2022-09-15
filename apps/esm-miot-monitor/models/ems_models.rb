require "base64"
module EsmMiotMonitor

class EMSCase < GXTModel
  
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  belongs_to :init_code, :class_name=>'EsmMiotMonitor::EMSCode', foreign_key: 'init_cbd_code'
  has_many :commands, :class_name=>'EsmMiotMonitor::EMSCommand', order: "created_at ASC", foreign_key: 'case_id'
  belongs_to :channel, :class_name=>'EsmMiotMonitor::EMSChannel', foreign_key: 'channel_id'
  
  belongs_to :zone, :class_name=>'EsmMiotMonitor::Zone', foreign_key: 'zone_id'
  
  
  key :case_no, String
  
  key :chief_complain, String
      
  key :request_cbd_code, ObjectId
      
  key :init_cbd_code, ObjectId
  
  key :final_cbd_code, ObjectId
  
  key :contact_name, String
  
  key :contact_phone, String
  
  key :patient_id, ObjectId
  key :patient_name, String
  key :patient_info, String
  key :patient_gender, String
  key :patient_age, String
  
  key :patient_cid, String
  key :patient_hn, String
  key :patient_phone, String
  
  key :patient_underlying, String
  
  key :channel_id, ObjectId
  
  
  key :location, String
  key :address, String
  key :latlng, String
  
  key :note, String
  
  
  key :patient_location, String
  key :patient_images, Array
  
  key :tracking_status, String
      
  key :admit_id, ObjectId
  
  key :station_id, ObjectId
  
  
  key :zone_id, ObjectId
  
  key :status, String
  
  key :paramedic_status , String
  key :paramedic_start_at , DateTime
  key :paramedic_stop_at , DateTime
  
  
  key :completed_at, DateTime
  
  include Mongoid::Timestamps

    
end

class EMSCode < GXTModel
  
  include Mongoid::Document
  
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

    return {:request_ems=>'*',:image_upload=>'*'}

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




class EMSDVRController < GXTDocument
  
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

class EMSParamedicController < GXTDocument
  
end

class EmsEMRController < GXTDocument
  
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


end