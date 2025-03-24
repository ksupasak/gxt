module EsmMiotMonitor
  

class ERCase < GXTModel
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  belongs_to :patient, :class_name=>'EsmMiotMonitor::Patient'
  belongs_to :reimbursement, :class_name=>'EsmMiotMonitor::Reimbursement'
  belongs_to :provider, :class_name=>'EsmMiotMonitor::Provider'
  belongs_to :room, :class_name=>'EsmMiotMonitor::Room'
  belongs_to :bed, :class_name=>'EsmMiotMonitor::Bed'
  belongs_to :unit, :class_name=>'EsmMiotMonitor::Unit'

  
  include Mongoid::Timestamps
  key :case_no, String
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

  key :chief_complain, String
  key :remark, String

  key :patient_cid, String
  key :patient_hn, String
  key :patient_phone, String

  key :patient_underlying, String

  key :inbound, String
  key :scene_triage, String

  key :code_155, String

  key :patient_weight, Float

  key :patient_height, Float

  key :patient_bmi, Float

  key :reimbursement_id, ObjectId

  key :admit_id, ObjectId
  key :date, Time
  key :status, String

  key :diagnosis, String
  key :diagnosis_icd, String

  key :triage_room, String
  key :doctor_name, String
  key :special, String

  key :provider_id, ObjectId
  key :provider_name, String
  key :resident_id, ObjectId
  key :resident_name, String
  key :nurse_id, ObjectId
  key :nurse_name, String
  key :nurse_assistant_id, ObjectId
  key :nurse_assistant_name, String


  key :room_id, ObjectId
  key :bed_id, ObjectId
  key :unit_id, ObjectId
  key :bed_name, String

  key :round_period, Integer

  key :referred_to, String

  def self.notify context, options={}
    zone = Zone.find(options[:zone_id])
    path = "miot/#{context.settings.name}/z/#{zone.name}"
    msg = 'NULL'
    send_msg = <<MSG
#{'Zone.Refresh'} #{path}
#{msg.to_json}
MSG
puts send_msg
res = context.settings.redis.publish(path, send_msg)
puts res
  end
end

class ERCaseController < GXTDocument
  
end

class ERCaseReport < GXTModel
  
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
  key :center_name, String
  key :date, Time
  key :center_address, String
  
  key :admit_id, ObjectId
  key :result, String
  
  
  key :bp_sys, Integer
  key :bp_dia, Integer
  key :bp_mean, Integer
  
  key :spo2, Integer
  key :pr, Integer
  
  key :temp, Integer
  
  key :rr, Integer
  
  
  
  key :chief_complaint, String
  
  key :level, String
  
  
  key :trauma_status, String
  
  
  key :trauma_concious, String
  
  key :trauma_wound, String
  
  key :trauma_bone, String
  
  key :trauma_blood, String
  
  key :trauma_organ, String
  
  
  key :non_trauma_med, String #อายุรกรรม
  
  key :non_trauma_wound, String

  key :non_trauma_gyne, String #สูติ-นรีเวช
  key :non_trauma_pediatric, String #กุมารฯ
  key :non_trauma_surgery, String #ศัลยกรรม
  key :non_trauma_etc, String #อื่นๆ
  
  key :treatment_breath, String #หายใจ
  key :treatment_wound, String #แผล
  key :treatment_liquid, String #สารน้ำ
  key :treatment_bone, String #ดามกระดูก
  key :treatment_cpr, String #CPR

  key :medicine, String 
  key :primary_result, String 
  
  include Mongoid::Timestamps
  
end



class ERCaseReportController < GXTDocument
  
end



end