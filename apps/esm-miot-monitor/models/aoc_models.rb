module EsmMiotMonitor
  

  class AocCaseRoute < GXTModel
    
    include Mongoid::Document
    belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
    
    belongs_to :departure_log, :class_name=>'EsmMiotMonitor::AdmitLog'
    
    belongs_to :arrival_log, :class_name=>'EsmMiotMonitor::AdmitLog'
    
    key :address, String
    
    key :status, String
    
    key :sort_order, Integer
    
    key :start_latlng, String
    key :stop_latlng, String
    
    key :ems_command_id, ObjectId
    
    key :departure_log_id, ObjectId
    key :arrival_log_id, ObjectId
    
    key :est_distance, Integer # km
    key :est_duration, Integer # min
    key :act_distance, Integer
    key :act_duration, Integer
    
    key :start_time, Time
    key :stop_time, Time
    
    
    key :note, String
    
    
    include Mongoid::Timestamps
    
  end


class AocCaseReport < GXTModel
  
  include Mongoid::Document
  belongs_to :admit, :class_name=>'EsmMiotMonitor::Admit'
  
#หน่วย
  key :center_name, String
  key :date, Time
  key :center_address, String
  
  key :admit_id, ObjectId
  key :result, String

  key :officer_1, String 
  key :officer_id_1, String 
  key :officer_2, String 
  key :officer_id_2, String 
  key :officer_3, String 
  key :officer_id_3, String 
  key :officer_4, String 
  key :officer_id_4, String 
  key :site_addr, String
  key :site_desc, String
  
  key :time_get, String
  key :time_order, String
  key :time_leave, String
  key :time_arrive, String
  key :time_back, String
  key :time_hos, String
  key :time_base, String

  key :sum_time_response, String
  key :sum_time_to_hos, String
  key :sum_time_to_base, String
  key :dis_response, String
  key :dis_to_hos, String
  key :dis_to_base, String
  
  
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

  key :hospital, String 
  key :hospital_type, String 
  key :reason, String 
  key :reporter, String 
  key :reporter_id, String 

  key :diagnosis, String 
  key :diag_level, String
  key :diag_breath, String 
  key :diag_blood, String 
  key :diag_liquid, String 
  key :diag_bone, String 
  key :diag_name, String 
  key :diag_pos, String 

  key :admitted, String 
  key :status, String 
  
  include Mongoid::Timestamps
  
end



class AocCaseReportController < GXTDocument
  
end

class AocCaseRouteController < GXTDocument
  
end


end