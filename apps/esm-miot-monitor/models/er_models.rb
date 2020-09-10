module EsmMiotMonitor
  

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